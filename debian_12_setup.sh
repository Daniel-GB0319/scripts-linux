#!/bin/bash

# Se modificó el script para ser utilizado en Debian 12.
echo "	******* Setup Inicial para Debian 12  ********"
echo "      ****** Autor: Daniel Gonzalez *******"
echo "             Ver. 1.3 - 19/Mar/2024"
echo ""
echo " Se realizarán las siguientes tareas:"
echo " 1) Instalar y habilitar ufw "
echo " 2) Añadir los repositorios contrib y non-free"
echo " 3) Actualizar paquetería y distribución"
echo " 4) Instalar los sig. paquetes: clam* git pdftk tree btop neofetch build-essential obs-studio  handbrake remmina net-tools gimp kdenlive dkms mokutil curl wget"
echo " 5) Actualizar la base de datos de virus con freshclam"
echo " 6) Connfigurar clamav para optimizar recursos"
echo " 7) Eliminar paquetes firefox-esr libreoffice* clamz (se utilizaran alternativas o versiones de flathub)"
echo " 12) sudo apt autoremove -y "
apt install ufw
ufw enable
apt-add-repository contrib non-free
apt update && apt upgrade -y
apt full-upgrade -y 
apt install clam* git pdftk tree btop neofetch build-essential obs-studio handbrake remmina net-tools gimp kdenlive dkms mokutil curl wget
systemctl stop clamav-freshclam && freshclam
systemctl enable clamav-freshclam && systemctl disable clamav-daemon
apt purge -y firefox-esr libreoffice* clamz
apt autoclean -y && apt autoremove -y
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client
apt install flatpak

DESKTOP_ENV=$(echo $XDG_CURRENT_DESKTOP)
if [ "$DESKTOP_ENV" == "GNOME" ]; then
    echo "GNOME detectado. Instalando plugin flathub para Gnome Software"
    apt install gnome-software-plugin-flatpak
elif [ "$DESKTOP_ENV" == "KDE" ]; then
    echo "KDE Plasma detectado. Instalando plugin flathub para Discover"
    apt install plasma-discover-backend-flatpak
else
    echo "$DESKTOP_ENV detectado. No es necesario instalar plugin flathub para tienda de software"
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo ""
echo "		******** Tarea de Setup en Debian 12 Finalizada *******"