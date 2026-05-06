import CoreBluetooth

/// Shared constants for the P2P Mesh Bluetooth prototype.
enum MeshConstants {
    /// Stable BLE service UUID used by nearby P2P Mesh devices.
    /// Keep this value fixed across test devices so scanners can discover advertisers.
    static let serviceUUID = CBUUID(string: "8BDBA650-4F72-4E5F-9E3A-8C8B5A9D3A11")

    /// Local name advertised over BLE. Keep this short because BLE advertisement space is limited.
    static let advertisedLocalName = "P2PMesh"
}
