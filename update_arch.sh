#!/bin/bash

######################################################################
# Script de Actualización y Limpieza de Distribución (Arch Linux y derivados)
# Autor: Daniel González 
# Versión: 1.3
# Fecha: 14 de Marzo de 2026
#
# Este script automatiza tareas de actualización y limpieza en una
# distribución de Linux basada en Arch Linux. Realiza la actualización de paquetes,
# actualización de paquetes Snap y Flatpak (si es aplicable), limpieza de caché
# y eliminación de paquetes innecesarios.
#
# Uso: sudo ./update_arch.sh
#
# Requiere permisos de superusuario (root) para ejecutarse.
######################################################################

# Activar modo estricto
set -euo pipefail

# Verifica si se ejecuta como superusuario
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;91m[Error] Este script debe ejecutarse como superusuario (root).\e[0m"
    exit 1
fi

# Verifica conexión a internet haciendo ping a Google DNS
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "\e[1;91m[Error] No hay conexión a Internet. Abortando el script.\e[0m"
    exit 1
fi

# Función para mostrar título y ejecutar comando
run_command() {
    local description="$1"
    local command="$2"

    echo -e "\n\e[1;35m###########################################"
    echo "# $description"
    echo -e "###########################################\e[0m"
    
    # Ejecuta el comando y avisa si falla
    if ! eval "$command"; then
        echo -e "\e[1;91m[!] Error ejecutando: $command\e[0m"
    fi
}

# Limpia pantalla
clear

# Presentación
echo -e "\n\e[1;35m*************************************************************"
echo "** Script para Actualización y Limpieza de Arch/Manjaro    **"
echo "* Autor: Daniel González   |   Ver. 1.3 (Arch)              *"
echo -e "*************************************************************\e[0m\n"

# Registra el tiempo de inicio
START_TIME=$(date +%s)
echo -e "\e[1;93mInicio del proceso: $(date)\e[0m\n"
sleep 2

# Comandos principales de pacman
run_command "Actualizando paquetes del sistema (Pacman)..." "pacman -Syu --noconfirm"
run_command "Limpiando caché de paquetes descargados..." "pacman -Sc --noconfirm"

# Elimina paquetes huérfanos si existen
echo -e "\n\e[1;35m###########################################"
echo "# Buscando paquetes huérfanos..."
echo -e "###########################################\e[0m"

# evitar que 'set -e' aborte el script si no hay huérfanos
orphans=$(pacman -Qdtq || true)

if [ -n "$orphans" ]; then
    run_command "Eliminando paquetes huérfanos..." "pacman -Rns --noconfirm $orphans"
else
    echo -e "\e[1;32mNo se encontraron paquetes huérfanos para eliminar.\e[0m"
fi

# Snap
if command -v snap &>/dev/null; then
    run_command "Actualizando paquetes Snap..." "snap refresh"
fi

# Flatpak
if command -v flatpak &>/dev/null; then
    run_command "Actualizando paquetes Flatpak..." "flatpak update -y"
fi

# Calcula el tiempo transcurrido
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

# Finalización
echo -e "\n\e[1;35m*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizado ****"
echo -e "*******************************************************\e[0m"
echo -e "\e[1;93mFinalizado en: $(date)\e[0m"
echo -e "\e[1;96mTiempo total de ejecución: ${MINUTES} minuto(s) y ${SECONDS} segundo(s).\e[0m\n"

# Comprobación de reinicio por actualización de Kernel en Arch
if [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
    echo -e "\e[1;91m[ALERTA] Se ha detectado una actualización del Kernel de Linux.\e[0m"
    echo -e "\e[1;91mPor favor, ejecuta 'reboot' para usar la nueva versión y evitar fallos con módulos USB/Red.\e[0m\n"
fi