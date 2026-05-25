#!/bin/bash

# =======================================================
#   Setup Inicial y Modular para Debian 12 / 13
#   Autor original: Daniel Gonzalez
#   Ver. 2.4
# =======================================================

if [ "$EUID" -ne 0 ]; then
  echo "Error: Este script debe ejecutarse como root. Usa: sudo ./setup_debian.sh"
  exit 1
fi

# Definición de Colores
COLOR_SEP='\033[1;36m' 
NC='\033[0m'          

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
    echo -e "${COLOR_SEP}\n================================================================================${NC}"
}

# DETECCIÓN ENTORNO DE ESCRITORIO 
DE_TYPE="UNKNOWN"
DE_NAME="Desconocido/Sin entorno"
HAS_GNOME=false
HAS_KDE=false

if dpkg -l | grep -q "plasma-workspace"; then
    DE_TYPE="QT"
    DE_NAME="KDE Plasma"
    HAS_KDE=true
elif dpkg -l | grep -q "lxqt-session"; then
    DE_TYPE="QT" 
    DE_NAME="LXQt"
elif dpkg -l | grep -q "gnome-shell"; then
    DE_TYPE="GTK"
    DE_NAME="GNOME"
    HAS_GNOME=true
elif dpkg -l | grep -q "cinnamon-common"; then
    DE_TYPE="GTK"
    DE_NAME="Cinnamon"
elif dpkg -l | grep -q "mate-desktop"; then
    DE_TYPE="GTK"
    DE_NAME="MATE"
elif dpkg -l | grep -q "xfce4-session"; then
    DE_TYPE="LIGHT"
    DE_NAME="XFCE"
elif dpkg -l | grep -q "lxde"; then
    DE_TYPE="LIGHT"
    DE_NAME="LXDE"
fi

log " [DETECTOR] Entorno de escritorio detectado: $DE_NAME (Familia: $DE_TYPE)"

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
else
    log " [OK] Conexión a internet confirmada."
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
    log " [DETECTOR] Procesador Intel detectado. Instalando intel-microcode..."
    ejecutar apt-get install -y intel-microcode
elif [[ "$CPU_VENDOR" == *"AuthenticAMD"* ]]; then
    log " [DETECTOR] Procesador AMD detectado. Instalando amd64-microcode..."
    ejecutar apt-get install -y amd64-microcode
else
    log " [DETECTOR] Procesador no identificado ($CPU_VENDOR). Omitiendo microcódigos."
fi

separador
log "[3/8] Analizando hardware (GPU)..."
GPU_INFO=$(lspci | grep -i vga)
if echo "$GPU_INFO" | grep -qi "intel"; then
    log " [DETECTOR] Gráficos Intel detectados. Instalando drivers VA-API..."
    ejecutar apt-get install -y intel-media-va-driver-non-free vainfo
elif echo "$GPU_INFO" | grep -qi "amd\|radeon"; then
    log " [DETECTOR] Gráficos AMD/Radeon detectados. Instalando firmware y Mesa..."
    ejecutar apt-get install -y firmware-amd-graphics mesa-va-drivers mesa-vdpau-drivers vainfo
elif echo "$GPU_INFO" | grep -qi "nvidia"; then
    log " [DETECTOR] Gráficos Nvidia detectados. Instalando driver privativo..."
    ejecutar apt-get install -y nvidia-driver firmware-misc-nonfree
else
    log " [DETECTOR] Dispositivo gráfico no identificado o genérico."
fi

separador
log "[4/8] Analizando Chasis y Gestión de Energía..."
CHASSIS=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)
if [[ "$CHASSIS" =~ ^(8|9|10|11|14|31|32)$ ]]; then
    log " [DETECTOR] Chasis de portátil (Laptop) detectado."
    if [ "$HAS_KDE" = true ] || [ "$HAS_GNOME" = true ]; then
        log " [AVISO] Entorno $DE_NAME en uso. Omitiendo TLP por conflictos de energía nativos."
    else
        log " [OPT] Instalando TLP para optimizar batería en este portátil..."
        ejecutar apt-get install -y tlp tlp-rdw
        systemctl enable tlp && systemctl start tlp
    fi
else
    log " [DETECTOR] Chasis de PC de escritorio/Servidor detectado. Omitiendo TLP."
fi

separador
log "[5/8] Instalando Software Base (Indispensable)..."

# Lógica para Fastfetch/Neofetch
if apt-cache show fastfetch >/dev/null 2>&1; then 
    FETCH_PKG="fastfetch"
    log " [DETECTOR] fastfetch disponible en repositorios."
else 
    FETCH_PKG="neofetch"
    log " [DETECTOR] fastfetch no disponible. Usando neofetch como alternativa."
fi

log " [OPT] Desplegando herramientas de sistema, conectividad móvil y códecs base..."

# Paquetes esenciales
ejecutar apt-get install -y ufw mokutil timeshift
ejecutar apt-get install -y bluetooth bluez libspa-0.2-bluetooth
ejecutar apt-get install -y tree rsync psmisc zip unzip p7zip-full ntfs-3g exfatprogs gvfs-backends mtp-tools libimobiledevice-utils ifuse $FETCH_PKG
ejecutar apt-get install -y ffmpeg sox twolame vorbis-tools lame faad unrar ttf-mscorefonts-installer libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-vaapi libdvd-pkg

