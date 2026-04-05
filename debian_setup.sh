#!/bin/bash

# =======================================================
#   Setup Inicial para Debian 12 o superior
#   Autor original: Daniel Gonzalez
#   Modificado con validaciones, optimizaciones, logging y trazabilidad
#   Ver. 2.0 - 04/Abr/2026
# =======================================================

# 1. Verificar permisos de root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Este script debe ejecutarse como root. Usa: sudo ./debian_setup.sh"
  exit 1
fi

# =======================================================
#   SISTEMA DE LOGGING Y TRAZABILIDAD
# =======================================================
LOG_FILE="/var/log/setup_debian_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Redirigir salida estándar y de errores al archivo y a la pantalla
exec > >(tee -i "$LOG_FILE") 2>&1

# Función para mensajes informativos
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Función para imprimir el comando antes de ejecutarlo
ejecutar() {
    log "   $ $*"
    "$@"
}

log "======================================================="
log "   Iniciando Configuración Maestra..."
log "   El registro de esta instalación se guardará en: $LOG_FILE"
log "======================================================="

# 2. Validar conexión a Internet
log "[*] Verificando conexión a internet..."
if ! ping -c 1 google.com &> /dev/null; then
    log "Error: No hay red. Conéctate a internet y vuelve a intentarlo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
log "   $ echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections"
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

# 3. Configurar repositorios y Actualización Profunda
log ""
log "[1/9] Añadiendo repositorios contrib, non-free y non-free-firmware..."
ejecutar apt-get install -y software-properties-common pciutils curl wget dirmngr
ejecutar apt-add-repository contrib non-free non-free-firmware -y
ejecutar apt-get update -y
ejecutar apt-get full-upgrade -y

# 4. Detección de CPU
log ""
log "[2/9] Analizando hardware (CPU)..."
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
if [[ "$CPU_VENDOR" == *"GenuineIntel"* ]]; then
    log " ---> Procesador Intel detectado."
    ejecutar apt-get install -y intel-microcode
elif [[ "$CPU_VENDOR" == *"AuthenticAMD"* ]]; then
    log " ---> Procesador AMD detectado."
    ejecutar apt-get install -y amd64-microcode
fi

# 5. Detección de GPU
log ""
log "[3/9] Analizando hardware (GPU)..."
GPU_INFO=$(lspci | grep -i vga)
if echo "$GPU_INFO" | grep -qi "intel"; then
    log " ---> Gráficos Intel. Instalando VA-API..."
    ejecutar apt-get install -y intel-media-va-driver-non-free vainfo
fi
if echo "$GPU_INFO" | grep -qi "amd\|radeon"; then
    log " ---> Gráficos AMD. Instalando firmware y aceleración..."
    ejecutar apt-get install -y firmware-amd-graphics mesa-va-drivers mesa-vdpau-drivers vainfo
fi
if echo "$GPU_INFO" | grep -qi "nvidia"; then
    log " ---> Gráficos NVIDIA. Instalando driver privativo..."
    ejecutar apt-get install -y nvidia-driver firmware-misc-nonfree
fi

# 6. Detección PC vs Laptop
log ""
log "[4/9] Analizando tipo de chasis..."
CHASSIS=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)
if [[ "$CHASSIS" =~ ^(8|9|10|11|14|31|32)$ ]]; then
    log " ---> Laptop detectada. Instalando gestión de energía (TLP)..."
    ejecutar apt-get install -y tlp tlp-rdw
    ejecutar systemctl enable tlp
    ejecutar systemctl start tlp
else
    log " ---> PC de escritorio detectada. Omitiendo TLP."
fi

# 7. Detección de Discos
log ""
log "[5/9] Analizando almacenamiento..."
HAS_SSD=false
HAS_NVME=false

for disk in /sys/block/nvme*; do
    if [ -d "$disk" ]; then
        HAS_NVME=true
        HAS_SSD=true
        break
    fi
done

for rot in /sys/block/sd*/queue/rotational 2>/dev/null; do
    if [ -f "$rot" ] && [ "$(cat "$rot")" -eq 0 ]; then
        HAS_SSD=true
    fi
done

if [ "$HAS_NVME" = true ]; then
    log " ---> Unidad M.2 NVMe detectada."
    ejecutar apt-get install -y nvme-cli
