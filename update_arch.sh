#!/bin/bash

######################################################################
# Script de Actualización y Limpieza de Distribución (Arch Linux y derivados)
# Autor: Daniel González 
# Versión: 1.2
# Fecha: 14 de Mayo de 2025
#
# Este script automatiza tareas de actualización y limpieza en una
# distribución de Linux basada en Arch Linux. Realiza la actualización de paquetes,
# actualización de paquetes Snap y Flatpak (si es aplicable), limpieza de caché
# y eliminación de paquetes innecesarios.
#
# Uso: ./update_arch.sh
#
# Requiere permisos de superusuario (root) para ejecutarse.
######################################################################


# Verifica si se ejecuta como superusuario
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;91mEste script debe ejecutarse como superusuario.\e[0m"
    exit 1
fi

# Limpia pantalla
clear

# Fecha de ejecución
FECHA=$(date "+%Y-%m-%d %H:%M:%S")

# Presentación
echo -e "\n\e[1;32m*************************************************************"
echo "** Script para Actualización y Limpieza de Arch/Manjaro   **"
echo "*         Autor: Daniel González     -  Fecha: $FECHA         *"
echo "*                        Versión 1.2                       *"
echo -e "*************************************************************\e[0m\n"

# Función para mostrar título y ejecutar comando
run_command() {
    echo -e "\n\e[1;32m###########################################"
    echo "# $1"
    echo -e "###########################################\e[0m\n"
    eval "$2"
}

# Comandos principales
run_command "1. Actualizando paquetes del sistema..." "pacman -Syu --noconfirm"

run_command "2. Limpiando caché de paquetes..." "yes | pacman -Sc"

# Elimina paquetes huérfanos si existen
orphans=$(pacman -Qdtq 2>/dev/null)
if [ -n "$orphans" ]; then
    run_command "3. Eliminando paquetes huérfanos..." "pacman -Rns --noconfirm $orphans"
else
    echo -e "\e[1;90mNo hay paquetes huérfanos para eliminar.\e[0m"
fi

# Snap
if command -v snap &>/dev/null; then
    run_command "4. Actualizando paquetes Snap..." "snap refresh"
else
    echo -e "\e[1;90mSnap no está instalado. Se omite.\e[0m"
fi

# Flatpak
if command -v flatpak &>/dev/null; then
    run_command "5. Actualizando paquetes Flatpak..." "flatpak update -y"
else
    echo -e "\e[1;90mFlatpak no está instalado. Se omite.\e[0m"
fi

# Finalización
echo -e "\n\e[1;32m*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizado ****"
echo -e "*************** $(date '+%Y-%m-%d %H:%M:%S') ***************\e[0m\n"
