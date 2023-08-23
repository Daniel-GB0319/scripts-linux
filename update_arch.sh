#!/bin/bash

######################################################################
# Script de Actualización y Limpieza de Distribución (Arch Linux y derivados)
# Autor: Daniel González 
# Versión: 2.0
# Fecha: 22 de Agosto de 2023
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

# Verifica si el usuario tiene permisos de superusuario
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;91mEste script debe ejecutarse como superusuario.\e[0m"
    exit 1
fi

# Función para ejecutar comandos y mostrar mensajes
run_command() {
    echo ""
    echo -e "\e[1;32m###########################################"
    echo "# $1"
    echo -e "###########################################\e[0m"
    echo ""
    $2
}

# Limpiar pantalla
clear

# Presentación inicial del programa 
echo ""
echo -e "\e[1;32m*************************************************************"
echo "** Script para Actualización y Limpieza de la Distribución **"
echo "*          ****** Autor: Daniel González ******             *"
echo "*                        Ver. 1.1                           *"
echo "*************************************************************\e[0m"
echo ""
echo -e "\e[1;93mComandos a ejecutar:\e[0m"
echo -e "1) \e[93mActualizar paquetes (sudo pacman -Syu)\e[0m"
echo -e "2) \e[93mActualizar paquetes Snap (sudo snap refresh)\e[0m"
echo -e "3) \e[93mActualizar paquetes Flatpak (flatpak update)\e[0m (si es aplicable)"
echo -e "4) \e[93mLimpiar caché con (sudo pacman -Sc)\e[0m"
echo -e "5) \e[93mEliminar paquetes innecesarios (sudo pacman -Rns $(pacman -Qdtq))\e[0m"
echo ""
echo -e "% Ingrese la contraseña y espere a que el Script finalice: %\e[0m"
echo ""
sleep 2s

# Ejecutación de comandos con sus respectivos mensajes
run_command "1. Actualizando paquetes..." "sudo pacman -Syu"
run_command "2. Actualizando paquetes Snap..." "sudo snap refresh"
run_command "3. Actualizando paquetes Flatpak..." "flatpak update"
run_command "4. Limpiando caché..." "sudo pacman -Sc"
run_command "5. Eliminando paquetes innecesarios..." "sudo pacman -Rns $(pacman -Qdtq)"

# Mensaje de finalización del programa
echo ""
echo -e "\e[1;32m*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizada ****"
echo -e "*******************************************************\e[0m"
echo ""