fi

# 8. Instalación de Software General
log ""
log "[6/9] Instalando paquetería principal por categorías..."

log " ---> [Seguridad y Red]"
ejecutar apt-get install -y ufw clamav clamav-freshclam net-tools mokutil

log " ---> [Multimedia y Edición]"
ejecutar apt-get install -y obs-studio handbrake gimp kdenlive gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad ffmpeg sox twolame vorbis-tools lame faad unrar ttf-mscorefonts-installer

log " ---> [Herramientas y Archivos]"
ejecutar apt-get install -y meld pdftk remmina rsync tmux psmisc zip unzip p7zip-full ntfs-3g exfatprogs libimobiledevice-utils ifuse gvfs-backends

if apt-cache show fastfetch >/dev/null 2>&1; then
    FETCH_PKG="fastfetch"
    log " ---> [Sistema] Fastfetch detectado."
else
    FETCH_PKG="neofetch"
    log " ---> [Sistema] Fastfetch no disponible, retrocediendo a Neofetch."
fi

log " ---> [Desarrollo y Sistema]"
ejecutar apt-get install -y git git-lfs build-essential dkms maven nodejs npm tree btop $FETCH_PKG gnome-boxes

log " ---> [Bluetooth]"
ejecutar apt-get install -y bluetooth bluez bluez-tools rfkill libspa-0.2-bluetooth

# 9. Configuración de Spotify Oficial
log ""
log "[7/9] Configurando repositorio oficial e instalando Spotify..."
log "   $ curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg"
curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
log "   $ echo \"deb https://repository.spotify.com stable non-free\" | sudo tee /etc/apt/sources.list.d/spotify.list"
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
ejecutar apt-get update -y
ejecutar apt-get install -y spotify-client

# 10. Configuración de Flatpak y Entorno de Escritorio
log ""
log "[8/9] Configurando Flatpak según el Entorno de Escritorio..."
ejecutar apt-get install -y flatpak

DESKTOP_ENV=$(echo $XDG_CURRENT_DESKTOP)
if [ "$DESKTOP_ENV" == "GNOME" ]; then
    log " ---> GNOME detectado. Instalando plugin flathub para Gnome Software"
    ejecutar apt-get install -y gnome-software-plugin-flatpak
elif [ "$DESKTOP_ENV" == "KDE" ]; then
    log " ---> KDE Plasma detectado. Instalando plugin flathub para Discover"
    ejecutar apt-get install -y plasma-discover-backend-flatpak
else
    log " ---> Entorno $DESKTOP_ENV. No se requiere plugin específico."
fi

ejecutar flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 11. Configuraciones Finales, Seguridad y Limpieza
log ""
log "[9/9] Aplicando configuraciones finales y limpiando sistema..."

log " ---> Configurando Firewall (UFW)..."
ejecutar ufw default deny incoming
ejecutar ufw default allow outgoing
ejecutar ufw enable

log " ---> Configurando Antivirus (ClamAV)..."
ejecutar systemctl stop clamav-freshclam
ejecutar freshclam
ejecutar systemctl enable clamav-freshclam
ejecutar systemctl start clamav-freshclam

log " ---> Iniciando servicios de Bluetooth..."
ejecutar rfkill unblock bluetooth
ejecutar systemctl enable bluetooth
ejecutar systemctl start bluetooth

if [ "$HAS_SSD" = true ]; then
    log " ---> Habilitando TRIM periódico para el SSD..."
    ejecutar systemctl enable fstrim.timer
fi

log " ---> Optimizando memoria RAM (Swappiness a 10)..."
log "   $ echo \"vm.swappiness=10\" > /etc/sysctl.d/99-swappiness.conf"
echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
ejecutar sysctl -p /etc/sysctl.d/99-swappiness.conf

log " ---> Limpieza final de paquetes y caché..."
ejecutar apt-get autoclean -y
ejecutar apt-get autoremove -y

log ""
log "======================================================="
log "   ******** Tarea de Setup Finalizada ********"
log "   El registro completo está guardado en: $LOG_FILE"
log "   Por favor, reinicia tu equipo para aplicar los cambios."
log "======================================================="