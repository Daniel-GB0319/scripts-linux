#!/bin/bash

# =======================================================
#   Setup Inicial para Debian 12 / 13
#   Autor original: Daniel Gonzalez
#   Ver. 2.3 
# =======================================================

if [ "$EUID" -ne 0 ]; then
  echo "Error: Este script debe ejecutarse como root. Usa: sudo ./setup_debian.sh"
  exit 1
fi

LOG_FILE="/var/log/setup_debian_$(date +'%Y-%m-%d_%H-%M-%S').log"
exec > >(tee -i "$LOG_FILE") 2>&1

log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

ejecutar() {
    log "   $ $*"
    "$@"
}

separador() {
    echo -e "\n================================================================================"
}

# DETECCIÓN ENTORNO DE ESCRITORIO 
DE_TYPE="UNKNOWN"
HAS_GNOME=false
HAS_KDE=false

if dpkg -l | grep -q "plasma-workspace"; then
    DE_TYPE="QT"
    HAS_KDE=true
elif dpkg -l | grep -q "lxqt-session"; then
    DE_TYPE="QT" 
elif dpkg -l | grep -qE "gnome-shell|cinnamon-common|mate-desktop"; then
    DE_TYPE="GTK"
    HAS_GNOME=true
elif dpkg -l | grep -qE "xfce4-session|lxde"; then
    DE_TYPE="LIGHT"
fi

log " [DETECTOR] Familia multimedia detectada: $DE_TYPE"

if [ "$DE_TYPE" == "QT" ]; then
    OPT_PLAYER="vlc"
    OPT_EDITOR="kdenlive"
elif [ "$DE_TYPE" == "GTK" ]; then
    OPT_PLAYER="celluloid"
    OPT_EDITOR="openshot-qt"
elif [ "$DE_TYPE" == "LIGHT" ]; then
    OPT_PLAYER="mpv"
    OPT_EDITOR="openshot-qt"
else
    OPT_PLAYER="mpv"
    OPT_EDITOR="openshot-qt"
fi

separador
log "   Iniciando Configuración Maestra..."
log "   Registro completo: $LOG_FILE"
separador

# Validar conexión
log "[*] Verificando conexión a internet..."
if ! ping -c 1 google.com &> /dev/null; then
    log " [!] ERROR: No hay red. El script requiere internet para continuar."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
echo libdvd-pkg libdvd-pkg/first-install note | debconf-set-selections

apt-get install -y whiptail

separador
log "[1/8] Validando Repositorios..."
ejecutar apt-get update -y
ejecutar apt-get install -y curl wget gpg dirmngr pciutils
ejecutar apt-get full-upgrade -y

separador
log "[2/8] Analizando hardware (CPU)..."
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
if [[ "$CPU_VENDOR" == *"GenuineIntel"* ]]; then
    ejecutar apt-get install -y intel-microcode
elif [[ "$CPU_VENDOR" == *"AuthenticAMD"* ]]; then
    ejecutar apt-get install -y amd64-microcode
fi

separador
log "[3/8] Analizando hardware (GPU)..."
GPU_INFO=$(lspci | grep -i vga)
if echo "$GPU_INFO" | grep -qi "intel"; then
    ejecutar apt-get install -y intel-media-va-driver-non-free vainfo
elif echo "$GPU_INFO" | grep -qi "amd\|radeon"; then
    ejecutar apt-get install -y firmware-amd-graphics mesa-va-drivers mesa-vdpau-drivers vainfo
elif echo "$GPU_INFO" | grep -qi "nvidia"; then
    ejecutar apt-get install -y nvidia-driver firmware-misc-nonfree
fi

separador
log "[4/8] Analizando Chasis y Gestión de Energía..."
CHASSIS=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)
if [[ "$CHASSIS" =~ ^(8|9|10|11|14|31|32)$ ]]; then
    if [ "$HAS_KDE" = true ] || [ "$HAS_GNOME" = true ]; then
        log " [AVISO] GNOME o KDE Plasma detectado. Omitiendo TLP por conflictos de energía nativos."
    else
        log " [OPT] Instalando TLP para optimizar batería..."
        ejecutar apt-get install -y tlp tlp-rdw
        systemctl enable tlp && systemctl start tlp
    fi
