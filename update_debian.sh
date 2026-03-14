#!/bin/bash

######################################################################
# Script de Actualización y Limpieza de Distribución (Debian y derivados)
# Autor: Daniel González 
# Versión: 2.3
# Fecha: 14 de Marzo de 2026
#
# Este script automatiza tareas de actualización y limpieza en una
# distribución de Linux basada en Debian. Realiza la sincronización de paquetes,
# actualizaciones, limpieza de archivos temporales y eliminación de
# paquetes innecesarios.
#
# Uso: sudo ./update_debian.sh
#
# Requiere permisos de superusuario (root) para ejecutarse.
######################################################################

# Activar modo estricto
set -euo pipefail

# Verifica si script está siendo ejecutado como superusuario
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;91m[Error] Este script debe ejecutarse como superusuario (root).\e[0m"
    exit 1
fi

# Verifica conexión a internet haciendo ping a Google DNS
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "\e[1;91m[Error] No hay conexión a Internet. Abortando el script.\e[0m"
    exit 1
fi

# Función para mostrar mensaje antes de ejecutar un comando
run_command() {
    local description="$1"  # Descripción del comando
    local command="$2"      # Comando a ejecutar

    echo ""
    echo -e "\e[1;36m###########################################"
    echo "# $description"
    echo -e "###########################################\e[0m"

    # Ejecuta el comando y muestra error si falla
    if ! eval "$command"; then
        echo -e "\e[1;91m[!] Error ejecutando: $command\e[0m"
    fi
}

# Limpia la terminal
clear

# Presentación del script
echo -e "\n\e[1;32m*************************************************************"
echo "** Script para Actualización y Limpieza de la Distribución **"
echo "* Autor:  Daniel González   |   Ver. 2.3        *"
echo -e "*************************************************************\e[0m\n"

# Registra tiempo de inicio
START_TIME=$(date +%s)
echo -e "\e[1;93mInicio del proceso: $(date)\e[0m\n"
sleep 2

# Array de comandos
declare -a commands=(
    "Sincronizando Repositorios...|apt update"
    "Actualizando Paquetes...|apt upgrade -y"
    "Actualizando la Distribución (Full)...|apt full-upgrade -y"
)

# Verifica si 'snap' existe
if command -v snap &> /dev/null; then
    commands+=("Actualizando Paquetes Snap...|snap refresh")
fi

# Verifica si 'flatpak' existe
if command -v flatpak &> /dev/null; then
    commands+=("Actualizando Paquetes Flatpak...|flatpak update -y")
fi

# Tareas de limpieza
commands+=(
    "Eliminando Archivos Temporales de APT...|apt autoclean -y"
    "Eliminando Paquetes Innecesarios y Dependencias Huérfanas...|apt autoremove -y"
)

# Recorre el array y ejecuta los comandos
for entry in "${commands[@]}"; do
    IFS="|" read -r description command <<< "$entry"
    run_command "$description" "$command"
done

# Calcula tiempo transcurrido
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

# Mensaje de finalización
echo -e "\n\e[1;32m*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizado ****"
echo -e "*******************************************************\e[0m"
echo -e "\e[1;93mFinalizado en: $(date)\e[0m"
echo -e "\e[1;96mTiempo total de ejecución: ${MINUTES} minuto(s) y ${SECONDS} segundo(s).\e[0m\n"

# Comprueba si el sistema requiere un reinicio
if [ -f /var/run/reboot-required ]; then
    echo -e "\e[1;91m[ALERTA] El sistema requiere un reinicio para aplicar las nuevas actualizaciones (ej. nuevo kernel).\e[0m"
    echo -e "\e[1;91mPor favor, ejecuta 'reboot' cuando te sea posible.\e[0m\n"
fi