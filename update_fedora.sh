#!/bin/bash

# Correccion y mejora de mensajes para visualizar en ventanas mas pequeñas. 6/Agosto/2022

clear
echo ""
echo "*************************************************************"
echo "** Script para Actualizacion y Limpieza de la Distribucion **"
echo "*          ****** Autor: Daniel Gonzalez ******             *"
echo "*                        Ver. 1.1                           *"
echo "*************************************************************"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo dnf -y upgrade"
echo "2) sudo dnf -y dsync"
echo "3) sudo dnf -y autoremove"
echo ""
echo "% Ingrese la contraseña y espere a que el Script finalice: %"
echo ""
sudo dnf -y upgrade
echo ""
echo "#############################################"
echo "#     !!! Paqueterias Actualizadas !!!      #"
echo "# % Ahora se actualizara la Distribucion. % #"
echo "#############################################"
echo ""
sudo dnf -y dsync 
echo ""
echo "####################################################"
echo "#         !!! Distribucion Actualizada !!!         #"
echo "# % Ahora se limpiaran los paquetes innecesarios % #"
echo "####################################################"
echo ""
sudo dnf -y autoremove
echo ""
echo "*******************************************************"
echo "**** Script de Actualizacion y Limpieza Finalizada ****"
echo "*******************************************************"
echo ""
