# P2PMesh iOS Bluetooth Prototype

This folder contains the first native iOS direction for P2P Mesh.

## Scope

This prototype is intentionally small:

- SwiftUI app shell
- CoreBluetooth scanner
- CoreBluetooth advertiser
- Shared P2P Mesh BLE service UUID
- Nearby peer list
- Runtime Bluetooth status display

## Not Included Yet

- Noise Protocol encryption
- 7-hop relay routing
- Binary packet chunking
- Message send / receive
- Background restoration
- Production identity management

## Why Native iOS

The web app can handle WebRTC and Nostr, but full Bluetooth LE mesh requires native iOS APIs.

Browser Bluetooth is not enough for reliable iPhone-to-iPhone mesh behavior.

## Xcode Setup

Open Xcode and create a new project manually:

```text
File -> New -> Project -> iOS -> App
Product Name: P2PMesh
Interface: SwiftUI
Language: Swift
Bundle Identifier: com.polydeuces32.p2pmesh
```

Then copy these files into the generated app target:

```text
P2PMeshApp.swift
ContentView.swift
BluetoothMeshManager.swift
MeshPeer.swift
MeshConstants.swift
```

## Required Info.plist Keys

Add these privacy strings to the app target:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>P2P Mesh uses Bluetooth to discover and communicate with nearby devices.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>P2P Mesh uses Bluetooth advertising so nearby devices can discover this phone.</string>
```

## First Test

Use a real iPhone. The iOS Simulator does not provide real Bluetooth behavior.

1. Build and run on iPhone A.
2. Tap `Start`.
3. Build and run on iPhone B.
4. Tap `Start`.
5. Confirm each device discovers the other.

## Next Implementation Step

After peer discovery works, add:

```text
- GATT characteristic for small packets
- HELLO packet
- ACK packet
- binary packet encoder
- duplicate packet cache
```
