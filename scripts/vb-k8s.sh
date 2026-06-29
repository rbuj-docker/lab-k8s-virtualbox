#!/bin/bash

VM=""
ISO=""
DISK=""
DISK_SIZE=0
RAM=0
CPUS=0
USER_NAME=""
USER_PASSWORD=""
HOSTNAME=""
LOCAL_FORWARD_PORT=0

# funció que mostra l'ús del script
usage() {
  echo "Ús: $0 --vm <nom_vm> --iso <ruta_iso> --disk <ruta_disc> --disk-size <mida_disc_MB> --ram <memoria_MB> --cpus <num_cpus> --user-name <nom_usuari> --user-password <contrasenya> --hostname <nom_host> --local-forward-port <port_local>"
}

# funció d'error que mostra l'ús i surt del script
error_args() {
  usage
  exit 1
}


# Parceja els arguments de la línia de comandes
while [[ $# -gt 0 ]]; do
  case $1 in
    --vm) VM="$2"; shift 2 ;;
    --iso) ISO="$2"; shift 2 ;;
    --disk) DISK="$2"; shift 2 ;;
    --disk-size) DISK_SIZE="$2"; shift 2 ;;
    --ram) RAM="$2"; shift 2 ;;
    --cpus) CPUS="$2"; shift 2 ;;
    --user-name) USER_NAME="$2"; shift 2 ;;
    --user-password) USER_PASSWORD="$2"; shift 2 ;;
    --hostname) HOSTNAME="$2"; shift 2 ;;
    --local-forward-port) LOCAL_FORWARD_PORT="$2"; shift 2 ;;
    *) echo "Argument desconegut: $1"; exit 1 ;;
  esac
done

# Si no s'han introduit tots els arguments necessaris, mostra un missatge d'error i surt
if [[ -z "$VM" ]]; then
  echo "Error: Falta l'argument --vm"
  error_args
fi

if [[ -z "$ISO" ]]; then
  echo "Error: Falta l'argument --iso"
  error_args
fi

if [[ -z "$DISK" ]]; then
  echo "Error: Falta l'argument --disk"
  error_args
fi

if [[ -z "$DISK_SIZE" ]]; then
  echo "Error: Falta l'argument --disk-size"
  error_args
fi

if [[ -z "$RAM" ]]; then
  echo "Error: Falta l'argument --ram"
  error_args
fi

if [[ -z "$CPUS" ]]; then
  echo "Error: Falta l'argument --cpus"
  error_args
fi

if [[ -z "$USER_NAME" ]]; then
  echo "Error: Falta l'argument --user-name"
  error_args
fi

if [[ -z "$USER_PASSWORD" ]]; then
  echo "Error: Falta l'argument --user-password"
  error_args
fi

if [[ -z "$HOSTNAME" ]]; then
  echo "Error: Falta l'argument --hostname"
  error_args
fi

if [[ -z "$LOCAL_FORWARD_PORT" ]]; then
  echo "Error: Falta l'argument --local-forward-port"
  error_args
fi

# Neteja prèvia
VBoxManage unregistervm "$VM" --delete 2>/dev/null
VBoxManage closemedium disk "$DISK" --delete 2>/dev/null
rm -f "$DISK"

# Crear VM ARM64
VBoxManage createvm --name "$VM" --ostype Ubuntu_arm64 --register

# Configurar VM
VBoxManage modifyvm "$VM" \
  --memory $RAM \
  --cpus $CPUS \
  \
  --nic1 nat \
  --natpf1 "ssh,tcp,,$LOCAL_FORWARD_PORT,,22" \
  \
  --nic2 intnet \
  --intnet2 "k8s-int" \
  \
  --nat-network1 k8s-nat \
  --graphicscontroller vmsvga \
  --vram 32 \
  --accelerate3d off \
  --accelerate2dvideo off \
  --firmware efi

# Crear disc
VBoxManage createhd --filename "$DISK" --size $DISK_SIZE

# Controlador SATA
VBoxManage storagectl "$VM" --name "SATA" --add sata --controller IntelAhci

# Adjuntar disc i ISO
VBoxManage storageattach "$VM" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$DISK"
VBoxManage storageattach "$VM" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$ISO"

# Instal·lació desatesa ARM64
VBoxManage unattended install "$VM" \
  --iso="$ISO" \
  --user="$USER_NAME" \
  --password="$USER_PASSWORD" \
  --full-user-name="Student User" \
  --hostname="$HOSTNAME" \
  --locale="ca_ES" \
  --time-zone="Europe/Madrid" \
  --country="ES" \
  --install-additions \
  --post-install-command="sudo apt-get update && sudo apt-get install -y openssh-server && sudo systemctl enable ssh && sudo systemctl start ssh" \
  --start-vm=headless

echo "Esperant que la VM acabi la instal·lació i arrenqui..."
VBoxManage guestproperty wait "$VM" "/VirtualBox/GuestInfo/OS/LoggedInUsers"
echo "La VM ha acabat la instal·lació i ha arrencat correctament."