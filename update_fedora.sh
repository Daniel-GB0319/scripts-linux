#!/bin/bash

# Corrección en palabras y términos utilizados, además de agregar actualización para 
# paquetes snap y flatpak en caso de ser aplicables. 07/Mayo/2023

clear
echo ""
echo "*************************************************************"
echo "** Script para Actualizacion y Limpieza de la Distribucion **"
echo "*          ****** Autor: Daniel Gonzalez ******             *"
echo "*                        Ver. 1.2                           *"
echo "*************************************************************"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo dnf -y upgrade"
echo "2) sudo snap refresh"
echo "3) flatpak update"
echo "3) sudo dnf -y autoremove"
echo "2) sudo dnf clean all"
echo ""
echo "% Ingrese la contraseña y espere a que el Script finalice: %"
echo ""
sudo dnf -y upgrade
echo ""
echo "#######################################################################"
echo "#          !!! Paquetes sincronizados y Actualizados !!!              #"
echo "# % Se actualizarán los paquetes snap/flathub, en caso de haberlos. % #"
echo "#######################################################################"
echo ""
sudo snap refresh
echo ""
flatpak update
echo ""
echo "####################################################"
echo "#   !!! Paquetes snap/flathub Actualizados !!!     #"
echo "# % Ahora se limpiaran los paquetes innecesarios % #"
echo "####################################################"
echo ""
sudo dnf -y autoremove
echo ""
echo "#############################################################"
echo "#        !!! Paquetes innecesarios eliminados !!!           #"
echo "# % Se limpiarán archivos temporales para ahorrar espacio % #"
echo "#############################################################"
echo ""
sudo dnf clean all
echo ""
echo "*******************************************************"
echo "**** Script de Actualizacion y Limpieza Finalizada ****"
echo "*******************************************************"
echo ""
