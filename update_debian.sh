#!/bin/bash

######################################################################
# Script de Actualización y Limpieza de Distribución (Debian y derivados)
# Autor: Daniel González 
# Versión: 2.0
# Fecha: 22 de Agosto de 2023
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
echo "*                        Ver. 2.0                           *"
echo -e "*************************************************************\e[0m"
echo ""
echo -e "\e[1;93mComandos a ejecutar:\e[0m"
echo -e "1) \e[93mActualizar lista de paquetes disponibles (sudo apt update)\e[0m"
echo -e "2) \e[93mActualizar paquetes instalados (sudo apt upgrade -y)\e[0m"
echo -e "3) \e[93mActualizar la distribución (sudo apt full-upgrade -y)\e[0m"
echo -e "4) \e[93mActualizar paquetes instalados a través de Snap (sudo snap refresh)\e[0m"
echo -e "5) \e[93mActualizar paquetes instalados a través de Flatpak (flatpak update)\e[0m"
echo -e "6) \e[93mLimpiar archivos temporales (sudo apt autoclean -y)\e[0m"
echo -e "7) \e[93mEliminar paquetes innecesarios (sudo apt autoremove -y)\e[0m"
echo ""
echo -e "% Espere a que el Script finalice: %\e[0m"
echo ""
sleep 2s

# Ejecutación de comandos con sus respectivos mensajes
run_command "1. Sincronizando Repositorios..." "sudo apt update"
run_command "2. Actualizando Paquetes..." "sudo apt upgrade -y"
run_command "3. Actualizando la Distribución..." "sudo apt full-upgrade -y"
run_command "4. Actualizando Paquetes Snap..." "sudo snap refresh"
run_command "5. Actualizando Paquetes Flathub..." "flatpak update"
run_command "6. Eliminando Archivos temporales..." "sudo apt autoclean -y"
run_command "7. Eliminando Paquetes Innecesarios..." "sudo apt autoremove -y"

# Mensaje de finalización del programa
echo ""
echo -e "\e[1;32m*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizada ****"
echo -e "*******************************************************\e[0m"
echo ""
