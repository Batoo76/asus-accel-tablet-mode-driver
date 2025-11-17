# Debugging Guide - ASUS Accel Tablet Mode Driver

This guide explains how to test and debug the Python driver before installation.

## Quick Start

1. **Setup test environment:**
   ```bash
   cd asus-accel-tablet-mode-driver
   chmod +x test_setup.sh test_accel_detection.sh debug_driver.sh
   ./test_setup.sh
   ```

2. **Test accelerometer detection:**
   ```bash
   ./test_accel_detection.sh
   ```

3. **Run driver in debug mode:**
   ```bash
   ./debug_driver.sh
   ```

## Test Environment Setup

### Prerequisites Check

The `test_setup.sh` script checks:
- ✅ Python 3 installation
- ✅ Python dependencies (python-libevdev)
- ✅ User groups (input, uinput)
- ✅ Kernel modules (uinput)
- ✅ Device access permissions
- ✅ Accelerometer sensor detection
- ✅ IIO device availability

### Fixing Common Issues

#### Missing Python Dependencies
```bash
# Debian/Ubuntu
sudo apt-get install python3-libevdev

# Arch Linux
sudo pacman -S python-libevdev

# Or using pip
pip3 install python-libevdev
```

#### Missing User Groups
```bash
sudo usermod -a -G input,uinput $USER
# Log out and back in for changes to take effect
```

#### Missing Kernel Modules
```bash
sudo modprobe uinput
```

To make permanent:
```bash
echo "uinput" | sudo tee -a /etc/modules
```

#### Permission Issues
If you can't access `/dev/uinput`:
- Add udev rules (see installation scripts)
- Or run with `sudo` for testing (not recommended for production)

## Debugging Modes

### 1. Verbose Logging

Enable debug output:
```bash
LOG=DEBUG python3 asus_accel_driver.py default
```

Or use the debug script:
```bash
./debug_driver.sh
```

### 2. System Log Monitoring

Watch system logs in real-time:
```bash
# Systemd journal
journalctl -f | grep "Asus Accel Tablet Mode Driver"

# Or syslog
tail -f /var/log/syslog | grep "Asus Accel Tablet Mode Driver"
```

### 3. Using debug_driver.sh

The debug script provides a convenient wrapper:
```bash
./debug_driver.sh                    # Default settings
./debug_driver.sh -l default        # Explicit layout
./debug_driver.sh -s                # Run with sudo
```

## Testing Without Hardware

### Accelerometer Detection Test

Test if the driver can detect your accelerometer:
```bash
./test_accel_detection.sh
```

This shows:
- Available accelerometer devices
- IIO device information
- Current accelerometer values
- Tablet mode detection status

### Manual Device Inspection

Check udev database:
```bash
udevadm info --export-db | grep -i accel
```

Check IIO devices:
```bash
ls -l /sys/bus/iio/devices/
cat /sys/bus/iio/devices/iio:device*/name
```

Check accelerometer values:
```bash
# Find device path first
udevadm info --export-db | grep -A 5 "accel" | grep "^P:"

# Then read values (replace path)
cat /sys/devices/.../iio:device0/in_accel_x_raw
cat /sys/devices/.../iio:device0/in_accel_y_raw
cat /sys/devices/.../iio:device0/in_accel_z_raw
```

## Debugging Specific Issues

### Issue: Driver Fails to Start

1. **Check accelerometer detection:**
   ```bash
   ./test_accel_detection.sh
   ```

2. **Check logs:**
   ```bash
   LOG=DEBUG python3 asus_accel_driver.py default 2>&1 | tee debug.log
   ```

3. **Verify permissions:**
   ```bash
   ls -l /dev/uinput
   groups  # Check if in input, uinput groups
   ```

### Issue: Accelerometer Not Detected

1. **Verify accelerometer exists:**
   ```bash
   ls -l /sys/bus/iio/devices/
   udevadm info --export-db | grep -i accel
   ```

2. **Check device name patterns:**
   The driver looks for "accel" in udev output

3. **Manual detection test:**
   ```bash
   # Find accelerometer device path
   udevadm info --export-db | grep -B 5 -A 10 "accel"
   ```

### Issue: Cannot Read Accelerometer Values

1. **Check file permissions:**
   ```bash
   ls -l /sys/devices/.../iio:device0/in_accel_*_raw
   ```

2. **Test reading manually:**
   ```bash
   # Find device path first
   cat /sys/devices/.../iio:device0/in_accel_x_raw
   ```

3. **Check permissions:**
   ```bash
   # May need to run with sudo for testing
   sudo python3 asus_accel_driver.py default
   ```

### Issue: uinput Device Not Created

1. **Check uinput module:**
   ```bash
   lsmod | grep uinput
   sudo modprobe uinput
   ```

2. **Check permissions:**
   ```bash
   ls -l /dev/uinput
   # Should be: crw-rw---- 1 root uinput
   ```

3. **Check groups:**
   ```bash
   groups | grep uinput
   ```

### Issue: Tablet Mode Not Detected

1. **Enable debug logging:**
   ```bash
   LOG=DEBUG python3 asus_accel_driver.py default
   ```

2. **Check accelerometer values:**
   ```bash
   ./test_accel_detection.sh
   ```