separador
log "[6/8] SELECCIÓN INTERACTIVA DE SOFTWARE OPCIONAL..."

# Ventana interactiva para sofware adicional
CHOICES=$(whiptail --title "Personalización del Sistema" --checklist \
"Selecciona las herramientas extras que deseas (ESPACIO para marcar, ENTER para confirmar):\n(Red, móviles, archivos comprimidos y códecs ya instalados)" 22 80 12 \
"video_player" "Reproductor de Video nativo ($OPT_PLAYER)" ON \
"video_editor" "Editor de Video nativo ($OPT_EDITOR)" ON \
"dev_tools" "Herramientas Desarrollo (Git, Compiladores, Meld)" OFF \
"sysadmin" "Herramientas Sysadmin (Remmina, Tmux, Btop, Net-tools)" OFF \
"antivirus" "Seguridad (ClamAV - *Consume recursos en 2do plano*)" OFF \
"torrent" "Cliente BitTorrent (Transmission)" OFF \
"obs-studio" "Grabación y Streaming de pantalla" OFF \
"gimp" "Edición de imágenes avanzada" OFF \
"handbrake" "Conversión y compresión de video" OFF \
"gnome-boxes" "Gestor de máquinas virtuales" OFF \
3>&1 1>&2 2>&3)

CHOICES=$(echo $CHOICES | tr -d '"')

INSTALL_PKGS=""
INSTALL_CLAMAV=false

if [ ! -z "$CHOICES" ]; then
    log " Procesando selección del usuario..."
    export DEBIAN_FRONTEND=dialog
    
    # Procesar opciones 
    for CHOICE in $CHOICES; do
        case "$CHOICE" in
            video_player) 
                INSTALL_PKGS="$INSTALL_PKGS $OPT_PLAYER"
                log " [OPT] Agregado a la cola: $OPT_PLAYER"
                ;;
            video_editor) 
                INSTALL_PKGS="$INSTALL_PKGS $OPT_EDITOR"
                log " [OPT] Agregado a la cola: $OPT_EDITOR"
                ;;
            dev_tools) 
                INSTALL_PKGS="$INSTALL_PKGS build-essential dkms git git-lfs maven meld"
                log " [OPT] Agregado a la cola: Entorno de Desarrollo (Git, Compiladores)"
                ;;
            sysadmin) 
                INSTALL_PKGS="$INSTALL_PKGS remmina tmux net-tools btop pdftk"
                log " [OPT] Agregado a la cola: Herramientas de Administración de Sistemas"
                ;;
            antivirus) 
                INSTALL_PKGS="$INSTALL_PKGS clamav clamav-freshclam"
                INSTALL_CLAMAV=true
                log " [OPT] Agregado a la cola: ClamAV Antivirus"
                ;;
            torrent) 
                INSTALL_PKGS="$INSTALL_PKGS transmission"
                log " [OPT] Agregado a la cola: Transmission"
                ;;
            *) 
                # Paquetes que se llaman igual que la opción 
                INSTALL_PKGS="$INSTALL_PKGS $CHOICE"
                log " [OPT] Agregado a la cola: $CHOICE"
                ;;
        esac
    done
    
    # Ejecutar instalación de todo lo seleccionado
    ejecutar apt-get install -y $INSTALL_PKGS
    export DEBIAN_FRONTEND=noninteractive
else
    log " [AVISO] El usuario decidió no instalar ningún software extra."
fi

separador
log "[7/8] Configurando Flatpak e Integración Gráfica..."
ejecutar apt-get install -y flatpak
if [ "$HAS_GNOME" = true ]; then
    log " [DETECTOR] Integrando Flatpak con GNOME Software..."
    ejecutar apt-get install -y gnome-software-plugin-flatpak
elif [ "$HAS_KDE" = true ]; then
    log " [DETECTOR] Integrando Flatpak con KDE Discover..."
    ejecutar apt-get install -y plasma-discover-backend-flatpak
else
    log " [DETECTOR] Entorno gráfico sin soporte oficial unificado. Se usará Flatpak por terminal."
fi
ejecutar flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

separador
log "[8/8] Seguridad y Limpieza Final..."

log " [OPT] Configurando firewall (UFW)..."
ejecutar ufw default deny incoming
ejecutar ufw default allow outgoing
ejecutar ufw enable

if [ "$INSTALL_CLAMAV" = true ]; then
    log " [OPT] Configurando e iniciando ClamAV..."
    ejecutar systemctl stop clamav-freshclam
    ejecutar freshclam
    ejecutar systemctl enable clamav-freshclam && ejecutar systemctl start clamav-freshclam
fi

log " [OPT] Aplicando configuraciones de Swap y DVD..."
ejecutar dpkg-reconfigure libdvd-pkg
echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
ejecutar sysctl -p /etc/sysctl.d/99-swappiness.conf

log " [OPT] Limpiando dependencias huérfanas y caché..."
ejecutar apt-get autoclean -y
ejecutar apt-get autoremove -y

separador
log "   ¡PROCESO COMPLETADO EXITOSAMENTE!"
log "   SE RECOMIENDA REINICIAR EL EQUIPO."
separador