# P2P Mesh Roadmap

## v2.1 Stabilization
- completed docs refresh
- completed connection polish

## v3 Identity + Trust
- completed device public/private key generation
- completed signed peer identity
- completed signed messages

## v3.5 Reliability
- completed reconnect logic
- completed message acknowledgements
- completed resend queue
- completed delivery indicators

## v4 True Mesh Routing (LIVE)
- mesh packet schema
- multi-peer topology model
- message forwarding between peers
- TTL hop count
- duplicate suppression
- offline store-and-forward foundation
- peer bridge routing direction
- group rooms next

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
