import Foundation

/// A nearby device discovered through Bluetooth scanning.
struct MeshPeer: Identifiable, Equatable {
    let id: UUID
    let name: String
    let rssi: Int
    let discoveredAt: Date

    var signalLabel: String {
        switch rssi {
        case -55...:
            return "Strong"
        case -75 ... -56:
            return "Medium"
        default:
            return "Weak"
        }
    }
}
