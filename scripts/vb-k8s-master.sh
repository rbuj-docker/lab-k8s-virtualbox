#!/bin/bash

VM="k8s-master"
ISO="/Volumes/SanDisk/VMs/ubuntu-26.04-live-server-arm64.iso"
DISK="./k8s-master.vdi"
DISK_SIZE=20000
RAM=4096
CPUS=2
USER_NAME="student"
USER_PASSWORD="k8s12345"
HOSTNAME="k8s-master.laboratory.org"
LOCAL_FORWARD_PORT=2222

./vb-k8s.sh --vm "$VM" \
  --iso "$ISO" \
  --disk "$DISK" \
  --disk-size "$DISK_SIZE" \
  --ram "$RAM" \
  --cpus "$CPUS" \
  --user-name "$USER_NAME" \
  --user-password "$USER_PASSWORD" \
  --hostname "$HOSTNAME" \
  --local-forward-port "$LOCAL_FORWARD_PORT"
  