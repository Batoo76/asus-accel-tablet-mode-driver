#!/bin/bash
# Run driver in debug mode with verbose logging

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default values
LAYOUT="default"
LOG_LEVEL="DEBUG"
USE_SUDO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--layout)
            LAYOUT="$2"
            shift 2
            ;;
        -s|--sudo)
            USE_SUDO="sudo -E"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -l, --layout LAYOUT    Layout name (default: default)"
            echo "  -s, --sudo             Run with sudo"
            echo "  -h, --help             Show this help"
            echo ""
            echo "Environment variables:"
            echo "  LOG=DEBUG              Set log level (INFO, DEBUG, ERROR)"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ ! -f "asus_accel_driver.py" ]; then
    echo "Error: Driver script not found: asus_accel_driver.py"
    exit 1
fi

# Check if layout exists
if [ ! -f "conf/${LAYOUT}.py" ]; then
    echo "Error: Layout file not found: conf/${LAYOUT}.py"
    echo "Available layouts:"
    ls -1 conf/*.py 2>/dev/null | sed 's|conf/||;s|\.py||' | sed 's/^/  - /' || echo "  (none found)"
    exit 1
fi

echo "=========================================="
echo "ASUS Accel Tablet Mode Driver - Debug Mode"
echo "=========================================="
echo ""
echo "Layout: $LAYOUT"
echo "Log Level: $LOG_LEVEL"
echo ""

echo "Starting driver in debug mode..."
echo "Press Ctrl+C to stop"
echo ""
echo "Logs will appear in:"
echo "  - Console output (stderr)"
echo "  - System log: journalctl -f | grep 'Asus Accel Tablet Mode Driver'"
echo ""

# Set environment variables for debugging
export LOG="$LOG_LEVEL"

# Run the driver
$USE_SUDO python3 asus_accel_driver.py "$LAYOUT"