3. **Verify detection criteria:**
   - Tablet mode: x >= -5 and x <= 5, y >= -5 and y <= 5, z <= -9
   - Laptop mode: anything else

4. **Monitor accelerometer values:**
   ```bash
   # Watch values in real-time
   watch -n 0.5 'cat /sys/devices/.../iio:device0/in_accel_*_raw'
   ```

### Issue: Events Not Being Sent

1. **Enable debug logging:**
   ```bash
   LOG=DEBUG python3 asus_accel_driver.py default
   ```

2. **Check if tablet mode is detected:**
   - Look for "Flip to tablet mode" or "Flip to laptop mode" in logs

3. **Monitor input events:**
   ```bash
   # In another terminal
   sudo evtest /dev/input/eventX  # Replace X with uinput device number
   ```

4. **Check if events are being sent:**
   ```bash
   # Use libinput debug-events
   sudo libinput debug-events | grep -i tablet
   
   # Or acpi_listen
   sudo acpi_listen
   ```

## Debugging Tools

### 1. evtest

Monitor input events:
```bash
sudo apt-get install evtest
sudo evtest
# Select the uinput device (Asus WMI accel tablet mode)
```

### 2. libinput debug-events

Monitor libinput events:
```bash
sudo libinput debug-events | grep -i tablet
```

### 3. acpi_listen

Monitor ACPI events:
```bash
sudo acpi_listen
# Should show: video/tabletmode TBLT ...
```

### 4. strace

Trace system calls:
```bash
strace -e trace=open,read,write python3 asus_accel_driver.py default
```

### 5. Python Debugger

Debug with pdb:
```bash
python3 -m pdb asus_accel_driver.py default
```

## Debug Output

### Log Levels

- **INFO**: Informational messages (default)
- **DEBUG**: Detailed debug information
- **ERROR**: Only errors

### Debug Information Printed

When `LOG=DEBUG` is set, the driver prints:
- Accelerometer detection process
- Device path information
- Accelerometer values (x, y, z)
- Tablet mode detection state changes
- Event sending status

### Example Debug Output

```
2024-11-14 13:20:15,123 INFO     Accelerometer detected
2024-11-14 13:20:15,234 INFO     Device path: /sys/devices/.../iio:device0
2024-11-14 13:20:15,345 DEBUG    X: 2.5, Y: -1.3, Z: -9.8
2024-11-14 13:20:15,456 INFO     Flip to tablet mode
2024-11-14 13:20:20,567 DEBUG    X: 0.1, Y: 0.2, Z: -9.5
2024-11-14 13:20:25,678 INFO     Flip to laptop mode
```

## Testing Checklist

Before installation, verify:

- [ ] Driver script is executable
- [ ] Python dependencies are installed
- [ ] Accelerometer is detected (`test_accel_detection.sh`)
- [ ] Driver starts without errors
- [ ] Accelerometer values are readable
- [ ] Tablet mode detection works (flip laptop)
- [ ] Events are sent when mode changes
- [ ] Config file is read correctly
- [ ] Logs are written correctly

## Common Problems and Solutions

### Problem: "Can't find accel sensor"
**Solution**: Check `/sys/bus/iio/devices/` for accelerometer. The driver looks for "accel" in udev output.

### Problem: "Can't find accel sensor device path"
**Solution**: The device path is extracted from udev "P:" line. Check if udevadm shows the device.

### Problem: "Cannot send event"
**Solution**:
- Check uinput module: `lsmod | grep uinput`
- Check permissions: `ls -l /dev/uinput`
- Add user to uinput group: `sudo usermod -a -G uinput $USER`

### Problem: Tablet mode not detected
**Solution**:
- Check accelerometer values: `./test_accel_detection.sh`
- Verify criteria: x/y between -5 and 5, z <= -9
- Try flipping laptop to different angles
- Check if accelerometer is working: `cat /sys/.../in_accel_*_raw`

### Problem: No events being received
**Solution**:
- Verify tablet mode is detected (check logs)
- Monitor input events: `sudo evtest` (select uinput device)
- Check if driver grabbed the device
- Verify events are being sent (check logs)

## Performance Debugging

### Check CPU Usage
```bash
top -p $(pgrep -f asus_accel_driver)
```

### Check Memory Usage
```bash
ps aux | grep asus_accel_driver
```

### Profile with cProfile
```bash
python3 -m cProfile -o profile.stats asus_accel_driver.py default
python3 -m pstats profile.stats
```

## Reporting Issues

When reporting issues, include:

1. **System information:**
   ```bash
   uname -a
   lsb_release -a
   python3 --version
   ```

2. **Device information:**
   ```bash
   ./test_accel_detection.sh > device_info.txt
   ```

3. **Debug logs:**
   ```bash
   LOG=DEBUG python3 asus_accel_driver.py default 2>&1 | tee debug.log
   ```

4. **Configuration:**
   - Layout name used
   - Config file contents
   - Any custom settings

5. **Steps to reproduce:**
   - What you did
   - What you expected
   - What actually happened

## Next Steps

After successful testing:
1. Review the logs for any warnings
2. Test tablet mode detection (flip laptop)
3. Verify events are sent correctly
4. Proceed with installation if everything works

