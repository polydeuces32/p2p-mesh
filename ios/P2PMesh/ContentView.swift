import SwiftUI

struct ContentView: View {
    @StateObject private var bluetooth = BluetoothMeshManager()

    var body: some View {
        NavigationStack {
            List {
                Section("Bluetooth") {
                    statusRow(label: "State", value: bluetooth.bluetoothState)
                    statusRow(label: "Scanning", value: bluetooth.isScanning ? "On" : "Off")
                    statusRow(label: "Advertising", value: bluetooth.isAdvertising ? "On" : "Off")
                    statusRow(label: "Last Event", value: bluetooth.lastEvent)
                }

                Section("Controls") {
                    Button("Start Scanner + Advertiser") {
                        bluetooth.start()
                    }

                    Button("Stop") {
                        bluetooth.stop()
                    }

                    Button("Clear Peers") {
                        bluetooth.clearPeers()
                    }
                }

                Section("Nearby Peers") {
                    if bluetooth.peers.isEmpty {
                        Text("No peers discovered yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(bluetooth.peers) { peer in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(peer.name)
                                    .font(.headline)

                                Text(peer.id.uuidString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)

                                HStack {
                                    Text("RSSI: \(peer.rssi)")
                                    Spacer()
                                    Text(peer.signalLabel)
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("P2P Mesh")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("BLE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func statusRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    ContentView()
}
