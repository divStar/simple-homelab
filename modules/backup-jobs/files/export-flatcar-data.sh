#!/bin/bash
set -e

EXPORT_DATE=$(date +%Y%m%d-%H%M%S)
VM_ID="800"
SOURCE_DIR="/mnt/storage/images/$VM_ID"
EXPORT_DIR="/mnt/temp/import"

echo "Starting export at $EXPORT_DATE..."

# Export Docker disk (disk-2)
echo "Exporting Docker disk..."
qemu-img convert -O qcow2 -p \
  "$SOURCE_DIR/vm-$VM_ID-disk-0.qcow2" \
  "$EXPORT_DIR/flatcar-docker.qcow2"

# Export Data disk (disk-3)
echo "Exporting Data disk..."
qemu-img convert -O qcow2 -p \
  "$SOURCE_DIR/vm-$VM_ID-disk-1.qcow2" \
  "$EXPORT_DIR/flatcar-data.qcow2"

echo "Export complete!"
echo "Docker disk size: $(du -h $EXPORT_DIR/flatcar-docker.qcow2 | cut -f1)"
echo "Data disk size: $(du -h $EXPORT_DIR/flatcar-data.qcow2 | cut -f1)"
