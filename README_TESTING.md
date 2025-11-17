# Testing and Debugging - Quick Start

## Setup Test Environment

```bash
cd asus-accel-tablet-mode-driver
./test_setup.sh
```

This will:
- ✅ Check all dependencies
- ✅ Verify permissions
- ✅ Check accelerometer detection
- ✅ Create test directories

## Quick Tests

### 1. Test Accelerometer Detection
```bash
./test_accel_detection.sh
```

### 2. Run Driver in Debug Mode
```bash
./debug_driver.sh
```

### 3. Monitor Events
```bash
./test_monitor_events.sh
```

## Debug Modes

### Debug Log Level
```bash
LOG=DEBUG python3 asus_accel_driver.py default
```

### Watch System Logs
```bash
# Terminal 1: Run driver
./debug_driver.sh

# Terminal 2: Watch logs
journalctl -f | grep "Asus Accel Tablet Mode Driver"
```

## Documentation

- **Full Debugging Guide**: `docs/DEBUGGING.md`
- **Testing Guide**: `TESTING.md`

## Test Checklist

Before installation, verify:
- [ ] Python dependencies installed
- [ ] Accelerometer is detected
- [ ] Driver starts without errors
- [ ] Tablet mode detection works
- [ ] Events are sent correctly
- [ ] No crashes or errors

## Common Issues

**"Can't find accel sensor"**
- Run: `./test_accel_detection.sh`
- Check: `udevadm info --export-db | grep accel`

**"Permission denied"**
- Add to groups: `sudo usermod -a -G input,uinput $USER`
- Log out and back in

**"Module not found"**
- Load: `sudo modprobe uinput`

**"Cannot send event"**
- Check uinput permissions
- Check if uinput module is loaded

For more details, see `docs/DEBUGGING.md`.

