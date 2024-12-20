# Lazy Copy

>*Because wasting time on automation feels way more productive.*

This project provides a Bash script to automate the detection, mounting, and file transfer process for USB devices. It includes logging, partition selection, and data validation.

---

## Features

- **USB Partition Detection**: Automatically detects USB partitions mounted under `/media` and filters those smaller or equal to 64GB.
- **Interactive Partition Selection**: Allows users to select a partition for file operations.
- **File Copy and Validation**: Copies files using `rsync` and validates the copy via checksum comparison.
- **Automated Mounting and Unmounting**: Handles unmounted partitions and cleans up temporary mount points.
- **Comprehensive Logging**: Logs all key actions with timestamps for better debugging.

---

## Prerequisites

Ensure the following are installed on your system:
- `bash` (default shell on most Linux systems)
- `rsync` for file copying and validation
- `lsblk` for device detection

---

## Installation

1. Clone this repository or copy the script to your local system.
   ```bash
   git clone https://github.com/joncvn/lazy-copy
   cd lazy-copy
   ```

2. Make the script executable:
   ```bash
   chmod +x lazy-copy.sh
   ```

3. Update the paths in the script for `SOURCE_DIR` and `LOG_FILE` to match your setup:
   ```bash
   SOURCE_DIR="/path/to/source/directory/to/copy"
   LOG_FILE="/path/to/directory/usb_auto_copy.log"
   ```

---

## Usage

Run the script:
```bash
./lazy-copy.sh
```

### Steps:
1. **USB Detection**:
   - The script detects all USB partitions mounted under `/media` and smaller or equal to 64GB.
   - It lists available USB partitions for user selection.

2. **Partition Selection**:
   - Select a partition by entering the corresponding number.

3. **File Copy**:
   - Files from `SOURCE_DIR` are copied to the selected USB partition.

4. **Validation**:
   - File integrity is validated using `rsync` checksum comparison.

5. **Unmounting**:
   - Temporary mount points are cleaned up after the script completes.

---

## Logs

Logs are saved to the specified log file (default: `/path/to/directory/usb_auto_copy.log`). Logs include:
- USB detection results
- Selected partition details
- File copy progress
- Validation results

---

## Troubleshooting

- **No USB Detected**:
  - Ensure your USB device is mounted under `/media`.
  - Verify that the partition size is 64GB or smaller.

- **Mounting Issues**:
  - Check if you have the necessary permissions to mount the USB device.
  - Verify the health of the USB device.

- **File Copy Errors**:
  - Ensure `rsync` is installed and accessible.
  - Check for sufficient space on the USB partition.

---

## Contributing

Feel free to open issues or submit pull requests to improve the script. Contributions are welcome!

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
