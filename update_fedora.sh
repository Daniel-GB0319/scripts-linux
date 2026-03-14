#!/bin/bash

######################################################################
# Script de Actualización y Limpieza de Distribución (Fedora y derivados)
# Autor: Daniel González 
# Versión: 2.1
# Fecha: 14 de Marzo de 2026
#
# Este script automatiza tareas de actualización y limpieza en una
# distribución de Linux basada en Fedora. Realiza la actualización de paquetes,
# actualización de paquetes Snap y Flatpak (si es aplicable), 
# y eliminación de paquetes innecesarios.
#
# Uso: sudo ./update_fedora.sh
#
# Requiere permisos de superusuario (root) para ejecutarse.
######################################################################

# Activar modo estricto
set -euo pipefail

# Verifica si el script está siendo ejecutado como superusuario
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;91m[Error] Este script debe ejecutarse como superusuario (root).\e[0m"
    exit 1
fi

# Verifica conexión a internet haciendo ping a Google DNS
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "\e[1;91m[Error] No hay conexión a Internet. Abortando el script.\e[0m"
    exit 1
fi

# Función para mostrar un mensaje antes de ejecutar un comando
run_command() {
    local description="$1"
    local command="$2"

    echo ""
    echo -e "\e[1;34m###########################################"
    echo "# $description"
    echo -e "###########################################\e[0m"

    # Ejecuta comando y muestra error si falla
    if ! eval "$command"; then
        echo -e "\e[1;91m[!] Error ejecutando: $command\e[0m"
    fi
}

# Limpia la terminal
clear

# Presentación inicial del programa 
echo -e "\n\e[1;34m*************************************************************"
echo "** Script para Actualización y Limpieza de la Distribución **"
echo "* Autor: Daniel González   |   Ver. 2.1 (Fedora)        *"
echo -e "*************************************************************\e[0m\n"

# Registra el tiempo de inicio
START_TIME=$(date +%s)
echo -e "\e[1;93mInicio del proceso: $(date)\e[0m\n"
sleep 2

# Array de comandos
declare -a commands=(
    "Limpiando caché de DNF...|dnf clean all"
    "Actualizando Paquetes (DNF)...|dnf upgrade -y"
)

# Verifica si 'snap' existe
if command -v snap &> /dev/null; then
    commands+=("Actualizando Paquetes Snap...|snap refresh")
fi

# Verifica si 'flatpak' existe
if command -v flatpak &> /dev/null; then
    commands+=("Actualizando Paquetes Flatpak...|flatpak update -y")
fi

# Agrega tarea de limpieza de paquetes huérfanos
commands+=("Eliminando paquetes innecesarios...|dnf autoremove -y")

# Recorre array y ejecuta los comandos
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
echo -e "\n\e[1;34m*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizado ****"
echo -e "*******************************************************\e[0m"
echo -e "\e[1;93mFinalizado en: $(date)\e[0m"
echo -e "\e[1;96mTiempo total de ejecución: ${MINUTES} minuto(s) y ${SECONDS} segundo(s).\e[0m\n"

# Comprueba si el sistema requiere un reinicio
if command -v dnf &> /dev/null; then
    echo -e "\e[1;93mComprobando si es necesario reiniciar el sistema...\e[0m"

    if ! dnf needs-restarting -r &> /dev/null; then
        echo -e "\e[1;91m[ALERTA] Se han actualizado componentes críticos (ej. Kernel, Systemd).\e[0m"
        echo -e "\e[1;91mPor favor, ejecuta 'reboot' cuando te sea posible para aplicar los cambios.\e[0m\n"
    else
        echo -e "\e[1;32mNo es necesario reiniciar el sistema.\e[0m\n"
    fi
fi