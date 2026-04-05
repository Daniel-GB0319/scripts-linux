#!/bin/bash

# =======================================================
#   Setup Inicial para Debian 12 / 13
#   Autor original: Daniel Gonzalez
#   Ver. 2.1 - 04/Abr/2026
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

sub_separador() {
    echo -e "   ------------------------------------------------------------"
}

separador
log "   Iniciando Configuración Maestra..."
log "   Registro completo: $LOG_FILE"
separador

# 1. Validar conexión
log "[*] Verificando conexión a internet..."
if ! ping -c 1 google.com &> /dev/null; then
    log " [!] ERROR: No hay red. El script requiere internet para continuar."
    exit 1
else
    log " [OK] Conexión detectada correctamente."
fi

export DEBIAN_FRONTEND=noninteractive
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
# Pre-aceptar configuración de libdvd-pkg
echo libdvd-pkg libdvd-pkg/first-install note | debconf-set-selections

separador
log "[1/9] Validando Repositorios Contrib y Non-Free..."

HAS_CONTRIB=$(grep -rEi "^deb.*contrib" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null)
HAS_NONFREE=$(grep -rEi "^deb.*[[:space:]]non-free([[:space:]]|$)" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null)

if [ -z "$HAS_CONTRIB" ] || [ -z "$HAS_NONFREE" ]; then
    log " [!] ADVERTENCIA: Faltan repositorios esenciales ('contrib' o 'non-free')."
    log ""
    log "     POR FAVOR, REALICE LO SIGUIENTE:"
    log "     1. Ejecute en otra terminal: sudo apt edit-sources"
    log "     2. Asegúrese de que las líneas terminen en: main contrib non-free non-free-firmware"
    log "     3. Guarde los cambios y vuelva a ejecutar este script."
    separador
    exit 1
else
    log " [OK] Repositorios adicionales (contrib y non-free) detectados correctamente."
fi

ejecutar apt-get update -y
log "Instalando herramientas base críticas..."
ejecutar apt-get install -y curl wget gpg dirmngr pciutils
ejecutar apt-get full-upgrade -y

separador
log "[2/9] Analizando hardware (CPU)..."
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
if [[ "$CPU_VENDOR" == *"GenuineIntel"* ]]; then
    log " [DETECTOR] Procesador Intel detectado. Instalando microcódigo..."
    ejecutar apt-get install -y intel-microcode
elif [[ "$CPU_VENDOR" == *"AuthenticAMD"* ]]; then
    log " [DETECTOR] Procesador AMD detectado. Instalando microcódigo..."
    ejecutar apt-get install -y amd64-microcode
else
    log " [AVISO] CPU no reconocida. No se requiere microcódigo específico."
fi

separador
log "[3/9] Analizando hardware (GPU)..."
GPU_INFO=$(lspci | grep -i vga)
FOUND_GPU=false

if echo "$GPU_INFO" | grep -qi "intel"; then
    log " [DETECTOR] Gráficos Intel detectados. Instalando VA-API..."
    ejecutar apt-get install -y intel-media-va-driver-non-free vainfo
    FOUND_GPU=true
fi
if echo "$GPU_INFO" | grep -qi "amd\|radeon"; then
    log " [DETECTOR] Gráficos AMD detectados. Instalando firmware y aceleración..."
    ejecutar apt-get install -y firmware-amd-graphics mesa-va-drivers mesa-vdpau-drivers vainfo
    FOUND_GPU=true
fi
if echo "$GPU_INFO" | grep -qi "nvidia"; then
    log " [DETECTOR] Gráficos NVIDIA detectados. Instalando drivers privativos..."
    ejecutar apt-get install -y nvidia-driver firmware-misc-nonfree
    FOUND_GPU=true
fi

if [ "$FOUND_GPU" = false ]; then
    log " [AVISO] No se detectó GPU conocida. Se mantendrán drivers básicos."
fi

separador
log "[4/9] Analizando tipo de chasis (Laptop vs Desktop)..."
CHASSIS=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)
if [[ "$CHASSIS" =~ ^(8|9|10|11|14|31|32)$ ]]; then
    log " [DETECTOR] Hardware identificado como Portátil/Laptop."
    ejecutar apt-get install -y tlp tlp-rdw
    systemctl enable tlp && systemctl start tlp
else
    log " [DETECTOR] Hardware identificado como PC de Escritorio. Omitiendo gestión de batería."
fi

