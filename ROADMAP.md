# P2P Mesh Roadmap

## v2.1 Stabilization

- refresh README
- architecture docs
- roadmap docs
- connection retry logic
- better status messaging
- browser compatibility checks
- improved error handling

## v3 Identity + Trust

- device public/private key generation
- signed peer registration
- signed messages
- QR code peer pairing
- nickname + verified fingerprint UI
- optional recovery export

## v3.5 Reliability

- TURN relay support
- reconnect logic
- message acknowledgements
- resend queue
- delivery state indicators

## v4 True Mesh Routing

- multi-peer topology
- group rooms
- message forwarding between peers
- TTL hop count
- duplicate suppression
- offline store-and-forward

## v5 Native Bluetooth Mode

- iOS Swift CoreBluetooth app
- Android Kotlin BLE app
- nearby discovery
- offline relay mesh
- bridge Bluetooth peers to WebRTC peers

## v6 Payments + Identity Extensions

- Bitcoin / Lightning tipping
- sats-based identity handles
- paid relay nodes
- anti-spam economics

## Commercial Opportunities

- emergency/offline communication
- event networking
- private teams communication
- field operations
- developer white-label SDK

## Rule Going Forward

Do not mix unfinished Bluetooth claims into the browser build.
Ship each transport as a clean module.
