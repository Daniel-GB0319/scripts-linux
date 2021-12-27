#!/bin/bash

# Se agregaron pasos para instalar git y wine de repositorios oficiales para obtener la version mas actual.
echo "		******* Setup Inicial para Distribucion Debian y derivados ********"
echo "          	         ****** Autor: Daniel Gonzalez *******"
echo "                  	      Ver. 1.2.1 --- 27/Dic/2021"
echo ""
echo " Comandos a ejecutar:"
echo " 1) sudo apt install ufw "
echo " 2) sudo ufw enable "
echo " 3) sudo apt update "
echo " 4) sudo apt upgrade -y "
echo " 5) sudo apt full-upgrade -y "
echo " 6) sudo apt install clamav "
echo " 	  6.1) sudo systemctl stop clamav-freshclam "
echo " 	  6.2) sudo freshclam "
echo " 	  6.3) sudo systemctl start clamav-freshclam "
echo " 7) add-apt-repository ppa:git-core/ppa  (Instala Git mas actual del repositorio oficial)"
echo " 8) sudo dpkg --add-architecture i386 (Instala Wine mas actual para Ubuntu 20.04 y derivados de repositorio Oficial)" 
echo "    8.1) wget -nc https://dl.winehq.org/wine-builds/winehq.key"
echo "    8.2) sudo apt-key add winehq.key"
echo "    8.3) sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'" 
echo " 8) sudo apt update"
echo " 9) sudo apt install "
echo " 		neofetch" 
echo "		htop" 
echo "		pdftk" 
echo "		tree"  
echo "		build-essential" 
echo "		geany" 
echo "		remmina" 
echo "		obs-studio" 
echo "		openshot"
echo "		vlc"
echo "		gimp"
echo "          git"
echo " 12) sudo apt install --install-recommends winehq-stable "
echo " 11) sudo apt autoclean -y "
echo " 12) sudo apt autoremove -y "
sleep 4s
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
add-apt-repository ppa:git-core/ppa
echo ""
sudo dpkg --add-architecture i386 
echo ""
wget -nc https://dl.winehq.org/wine-builds/winehq.key
echo ""
sudo apt-key add winehq.key
echo ""
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' 
echo ""
sudo apt update
echo ""
sudo apt install neofetch htop pdftk tree build-essential geany vlc remmina obs-studio openshot gimp git
echo ""
sudo apt install --install-recommends winehq-stable
echo ""
sudo apt autoclean -y
echo ""
sudo apt autoremove -y
echo ""
echo "		******** Tarea de Setup en Distribucion Debian y derivados Terminada *******"
echo ""
