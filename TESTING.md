# Testing Guide - ASUS Accel Tablet Mode Driver

Quick reference for testing the driver before installation.

## Quick Test

```bash
# 1. Setup environment
./test_setup.sh

# 2. Test accelerometer detection
./test_accel_detection.sh

# 3. Run driver in debug mode
./debug_driver.sh
```

## Test Scripts

### test_setup.sh
Comprehensive environment check:
- Verifies all dependencies
- Checks permissions and groups
- Creates test directories

### test_accel_detection.sh
Tests accelerometer detection without running the full driver:
- Shows available accelerometers
- Lists IIO devices
- Displays current accelerometer values
- Tests tablet mode detection criteria

### debug_driver.sh
Runs the driver with debug output:
- Verbose logging to console
- Configurable log levels
- Easy configuration

### test_monitor_events.sh
Helps monitor input events:
- Lists available devices
- Shows how to use evtest
- Provides monitoring commands

## Manual Testing Steps

### 1. Verify Installation
```bash
cd asus-accel-tablet-mode-driver
python3 --version  # Should be 3.6+
python3 -c "import libevdev; print('OK')"
```

### 2. Test Accelerometer Detection
```bash
./test_accel_detection.sh
# Verify accelerometer is detected
# Verify values are readable
```

### 3. Run with Debug Output
```bash
LOG=DEBUG python3 asus_accel_driver.py default
```

### 4. Test Tablet Mode Detection
- Start driver: `./debug_driver.sh`
- Flip laptop to horizontal position
- Should see "Flip to tablet mode" in logs
- Flip back to normal position
- Should see "Flip to laptop mode" in logs

### 5. Monitor Events
In another terminal:
```bash
# Watch system logs
journalctl -f | grep "Asus Accel Tablet Mode Driver"

# Or monitor input events
sudo evtest
# Select the uinput device
```

### 6. Test with libinput
```bash
sudo libinput debug-events | grep -i tablet
```

### 7. Test with acpi_listen
```bash
sudo acpi_listen
# Should show tablet mode events
```

## Expected Behavior

### On Startup
- Driver detects accelerometer device
- Driver creates uinput device
- Driver loads configuration
- Driver enters monitoring loop

### During Operation
- Accelerometer values are read every 0.5 seconds
- Tablet mode is detected when: x/y between -5 and 5, z <= -9
- Events are sent when mode changes
- Logs show mode transitions

### On Shutdown
- Clean shutdown on Ctrl+C
- Resources are freed
- Logs show "Driver stopped"

## Troubleshooting

See `docs/DEBUGGING.md` for detailed troubleshooting guide.

## Success Criteria

Driver is ready for installation when:
- ✅ Python dependencies installed
- ✅ Accelerometer is detected
- ✅ Driver starts without errors
- ✅ Tablet mode detection works
- ✅ Events are sent correctly
- ✅ No crashes or errors
- ✅ Clean shutdown

