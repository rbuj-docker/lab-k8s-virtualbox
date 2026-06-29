#!/bin/bash

VM="k8s-worker-01"
ISO="/Volumes/SanDisk/VMs/ubuntu-26.04-live-server-arm64.iso"
DISK="./k8s-worker-01.vdi"
DISK_SIZE=20000
RAM=4096
CPUS=2
USER_NAME="student"
USER_PASSWORD="k8s12345"
HOSTNAME="k8s-worker-01.laboratory.org"
LOCAL_FORWARD_PORT=2223

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
  