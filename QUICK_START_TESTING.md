# Quick Start - Testing the Driver

## 1. Setup (One Time)

```bash
cd asus-accel-tablet-mode-driver
chmod +x *.sh
./test_setup.sh
```

This checks dependencies, permissions, and accelerometer detection.

## 2. Test Accelerometer Detection

```bash
./test_accel_detection.sh
```

Verifies your accelerometer is detected and readable.

## 3. Run Driver in Debug Mode

```bash
./debug_driver.sh
```

Runs the driver with verbose output. Press Ctrl+C to stop.

## 4. Monitor Events (Optional)

In another terminal:
```bash
# Watch system logs
journalctl -f | grep "Asus Accel Tablet Mode Driver"

# Or monitor input events
sudo evtest
```

## Debug Options

### Debug Log Level
```bash
LOG=DEBUG python3 asus_accel_driver.py default
```

### With Sudo (if needed)
```bash
sudo -E LOG=DEBUG python3 asus_accel_driver.py default
```

## Testing Features

1. **Tablet Mode Detection**
   - Flip laptop to horizontal position
   - Should detect tablet mode (z <= -9, x/y between -5 and 5)
   - Should see "Flip to tablet mode" in logs

2. **Laptop Mode Detection**
   - Flip laptop back to normal position
   - Should detect laptop mode
   - Should see "Flip to laptop mode" in logs

3. **Event Sending**
   - When mode changes, events should be sent
   - Monitor with: `sudo libinput debug-events`
   - Or: `sudo acpi_listen`

## Troubleshooting

- **"Can't find accel sensor"**: Run `./test_accel_detection.sh`
- **"Permission denied"**: Add to groups: `sudo usermod -a -G input,uinput $USER`
- **"Module not found"**: `sudo modprobe uinput`
- **"Cannot send event"**: Check uinput permissions and module

See `docs/DEBUGGING.md` for detailed help.

