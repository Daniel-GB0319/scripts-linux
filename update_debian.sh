#!/bin/bash

######################################################################
# Script de Actualización y Limpieza de Distribución (Debian y derivados)
# Autor: Daniel González 
# Versión: 2.1
# Fecha: 14 de Mayo de 2025
#
# Este script automatiza tareas de actualización y limpieza en una
# distribución de Linux basada en Debian. Realiza la sincronización de paquetes,
# actualizaciones, limpieza de archivos temporales y eliminación de
# paquetes innecesarios.
#
# Uso: ./update_debian.sh
#
# Requiere permisos de superusuario (root) para ejecutarse.
######################################################################


# Activar modo estricto:
# -e: salir si un comando falla
# -u: fallar si se usa una variable no definida
# -o pipefail: si un comando en un pipeline falla, todo el pipeline falla
set -euo pipefail

# Verifica si el script está siendo ejecutado como superusuario
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;91mEste script debe ejecutarse como superusuario.\e[0m"
    exit 1
fi

# Función para mostrar un mensaje decorativo antes de ejecutar un comando
# Si el comando falla, se notifica con un mensaje de error
run_command() {
    local description="$1"  # Descripción amigable del comando
    local command="$2"      # Comando real a ejecutar

    echo ""
    echo -e "\e[1;32m###########################################"
    echo "# $description"
    echo -e "###########################################\e[0m"
    echo ""

    # Ejecuta el comando y muestra un error si falla
    if ! eval "$command"; then
        echo -e "\e[1;91mError ejecutando: $command\e[0m"
    fi
}

# Limpia la terminal antes de mostrar el menú
clear

# Presentación visual del script
echo -e "\n\e[1;32m*************************************************************"
echo "** Script para Actualización y Limpieza de la Distribución **"
echo "*             Autor:  Daniel González   |   Ver. 2.1        *"
echo -e "*************************************************************\e[0m\n"

# Muestra la hora de inicio
echo -e "\e[1;93mInicio del proceso: $(date)\e[0m\n"
sleep 2s

# Se define un array con los comandos a ejecutar, cada elemento tiene:
# "Descripción del paso|Comando a ejecutar"
declare -a commands=(
    "Sincronizando Repositorios...|sudo apt update"
    "Actualizando Paquetes...|sudo apt upgrade -y"
    "Actualizando la Distribución...|sudo apt full-upgrade -y"
)

# Verifica si el comando 'snap' existe, y si es así, agrega su actualización
if command -v snap &> /dev/null; then
    commands+=("Actualizando Paquetes Snap...|sudo snap refresh")
fi

# Verifica si el comando 'flatpak' existe, y si es así, agrega su actualización
if command -v flatpak &> /dev/null; then
    # El modificador '-y' fuerza la actualización sin preguntar
    commands+=("Actualizando Paquetes Flatpak...|flatpak update -y")
fi

# Agrega tareas de limpieza al array
commands+=(
    "Eliminando Archivos Temporales...|sudo apt autoclean -y"
    "Eliminando Paquetes Innecesarios...|sudo apt autoremove -y"
)

# Recorre cada entrada del array y ejecuta los comandos
for entry in "${commands[@]}"; do
    # Separa la descripción y el comando usando el delimitador '|'
    IFS="|" read -r description command <<< "$entry"

    # Llama a la función run_command con los datos separados
    run_command "$description" "$command"
done

# Mensaje de finalización con hora
echo -e "\n\e[1;32m*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizada ****"
echo -e "*******************************************************\e[0m"
echo -e "\e[1;93mFinalizado en: $(date)\e[0m\n"
