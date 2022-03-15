#!/bin/bash

# Se alinearon mensajes de los pasos realizados para ajustarse en la ventana de terminal. 14/Marzo/2022

clear
echo ""
echo "*******************************************************************"
echo "***** Script para Actualizacion y Limpieza de la Distribucion *****"
echo "*             ****** Autor: Daniel Gonzalez ******                *"
echo "*                         Ver. 1.4.2                              *"
echo "*******************************************************************"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo apt update"
echo "2) sudo apt upgrade -y"
echo "3) sudo apt full-upgrade -y"
echo "4) sudo apt autoclean -y"
echo "5) sudo apt autoremove -y"
echo ""
echo "% Ingrese la contraseña para dar privilegios Root y espere a que el Script termine: %"
echo ""
sleep 2s
sudo apt update
echo ""
echo "#########################################################################################"
echo "#                       !!! Repositorios Sincronizados !!!                              #"
echo "# % Ahora se actualizaran los Programas/Paqueterias en caso de haber nuevas versiones % #"
echo "#########################################################################################"
echo ""
sudo apt upgrade -y
echo ""
echo "###############################################################################"
echo "#               !!! Programas/Paqueterias Actualizadas !!!                    #"
echo "# % Ahora se actualizara la Distribucion, en caso de haber nuevas versiones % #"
echo "###############################################################################"
echo ""
sudo apt full-upgrade -y 
echo ""
echo "#####################################################################"
echo "#                !!! Distribucion Actualizada !!!                   #"
echo "# % Ahora se limpiaran los archivos de actualizacion innecesarios % #"
echo "#####################################################################"
echo ""
sudo apt autoclean -y
echo ""
echo "#######################################################"
echo "#             !!! Limpieza Completa !!!               #"
echo "# % Por ultimo, se eliminaran paquetes innecesarios % #"
echo "#######################################################"
echo ""
sudo apt autoremove -y
echo ""
echo "*************************************************************"
echo "******* Script de Actualizacion y Limpieza Finalizada *******"
echo "*************************************************************"
echo ""
