#!/bin/bash
# Monitor input events while driver is running

set -e

echo "=========================================="
echo "ASUS Accel Tablet Mode Driver - Event Monitor"
echo "=========================================="
echo ""
echo "This script helps monitor input events while the driver is running."
echo ""

# Check for evtest
if ! command -v evtest >/dev/null 2>&1; then
    echo "Error: evtest not installed"
    echo "Install with: sudo apt-get install evtest"
    exit 1
fi

echo "Available input devices:"
echo "-----------------------------------"
evtest --list-devices 2>/dev/null | grep -E "Asus|Tablet|accel" || echo "No ASUS devices found yet"

echo ""
echo "To monitor events:"
echo "  1. Start the driver in another terminal:"
echo "     ./debug_driver.sh"
echo ""
echo "  2. Then run this to find the uinput device:"
echo "     evtest"
echo ""
echo "  3. Or monitor all events:"
echo "     sudo libinput debug-events"
echo ""

# Try to find the uinput device
if [ -d /sys/class/input ]; then
    echo "Looking for uinput devices..."
    for dev in /sys/class/input/event*/device/name; do
        if [ -f "$dev" ]; then
            name=$(cat "$dev" 2>/dev/null)
            if echo "$name" | grep -qi "asus\|tablet\|accel"; then
                event_num=$(echo "$dev" | sed 's|/sys/class/input/event\([0-9]*\)/.*|\1|')
                echo "  Found: /dev/input/event$event_num - $name"
            fi
        fi
    done
fi

echo ""
echo "To test tablet mode events manually:"
echo "  # Monitor with libinput"
echo "  sudo libinput debug-events | grep -i tablet"
echo ""
echo "  # Monitor with acpi_listen (if available)"
echo "  sudo acpi_listen"
echo ""
echo "  # Monitor with evtest"
echo "  sudo evtest"
echo "  # Select the 'Asus WMI accel tablet mode' device"
echo ""

