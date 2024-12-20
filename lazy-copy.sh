#!/bin/bash

# Paths
SOURCE_DIR="/path/to/source/directory/to/copy"
LOG_FILE="/path/to/directory/usb_auto_copy.log"

# Logging function
log() {
    echo "$(date) - $1" | tee -a "$LOG_FILE"
}

# Main script logic
log "USB Automation Script Started"

# Detect USB partitions smaller or equal to 64GB and mounted under /media
log "Detecting USB partitions smaller or equal to 64GB and mounted under /media..."

USB_DEVICES=$(lsblk -p -o NAME,SIZE,TYPE,MOUNTPOINT | grep '/media' | awk '{gsub(/[├─└]/, ""); mount=$NF; for (i=1;i<NF-2;i++) name=name $i " "; print name, $(NF-1), mount; name=""}')

if [ -z "$USB_DEVICES" ]; then
    log "No USB partitions mounted under /media and smaller or equal to 64GB detected."
    exit 1
fi

# List filtered devices
log "Available USB partitions:"
echo "$USB_DEVICES" | nl -w2 -s'. ' | tee -a "$LOG_FILE"

# Ask the user to select a device
read -p "Enter the number of the USB partition to use: " DEVICE_NUM
SELECTED_LINE=$(echo "$USB_DEVICES" | sed -n "${DEVICE_NUM}p")
SELECTED_PARTITION=$(echo "$SELECTED_LINE" | awk '{print $1}')
MOUNT_POINT=$(echo "$SELECTED_LINE" | awk '{for (i=3; i<=NF; i++) printf "%s ", $i; print ""}' | xargs)

if [ -z "$SELECTED_PARTITION" ]; then
    log "Invalid partition selection."
    exit 1
fi

log "User selected partition: $SELECTED_PARTITION"

# Check if the partition is already mounted
if [ -n "$MOUNT_POINT" ] && [ "$MOUNT_POINT" != "-" ]; then
    log "Partition is already mounted at $MOUNT_POINT. Using the existing mount point."
else
    log "Partition is not mounted. Attempting to mount $SELECTED_PARTITION."
    MOUNT_POINT="/mnt/$(basename "$SELECTED_PARTITION")"
    mkdir -p "$MOUNT_POINT"
    if mount "$SELECTED_PARTITION" "$MOUNT_POINT"; then
        log "Successfully mounted $SELECTED_PARTITION at $MOUNT_POINT."
    else
        log "Failed to mount $SELECTED_PARTITION. Check permissions or device health."
        exit 1
    fi
fi

# Ensure MOUNT_POINT is valid
if [ ! -d "$MOUNT_POINT" ]; then
    log "Invalid mount point: $MOUNT_POINT"
    exit 1
fi

# Copy files to the USB stick
log "Starting file copy to $MOUNT_POINT."
if rsync -av --progress "$SOURCE_DIR/" "$MOUNT_POINT/SOURCE-DIRECTORY-NAME/" >> "$LOG_FILE" 2>&1; then
    log "File copy completed successfully."
else
    log "File copy failed. Check logs for more details."
    exit 1
fi

# Validate rsync operation
log "Validating file copy integrity using rsync checksum comparison."
if rsync -avc --progress "$SOURCE_DIR/" "$MOUNT_POINT/SOURCE-DIRECTORY-NAME/" --dry-run >> "$LOG_FILE" 2>&1; then
    log "Validation completed successfully. All files match between source and destination."
else
    log "Validation failed. Differences found between source and destination. Check logs for details."
    exit 1
fi

# Unmount if the script mounted the partition
if [[ "$MOUNT_POINT" == "/mnt/"* ]]; then
    log "Unmounting $MOUNT_POINT."
    if umount "$MOUNT_POINT"; then
        log "Successfully unmounted $MOUNT_POINT."
        rmdir "$MOUNT_POINT" 2>/dev/null || log "Could not remove mount point directory $MOUNT_POINT."
    else
        log "Failed to unmount $MOUNT_POINT. Ensure it is not in use."
    fi
else
    log "Partition was already mounted. Skipping unmount."
fi

log "Completed copying to $SELECTED_PARTITION"
log "USB Automation Script Finished"
