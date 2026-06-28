#!/bin/bash

VM="k8s-master"
ISO="/Volumes/SanDisk/VMs/ubuntu-26.04-live-server-arm64.iso"
DISK="./k8s-master.vdi"
RAM=4096
CPUS=2

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
  --natpf1 "ssh,tcp,,2222,,22" \
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
VBoxManage createhd --filename "$DISK" --size 20000

# Controlador SATA
VBoxManage storagectl "$VM" --name "SATA" --add sata --controller IntelAhci

# Adjuntar disc i ISO
VBoxManage storageattach "$VM" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$DISK"
VBoxManage storageattach "$VM" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$ISO"

# Instal·lació desatesa ARM64
VBoxManage unattended install "$VM" \
  --iso="$ISO" \
  --user="student" \
  --password="k8s12345" \
  --full-user-name="Student User" \
  --hostname="k8s-master.laboratory.org" \
  --locale="ca_ES" \
  --time-zone="Europe/Madrid" \
  --country="ES" \
  --install-additions \
  --post-install-command="sudo apt-get update && sudo apt-get install -y openssh-server && sudo systemctl enable ssh && sudo systemctl start ssh" \
  --start-vm=headless
