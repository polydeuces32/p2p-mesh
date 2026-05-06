import CoreBluetooth
import Foundation
import SwiftUI

/// First-pass CoreBluetooth scanner + advertiser for P2P Mesh.
///
/// This class only proves local discovery. It does not send messages yet.
final class BluetoothMeshManager: NSObject, ObservableObject {
    @Published private(set) var bluetoothState: String = "Unknown"
    @Published private(set) var isScanning = false
    @Published private(set) var isAdvertising = false
    @Published private(set) var peers: [MeshPeer] = []
    @Published private(set) var lastEvent: String = "Idle"

    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var peerMap: [UUID: MeshPeer] = [:]

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
        peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
    }

    func start() {
        startScanningIfReady()
        startAdvertisingIfReady()
    }

    func stop() {
        centralManager.stopScan()
        peripheralManager.stopAdvertising()
        isScanning = false
        isAdvertising = false
        lastEvent = "Stopped scanner and advertiser"
    }

    func clearPeers() {
        peerMap.removeAll()
        peers.removeAll()
        lastEvent = "Cleared discovered peers"
    }

    private func startScanningIfReady() {
        guard centralManager.state == .poweredOn else {
            lastEvent = "Bluetooth scanner is not ready"
            return
        }

        centralManager.scanForPeripherals(
            withServices: [MeshConstants.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )

        isScanning = true
        lastEvent = "Scanning for P2P Mesh peers"
    }

    private func startAdvertisingIfReady() {
        guard peripheralManager.state == .poweredOn else {
            lastEvent = "Bluetooth advertiser is not ready"
            return
        }

        let advertisement: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [MeshConstants.serviceUUID],
            CBAdvertisementDataLocalNameKey: MeshConstants.advertisedLocalName
        ]

        peripheralManager.startAdvertising(advertisement)
        isAdvertising = true
        lastEvent = "Advertising P2P Mesh service"
    }

    private func upsertPeer(id: UUID, name: String, rssi: Int) {
        let peer = MeshPeer(
            id: id,
            name: name.isEmpty ? "Unnamed peer" : name,
            rssi: rssi,
            discoveredAt: Date()
        )

        peerMap[id] = peer
        peers = peerMap.values.sorted { $0.discoveredAt > $1.discoveredAt }
        lastEvent = "Discovered \(peer.name) RSSI \(rssi)"
    }

    private func describeState(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        @unknown default:
            return "Unknown Future State"
        }
    }
}

extension BluetoothMeshManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = describeState(central.state)

        if central.state == .poweredOn {
            startScanningIfReady()
        } else {
            isScanning = false
            lastEvent = "Central state: \(bluetoothState)"
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let peerName = advertisedName ?? peripheral.name ?? "P2P Mesh Peer"
        upsertPeer(id: peripheral.identifier, name: peerName, rssi: RSSI.intValue)
    }
}

extension BluetoothMeshManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertisingIfReady()
        } else {
            isAdvertising = false
            lastEvent = "Peripheral state: \(describeState(peripheral.state))"
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error {
            isAdvertising = false
            lastEvent = "Advertising failed: \(error.localizedDescription)"
            return
        }

        isAdvertising = true
        lastEvent = "Advertising started"
    }
}
