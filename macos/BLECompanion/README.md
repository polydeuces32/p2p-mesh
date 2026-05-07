# P2P Mesh macOS BLE Companion

This is the second test option for the iOS BLE prototype.

It lets your Mac act as a nearby BLE peer so you can test the iPhone scanner without needing a second iPhone.

## What it does

- Starts a CoreBluetooth central scanner.
- Starts a CoreBluetooth peripheral advertiser.
- Uses the same P2P Mesh BLE service UUID as the iOS app.
- Prints discovered peers and RSSI values to the terminal.

## What it does not do yet

- No message sending.
- No GATT packet characteristic.
- No Noise encryption.
- No relay routing.
- No background mode.

## Run

From the repo root:

```bash
cd ~/Desktop/p2p-mesh
swift macos/BLECompanion/main.swift
```

macOS may ask for Bluetooth permission for Terminal or your shell app. Allow it.

## Test with iPhone

1. Run the companion on your Mac:

```bash
swift macos/BLECompanion/main.swift
```

2. Run the P2PMesh iOS app on a real iPhone.
3. Tap `Start Scanner + Advertiser`.
4. Watch the Mac terminal for discovered peers.
5. Watch the iPhone app for discovered peers.

## Expected terminal output

```text
P2P Mesh macOS BLE Companion
Central state: poweredOn
Peripheral state: poweredOn
Advertising P2P Mesh service
Scanning for P2P Mesh peers
Discovered peer: P2PMesh RSSI -61
```

## Notes

BLE discovery can be inconsistent on macOS if Bluetooth permissions are denied. Check:

```text
System Settings -> Privacy & Security -> Bluetooth
```

Allow your terminal app or Xcode if prompted.