separador
log "[5/9] Analizando almacenamiento (SSD/NVMe)..."
HAS_SSD=false
if [ -d /sys/block/nvme0n1 ]; then
    log " [DETECTOR] Unidad M.2 NVMe detectada."
    ejecutar apt-get install -y nvme-cli
    HAS_SSD=true
fi

for rot in /sys/block/sd*/queue/rotational; do
    if [ -f "$rot" ] && [ "$(cat "$rot")" -eq 0 ]; then
        log " [DETECTOR] Disco de Estado Sólido (SSD) SATA detectado."
        HAS_SSD=true
        break
    fi
done

if [ "$HAS_SSD" = false ]; then
    log " [AVISO] No se detectaron SSDs. Se asume disco mecánico (HDD)."
fi

separador
log "[6/9] Instalación de Software General..."

sub_separador
log " ---> [Categoría: Seguridad y Red]"
ejecutar apt-get install -y ufw clamav clamav-freshclam net-tools mokutil

sub_separador
log " ---> [Categoría: Multimedia y Edición]"
ejecutar apt-get install -y obs-studio handbrake gimp kdenlive ffmpeg sox twolame \
                   vorbis-tools lame faad unrar ttf-mscorefonts-installer \
                   libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly \
                   gstreamer1.0-plugins-bad gstreamer1.0-plugins-good \
                   gstreamer1.0-vaapi libdvd-pkg mpv

sub_separador
log " ---> [Categoría: Herramientas y Archivos]"
ejecutar apt-get install -y meld pdftk remmina rsync tmux psmisc zip unzip p7zip-full ntfs-3g exfatprogs libimobiledevice-utils ifuse gvfs-backends

sub_separador
log " ---> [Categoría: Sistema y Desarrollo]"
if apt-cache show fastfetch >/dev/null 2>&1; then FETCH_PKG="fastfetch"; else FETCH_PKG="neofetch"; fi
log "      Usando $FETCH_PKG para resumen de hardware."
ejecutar apt-get install -y git git-lfs build-essential dkms maven nodejs npm tree btop $FETCH_PKG gnome-boxes

sub_separador
log " ---> [Categoría: Conectividad Bluetooth]"
ejecutar apt-get install -y bluetooth bluez bluez-tools rfkill libspa-0.2-bluetooth

separador
log "[7/9] Configurando Spotify Oficial..."
curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
ejecutar apt-get update -y
ejecutar apt-get install -y spotify-client

separador
log "[8/9] Configurando Flatpak e Integración Gráfica..."
ejecutar apt-get install -y flatpak
DESKTOP_ENV=$(echo $XDG_CURRENT_DESKTOP)
if [ "$DESKTOP_ENV" == "GNOME" ]; then
    log " [DETECTOR] GNOME detectado. Instalando plugin para GNOME Software."
    ejecutar apt-get install -y gnome-software-plugin-flatpak
elif [ "$DESKTOP_ENV" == "KDE" ]; then
    log " [DETECTOR] KDE Plasma detectado. Instalando plugin para Discover."
    ejecutar apt-get install -y plasma-discover-backend-flatpak
else
    log " [AVISO] Entorno '$DESKTOP_ENV' sin plugin de tienda específico."
fi
ejecutar flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

separador
log "[9/9] Seguridad, Optimización y Limpieza Final..."
ejecutar ufw default deny incoming
ejecutar ufw default allow outgoing
ejecutar ufw enable

log "Configurando servicios de mantenimiento..."
ejecutar systemctl stop clamav-freshclam
ejecutar freshclam
ejecutar systemctl enable clamav-freshclam && ejecutar systemctl start clamav-freshclam
ejecutar rfkill unblock bluetooth

log "Finalizando configuración de códecs de DVD..."
ejecutar dpkg-reconfigure libdvd-pkg

if [ "$HAS_SSD" = true ]; then
    log " [OPT] Habilitando TRIM semanal para SSD/NVMe."
    ejecutar systemctl enable fstrim.timer
fi

log "Optimizando uso de RAM (Swappiness)..."
echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
ejecutar sysctl -p /etc/sysctl.d/99-swappiness.conf

ejecutar apt-get autoclean -y
ejecutar apt-get autoremove -y

separador
log "   ¡PROCESO COMPLETADO!"
log "   Bitácora: $LOG_FILE"
log "   SE RECOMIENDA REINICIAR EL EQUIPO."
separador