fi

separador
log "[5/8] Instalación de Software Base (Seguridad, Red, Archivos, Móviles y Códecs)..."

# Lógica para Fastfetch/Neofetch
if apt-cache show fastfetch >/dev/null 2>&1; then 
    FETCH_PKG="fastfetch"
else 
    FETCH_PKG="neofetch"
fi
log " [DETECTOR] Usando $FETCH_PKG para resumen de sistema en la terminal."

ejecutar apt-get install -y ufw clamav clamav-freshclam net-tools mokutil
ejecutar apt-get install -y bluetooth bluez libspa-0.2-bluetooth
ejecutar apt-get install -y meld maven tree pdftk remmina rsync tmux psmisc zip unzip p7zip-full ntfs-3g exfatprogs gvfs-backends mtp-tools libimobiledevice-utils ifuse git git-lfs build-essential dkms transmission btop $FETCH_PKG
ejecutar apt-get install -y ffmpeg sox twolame vorbis-tools lame faad unrar ttf-mscorefonts-installer libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-vaapi libdvd-pkg

separador
log "[6/8] SELECCIÓN INTERACTIVA DE SOFTWARE..."
CHOICES=$(whiptail --title "Selección de Software Opcional" --checklist \
"Selecciona con ESPACIO, confirma con ENTER:\n(Soporte móvil y códecs base ya instalados)" 20 75 8 \
"multimedia_suite" "Instalar Reproductor y Editor ($OPT_PLAYER + $OPT_EDITOR)" ON \
"obs-studio" "Grabación y Streaming de pantalla" OFF \
"gimp" "Edición de imágenes avanzada" OFF \
"handbrake" "Conversión y compresión de video" OFF \
"gnome-boxes" "Gestor de máquinas virtuales" OFF \
3>&1 1>&2 2>&3)

CHOICES=$(echo $CHOICES | tr -d '"')

if [ ! -z "$CHOICES" ]; then
    log " Procesando selección de software..."
    export DEBIAN_FRONTEND=dialog
    
    if echo "$CHOICES" | grep -q "multimedia_suite"; then
        CHOICES=$(echo "$CHOICES" | sed "s/multimedia_suite/$OPT_PLAYER $OPT_EDITOR/")
        log " [OPT] Desplegando suite multimedia nativa: $OPT_PLAYER y $OPT_EDITOR"
    fi
    
    apt-get install -y $CHOICES
    export DEBIAN_FRONTEND=noninteractive
else
    log " [AVISO] No se seleccionó ningún software opcional."
fi

separador
log "[7/8] Configurando Flatpak e Integración Gráfica..."
ejecutar apt-get install -y flatpak
if [ "$HAS_GNOME" = true ]; then
    ejecutar apt-get install -y gnome-software-plugin-flatpak
elif [ "$HAS_KDE" = true ]; then
    ejecutar apt-get install -y plasma-discover-backend-flatpak
fi
ejecutar flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

separador
log "[8/8] Seguridad y Limpieza Final..."
ejecutar ufw default deny incoming
ejecutar ufw default allow outgoing
ejecutar ufw enable

ejecutar systemctl stop clamav-freshclam
ejecutar freshclam
ejecutar systemctl enable clamav-freshclam && ejecutar systemctl start clamav-freshclam

ejecutar dpkg-reconfigure libdvd-pkg
echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
ejecutar sysctl -p /etc/sysctl.d/99-swappiness.conf

ejecutar apt-get autoclean -y
ejecutar apt-get autoremove -y

separador
log "   ¡PROCESO COMPLETADO!"
log "   SE RECOMIENDA REINICIAR EL EQUIPO."
separador