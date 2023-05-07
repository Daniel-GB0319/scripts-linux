#!/bin/bash

# Ligera modificación en texto de mensajes. 07/Mayo/2023

clear
echo ""
echo "*************************************************************"
echo "** Script para Actualización y Limpieza de la Distribución **"
echo "*          ****** Autor: Daniel González ******             *"
echo "*                      Ver. 1.5.1                           *"
echo "*************************************************************"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo apt update"
echo "2) sudo apt upgrade -y"
echo "3) sudo apt full-upgrade -y"
echo "4) sudo snap refresh"
echo "5) flatpak update"
echo "6) sudo apt autoclean -y"
echo "7) sudo apt autoremove -y"
echo ""
echo "% Ingrese la contraseña y espere a que el Script finalice: %"
echo ""
sleep 2s
sudo apt update
echo ""
echo "###########################################"
echo "#   !!! Repositorios Sincronizados !!!    #"
echo "# % Ahora se actualizarán los Paquetes. % #"
echo "###########################################"
echo ""
sudo apt upgrade -y
echo ""
echo "#############################################"
echo "#      !!! Paquetes Actualizados !!!        #"
echo "# % Ahora se actualizará la Distribución. % #"
echo "#############################################"
echo ""
sudo apt full-upgrade -y 
echo ""
echo "#######################################################################"
echo "#                 !!! Distribución Actualizada !!!                    #"
echo "# % Se actualizarán los paquetes snap/flathub, en caso de haberlos. % #"
echo "#######################################################################"
echo ""
sudo snap refresh
echo ""
flatpak update
echo ""
echo "#############################################################"
echo "#       !!! Paquetes snap/flathub Actualizados !!!          #"
echo "# % Se limpiarán archivos temporales para ahorrar espacio % #"
echo "#############################################################"
echo ""
sudo apt autoclean -y
echo ""
echo "################################################"
echo "#         !!! Limpieza Completa !!!            #"
echo "# % Se eliminarán los paquetes innecesarios. % #"
echo "################################################"
echo ""
sudo apt autoremove -y
echo ""
echo "*******************************************************"
echo "**** Script de Actualización y Limpieza Finalizada ****"
echo "*******************************************************"
echo ""
