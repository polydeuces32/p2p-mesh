import Foundation

/// A nearby device discovered through Bluetooth scanning.
struct MeshPeer: Identifiable, Equatable {
    let id: UUID
    let name: String
    let rssi: Int
    let discoveredAt: Date

    var signalLabel: String {
        if rssi >= -55 {
            return "Strong"
        }

        if rssi >= -75 {
            return "Medium"
        }

        return "Weak"
    }
}
