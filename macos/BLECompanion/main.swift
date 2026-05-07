import CoreBluetooth
import Foundation

private enum MeshConstants {
    static let serviceUUID = CBUUID(string: "8BDBA650-4F72-4E5F-9E3A-8C8B5A9D3A11")
    static let advertisedLocalName = "P2PMeshMac"
}

final class BLECompanion: NSObject {
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var seenPeerIDs = Set<UUID>()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
        peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
    }

    func start() {
        print("P2P Mesh macOS BLE Companion")
        print("Service UUID: \(MeshConstants.serviceUUID.uuidString)")
        print("Waiting for Bluetooth managers...")
    }

    private func startScanningIfReady() {
        guard centralManager.state == .poweredOn else {
            print("Scanner not ready: \(describeState(centralManager.state))")
            return
        }

        centralManager.scanForPeripherals(
            withServices: [MeshConstants.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )

        print("Scanning for P2P Mesh peers")
    }

    private func startAdvertisingIfReady() {
        guard peripheralManager.state == .poweredOn else {
            print("Advertiser not ready: \(describeState(peripheralManager.state))")
            return
        }

        let advertisement: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [MeshConstants.serviceUUID],
            CBAdvertisementDataLocalNameKey: MeshConstants.advertisedLocalName
        ]

        peripheralManager.startAdvertising(advertisement)
        print("Advertising P2P Mesh service as \(MeshConstants.advertisedLocalName)")
    }

    private func describeState(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        @unknown default:
            return "unknownFutureState"
        }
    }
}

extension BLECompanion: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state: \(describeState(central.state))")

        if central.state == .poweredOn {
            startScanningIfReady()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let name = advertisedName ?? peripheral.name ?? "Unnamed peer"

        if seenPeerIDs.insert(peripheral.identifier).inserted {
            print("Discovered peer: \(name) id=\(peripheral.identifier.uuidString) RSSI=\(RSSI.intValue)")
        } else {
            print("Updated peer: \(name) RSSI=\(RSSI.intValue)")
        }
    }
}

extension BLECompanion: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Peripheral state: \(describeState(peripheral.state))")

        if peripheral.state == .poweredOn {
            startAdvertisingIfReady()
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error {
            print("Advertising failed: \(error.localizedDescription)")
            return
        }

        print("Advertising started")
    }
}

let companion = BLECompanion()
companion.start()
RunLoop.main.run()
