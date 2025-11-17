#!/bin/bash
# Test accelerometer detection without running the full driver

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "ASUS Accel Tablet Mode Driver - Accelerometer Detection Test"
echo "=========================================="
echo ""

echo "1. Checking udevadm accelerometer detection..."
echo "-----------------------------------"
if ! command -v udevadm >/dev/null 2>&1; then
    echo "Error: udevadm not found"
    exit 1
fi

echo "Searching for accelerometer in udev database..."
echo ""

# Show accelerometer detection process
accel_detected=0
accel_device_dir_path=""

while IFS= read -r line; do
    if [ "$accel_detected" -eq 0 ] && echo "$line" | grep -q "accel"; then
        accel_detected=1
        echo "Found 'accel' in udev output:"
        echo "  $line"
    fi
    
    if [ "$accel_detected" -eq 1 ]; then
        if echo "$line" | grep -q "^P: "; then
            accel_device_dir_path="/sys$(echo "$line" | awk '{print $2}')"
            accel_detected=2
            echo "  Device path: $accel_device_dir_path"
            break
        fi
    fi
done < <(udevadm info --export-db 2>/dev/null)

if [ "$accel_detected" -eq 2 ] && [ -n "$accel_device_dir_path" ]; then
    echo -e "\n✓ Accelerometer detected successfully!"
    echo "  Path: $accel_device_dir_path"
    
    # Check if accelerometer files exist
    echo ""
    echo "2. Checking accelerometer data files..."
    echo "-----------------------------------"
    for file in in_accel_x_raw in_accel_y_raw in_accel_z_raw; do
        if [ -f "$accel_device_dir_path/$file" ]; then
            echo -e "✓ $file exists"
            if [ -r "$accel_device_dir_path/$file" ]; then
                value=$(cat "$accel_device_dir_path/$file" 2>/dev/null || echo "N/A")
                echo "  Current value: $value"
            else
                echo "  (not readable - may need permissions)"
            fi
        else
            echo -e "✗ $file not found"
        fi
    done
    
    # Try to read current accelerometer values
    echo ""
    echo "3. Reading current accelerometer values..."
    echo "-----------------------------------"
    if [ -r "$accel_device_dir_path/in_accel_x_raw" ] && \
       [ -r "$accel_device_dir_path/in_accel_y_raw" ] && \
       [ -r "$accel_device_dir_path/in_accel_z_raw" ]; then
        x=$(cat "$accel_device_dir_path/in_accel_x_raw" 2>/dev/null || echo "N/A")
        y=$(cat "$accel_device_dir_path/in_accel_y_raw" 2>/dev/null || echo "N/A")
        z=$(cat "$accel_device_dir_path/in_accel_z_raw" 2>/dev/null || echo "N/A")
        echo "X: $x"
        echo "Y: $y"
        echo "Z: $z"
        
        # Check tablet mode criteria
        echo ""
        echo "4. Tablet mode detection criteria..."
        echo "-----------------------------------"
        echo "Criteria: x >= -5 and x <= 5, y >= -5 and y <= 5, z <= -9"
        if [ "$x" != "N/A" ] && [ "$y" != "N/A" ] && [ "$z" != "N/A" ]; then
            x_float=$(echo "$x" | awk '{print $1}')
            y_float=$(echo "$y" | awk '{print $1}')
            z_float=$(echo "$z" | awk '{print $1}')
            
            if (( $(echo "$x_float >= -5 && $x_float <= 5" | bc -l 2>/dev/null || echo "0") )) && \
               (( $(echo "$y_float >= -5 && $y_float <= 5" | bc -l 2>/dev/null || echo "0") )) && \
               (( $(echo "$z_float <= -9" | bc -l 2>/dev/null || echo "0") )); then
                echo "  Current state: TABLET MODE"
            else
                echo "  Current state: LAPTOP MODE"
            fi
        fi
    else
        echo "Cannot read accelerometer values (permission denied)"
        echo "  Try running with sudo or add user to appropriate groups"
    fi
else
    echo -e "\n✗ Accelerometer not detected"
    echo "  Detection code: $accel_detected"
    if [ -z "$accel_device_dir_path" ]; then
        echo "  Device path not found"
    fi
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check if accelerometer is present: ls /sys/bus/iio/devices/"
    echo "  2. Check udev database: udevadm info --export-db | grep -i accel"
    echo "  3. Check if IIO subsystem is loaded: lsmod | grep iio"
fi

echo ""
echo "5. Checking IIO devices..."
echo "-----------------------------------"
if [ -d "/sys/bus/iio/devices" ]; then
    echo "IIO devices found:"
    for dev in /sys/bus/iio/devices/iio:device*; do
        if [ -d "$dev" ]; then
            dev_name=$(basename "$dev")
            echo "  $dev_name"
            if [ -f "$dev/name" ]; then
                name=$(cat "$dev/name" 2>/dev/null || echo "unknown")
                echo "    Name: $name"
            fi
        fi
    done
else
    echo "No IIO devices directory found"
fi

echo ""
echo "=========================================="
echo "Accelerometer detection test complete"
echo "=========================================="

