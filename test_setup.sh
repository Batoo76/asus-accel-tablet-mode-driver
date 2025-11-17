#!/bin/bash
# Test environment setup script for ASUS Accel Tablet Mode Driver

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "ASUS Accel Tablet Mode Driver - Test Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${YELLOW}Warning: Running as root. Some checks may not work correctly.${NC}"
   echo ""
fi

# Function to check command availability
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
}

# Function to check file/directory permissions
check_permissions() {
    local path="$1"
    local required="$2"
    if [ -e "$path" ]; then
        if [ -$required "$path" ]; then
            echo -e "${GREEN}✓${NC} $path is accessible ($required)"
            return 0
        else
            echo -e "${RED}✗${NC} $path exists but not accessible ($required)"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} $path does not exist"
        return 1
    fi
}

echo "1. Checking Python dependencies..."
echo "-----------------------------------"
MISSING_DEPS=0

check_command python3 || MISSING_DEPS=1

# Check for Python packages
echo ""
echo "Checking for required Python packages..."
if python3 -c "import libevdev" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} python-libevdev"
else
    echo -e "${RED}✗${NC} python-libevdev missing (install: pip3 install python-libevdev)"
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo -e "${RED}Missing required dependencies!${NC}"
    echo "Install with:"
    echo "  Debian/Ubuntu: sudo apt-get install python3-libevdev"
    echo "  Arch: sudo pacman -S python-libevdev"
    echo "  Or: pip3 install python-libevdev"
    exit 1
fi

echo ""
echo "2. Checking system permissions..."
echo "-----------------------------------"

# Check user groups
echo "Checking user groups..."
if groups | grep -q "\binput\b"; then
    echo -e "${GREEN}✓${NC} User is in 'input' group"
else
    echo -e "${YELLOW}⚠${NC} User is NOT in 'input' group (may need: sudo usermod -a -G input \$USER)"
fi

if groups | grep -q "\buinput\b"; then
    echo -e "${GREEN}✓${NC} User is in 'uinput' group"
else
    echo -e "${YELLOW}⚠${NC} User is NOT in 'uinput' group (may need: sudo usermod -a -G uinput \$USER)"
fi

echo ""
echo "3. Checking kernel modules..."
echo "-----------------------------------"
if lsmod | grep -q "^uinput"; then
    echo -e "${GREEN}✓${NC} uinput module is loaded"
else
    echo -e "${YELLOW}⚠${NC} uinput module not loaded (may need: sudo modprobe uinput)"
fi

echo ""
echo "4. Checking device access..."
echo "-----------------------------------"
check_permissions "/dev/uinput" "r" || echo "  Note: May need udev rules or run with sudo"

# Check for udevadm
if command -v udevadm >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} udevadm is available"
else
    echo -e "${RED}✗${NC} udevadm not found (required for accelerometer detection)"
    MISSING_DEPS=1
fi

echo ""
echo "5. Checking for accelerometer sensor..."
echo "-----------------------------------"
if command -v udevadm >/dev/null 2>&1; then
    if udevadm info --export-db 2>/dev/null | grep -q "accel"; then
        echo -e "${GREEN}✓${NC} Found accelerometer sensor in udev database"
        echo "  Accelerometer devices:"
        udevadm info --export-db 2>/dev/null | grep -B 2 -A 5 "accel" | grep -E "P:|N:|E: DEVNAME=" | head -10
    else
        echo -e "${YELLOW}⚠${NC} No accelerometer sensor detected in udev database"
        echo "  This is normal if you don't have an accelerometer or it's not detected"
    fi
else
    echo -e "${YELLOW}⚠${NC} Cannot check accelerometer (udevadm not available)"
fi

# Check for IIO devices
if [ -d "/sys/bus/iio/devices" ]; then
    IIO_COUNT=$(find /sys/bus/iio/devices -name "iio:device*" -type d 2>/dev/null | wc -l)
    if [ "$IIO_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Found $IIO_COUNT IIO device(s)"
        find /sys/bus/iio/devices -name "iio:device*" -type d 2>/dev/null | head -3
    else
        echo -e "${YELLOW}⚠${NC} No IIO devices found"
    fi
else
    echo -e "${YELLOW}⚠${NC} IIO subsystem not available"
fi

echo ""
echo "6. Checking driver files..."
echo "-----------------------------------"
if [ -f "asus_accel_driver.py" ]; then
    echo -e "${GREEN}✓${NC} Driver script found: asus_accel_driver.py"
    if [ -x "asus_accel_driver.py" ]; then
        echo -e "${GREEN}✓${NC} Driver script is executable"
    else
        echo -e "${YELLOW}⚠${NC} Driver script not executable (run: chmod +x asus_accel_driver.py)"
    fi
else
    echo -e "${RED}✗${NC} Driver script not found: asus_accel_driver.py"
    exit 1
fi

if [ -d "conf" ]; then
    echo -e "${GREEN}✓${NC} Configuration directory found: conf/"
    if [ -f "conf/default.py" ]; then
        echo -e "${GREEN}✓${NC} Default layout found: conf/default.py"
    else
        echo -e "${YELLOW}⚠${NC} Default layout not found: conf/default.py"
    fi
else
    echo -e "${RED}✗${NC} Configuration directory not found: conf/"
    exit 1
fi

echo ""
echo "7. Creating test directories..."
echo "-----------------------------------"
mkdir -p test/logs
echo -e "${GREEN}✓${NC} Test directories created"

echo ""
echo "=========================================="
echo -e "${GREEN}Test environment setup complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review the warnings above and fix any issues"
echo "  2. Run: ./test_accel_detection.sh (to test accelerometer detection)"
echo "  3. Run: ./debug_driver.sh (to run driver in debug mode)"
echo "  4. Check: docs/DEBUGGING.md (for debugging guide)"
echo ""

