#!/bin/bash

echo "		******* Setup Inicial para Distribucion Debian y derivados ********"
echo "          	         ****** Autor: Daniel Gonzalez *******"
echo "                  	      Ver. 1.2 --- 06/Oct/2021"
echo ""
echo " Comandos a ejecutar:"
echo " 1) sudo apt install ufw "
echo " 2) sudo ufw enable "
echo " 3) sudo apt update "
echo " 4) sudo apt upgrade -y "
echo " 5) sudo apt full-upgrade -y "
echo " 6) sudo apt install clamav "
echo " 7) sudo systemctl stop clamav-freshclam "
echo " 8) sudo freshclam "
echo " 9) sudo systemctl start clamav-freshclam "
echo " 10) sudo apt install "
echo " 			neofetch" 
echo "			htop" 
echo "			pdftk" 
echo "			tree" 
echo "			git" 
echo "			build-essential" 
echo "			geany" 
echo "			remmina" 
echo "			wine" 
echo "			obs-studio" 
echo "			openshot"
echo "			vlc"
echo "			gimp"
echo " 11) sudo apt autoclean -y "
echo " 12) sudo apt autoremove -y "
sleep 2s
sudo apt install ufw
echo ""
sudo ufw enable
echo ""
sudo apt update
echo ""
sudo apt upgrade -y
echo ""
sudo apt full-upgrade -y 
echo ""
sudo apt install clamav
echo ""
sudo systemctl stop clamav-freshclam
echo ""
sudo freshclam
echo ""
sudo systemctl start clamav-freshclam
echo ""
sudo apt install neofetch htop pdftk tree git build-essential geany vlc remmina wine obs-studio openshot gimp 
echo ""
sudo apt autoclean -y
echo ""
sudo apt autoremove -y
echo ""
echo "		******** Tarea de Setup en Distribucion Debian y derivados Terminada *******"
echo ""
