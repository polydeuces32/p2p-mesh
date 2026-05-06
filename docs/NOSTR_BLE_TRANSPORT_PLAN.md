# Nostr + Bluetooth Mesh Transport Plan

## Goal

Extend P2P Mesh into a dual-transport communication system:

1. **Bluetooth Mesh Network offline** for local peer-to-peer communication without internet.
2. **Nostr Protocol over the internet** for global relay-based messaging.

The browser WebRTC version remains the current working transport. Nostr and Bluetooth should be added as separate transport modules, not mixed directly into the existing signaling logic.

## Target Capabilities

### Bluetooth Mesh Network Offline

- **Local communication:** direct peer-to-peer messaging within Bluetooth range.
- **Multi-hop relay:** messages route through nearby devices with a maximum of 7 hops.
- **No internet required:** works completely offline for disaster scenarios, protests, remote areas, events, and local coordination.
- **Noise Protocol encryption:** end-to-end encrypted sessions with forward secrecy.
- **Binary protocol:** compact packet format optimized for Bluetooth LE MTU and low-bandwidth constraints.
- **Automatic discovery:** peer discovery, connection negotiation, and connection management.
- **Adaptive power:** battery-optimized duty cycling for scanning, advertising, and relay behavior.

### Nostr Protocol Internet

- **Global reach:** connect with users worldwide through internet relays.
- **Location channels:** geographic chat rooms using geohash coordinates.
- **Relay network:** use a broad configurable relay set instead of a single server dependency.
- **NIP-17 encryption:** gift-wrapped private messages for internet privacy.
- **Ephemeral keys:** fresh cryptographic identity per geohash area.

## Transport Layers

```text
Application Layer
  - identity
  - messages
  - channel routing
  - encryption policy
  - message status

Transport Layer
  - WebRTC DataChannel
  - Nostr relays
  - Bluetooth LE mesh

Bridge Layer
  - optional forwarding between transports
  - rate limits
  - duplicate protection
  - TTL / hop limits
```

## Nostr Protocol Transport

### Purpose

Nostr provides internet-scale communication through distributed relays. It can extend P2P Mesh beyond direct WebRTC sessions and allow users to communicate through public or private relay infrastructure.

### Capabilities

- Global reach through internet relays.
- Relay-based publish/subscribe model.
- Geographic channels using geohash-based topic naming.
- Distributed relay redundancy.
- Private messaging using NIP-17 gift-wrapped encryption.
- Ephemeral keys per geographic area for privacy isolation.

### Proposed Channel Model

```text
nostr:global
nostr:geohash:<precision>:<hash>
nostr:dm:<recipient-public-key>
nostr:relay-status
```

Example:

```text
nostr:geohash:6:dr5reg
```

This would represent a location-scoped chat area without storing exact GPS coordinates in the message payload.

### Relay Model

Use a configurable relay list:

```json
{
  "relays": [
    "wss://relay.damus.io",
    "wss://nos.lol",
    "wss://relay.primal.net"
  ]
}
```

Do not hardcode a permanent relay list into app logic. Keep it configurable.

A production implementation can support a larger relay directory, but the app should actively connect only to a bounded subset at runtime for battery, bandwidth, and spam control.

### Encryption Direction

Use Nostr private message standards where supported:

- NIP-17 gift-wrapped private messages.
- Avoid exposing plaintext DM metadata where possible.
- Use ephemeral keys for location rooms.
- Keep long-term identity optional.

### Ephemeral Identity Model

Each geohash area can generate a temporary Nostr keypair:

```text
master browser identity
  -> geohash scoped identity
  -> nostr event signing key
```

This prevents one user identity from being trivially linked across all geographic rooms.

## Bluetooth LE Mesh Transport

### Channel Name

```text
mesh #bluetooth
```

### Purpose

Bluetooth mesh provides local-first communication when the internet is unavailable or undesirable.

### Scope

- Local devices within Bluetooth range.
- Multi-hop forwarding with a hard maximum of 7 hops.
- No internet requirement.
- Useful for offline communication, protests, disasters, remote areas, events, and local coordination.

### Discovery Model

Bluetooth peers should discover each other automatically through alternating scan and advertise windows.

```text
advertise window -> peer announces service UUID and short ephemeral identity
scan window      -> peer listens for nearby service advertisements
connect window   -> peer negotiates session and exchanges packets
sleep window     -> peer reduces radio usage to preserve battery
```

Discovery must not require a central coordinator.

### Relay Model

Each packet carries a hop counter and a TTL.

```text
initial_ttl = 7
on_relay: ttl = ttl - 1
if ttl <= 0: drop packet
if packet_id already seen: drop packet
```

The max 7-hop limit prevents uncontrolled flooding and protects battery life.

### Noise Protocol Encryption

Use Noise Protocol for Bluetooth session encryption.

Recommended direction:

```text
Noise_XX or Noise_IK
Curve25519 key exchange
ChaCha20-Poly1305 AEAD
BLAKE2s or SHA-256 hash
```

Design goals:

- End-to-end encryption.
- Forward secrecy.
- Session keys rotated regularly.
- No plaintext private messages over BLE.
- Long-term identity optional; ephemeral identities preferred for local rooms.

### Binary Packet Format

Bluetooth packets should use a compact binary envelope instead of JSON.

Suggested packet header:

```text
byte 0      version
byte 1      packet_type
byte 2      ttl
byte 3      flags
bytes 4-19  packet_id      16 bytes
bytes 20-27 channel_id     8 bytes
bytes 28-31 timestamp      uint32
bytes 32..  encrypted_body
```

Packet types:

```text
0x01 HELLO
0x02 HANDSHAKE
0x03 CHAT
0x04 ACK
0x05 RELAY
0x06 GOODBYE
```

The binary body should be chunked when larger than the negotiated BLE MTU.

### Adaptive Power

Bluetooth mesh should support battery-aware radio behavior.

Modes:

```text
active     frequent scan/advertise/connect windows
balanced   moderate scan and relay behavior
low_power  longer sleep windows, reduced relay participation
emergency  aggressive relay mode while battery allows
```

The app should expose a user-visible battery/network mode rather than silently draining the device.

### Transport Constraints

Bluetooth LE has strict limits:

- Small packet size.
- Higher latency than WebRTC.
- Mobile OS background restrictions.
- Browser Bluetooth support is limited and not enough for full mesh networking.
- Real production support likely needs native iOS and Android apps.

### Native Layer Direction

```text
iOS: Swift + CoreBluetooth
Android: Kotlin + Bluetooth LE
Shared: compact encrypted packet protocol
Frontend: web app can display status and imported messages
```

## Unified Packet Envelope

All transports should share a logical message envelope.

JSON is acceptable for WebRTC and Nostr. Bluetooth should encode the same fields into a compact binary form.

```json
{
  "v": 1,
  "id": "uuid-or-hash",
  "type": "chat",
  "from": "public-key-or-ephemeral-id",
  "to": "channel-or-peer-id",
  "transport": "webrtc|nostr|bluetooth",
  "channel": "nostr:geohash:6:dr5reg",
  "body": "encrypted-or-plaintext-payload",
  "created_at": 1710000000,
  "ttl": 7,
  "path": [],
  "sig": "signature"
}
```

## Duplicate Protection

Every transport must reject duplicate packets by `id`.

```text
seen_packet_ids = LRU cache
packet ttl decreases on every relay hop
packet is dropped when ttl <= 0
```

## Recommended Implementation Order

### Phase 1: Documentation and Data Model

- Add this transport plan.
- Define shared packet envelope.
- Define channel naming conventions.
- Define relay configuration format.
- Define Bluetooth binary packet header.

### Phase 2: Nostr Read-Only Prototype

- Add Nostr relay connection module.
- Subscribe to one geohash channel.
- Display incoming Nostr events in the existing message UI.
- Do not send private messages yet.

### Phase 3: Nostr Send Support

- Generate ephemeral geohash keypair.
- Publish signed events to configured relays.
- Add relay health indicators.
- Add duplicate protection.

### Phase 4: NIP-17 Private Messaging

- Add encrypted direct messages.
- Add gift-wrapped event flow.
- Add recipient key management.
- Add clear privacy warnings.

### Phase 5: Bluetooth Native Prototype

- Build native BLE scanner/broadcaster prototype.
- Implement automatic peer discovery.
- Implement compact binary packet envelope.
- Add Noise Protocol session encryption.
- Forward packets with max 7-hop TTL.
- Add adaptive power mode.
- Sync received packets back into the app UI.

### Phase 6: Transport Bridge

- Optional bridge between Nostr and Bluetooth.
- Strict rate limits.
- Explicit user opt-in.
- Abuse controls.

## Repo Impact

Suggested future structure:

```text
api/
  main.py

docs/
  NOSTR_BLE_TRANSPORT_PLAN.md

src/
  transports/
    webrtc.js
    nostr.js
    bluetooth.js
  protocol/
    envelope.js
    binary-packet.js
    crypto.js
    channels.js
```

The current project is a single-file browser prototype. Before adding real Nostr or Bluetooth code, the frontend should be split into modules.

## Risks

- Nostr relays can leak metadata if channels and keys are reused.
- Location channels can expose user movement if geohash precision is too high.
- NIP-17 implementation must be tested carefully before claiming privacy.
- Browser Bluetooth is not enough for reliable offline mesh.
- Native BLE mesh needs battery, background execution, and OS permission handling.
- Noise Protocol implementation must be audited or use a proven library.
- Public relay abuse/spam requires moderation and filtering.
- Bluetooth mesh relay behavior can drain batteries without adaptive power controls.

## Practical MVP

The best first real implementation is:

```text
Nostr geohash public channel prototype
```

Minimum feature set:

- Configurable relay list.
- Geohash channel input.
- Ephemeral Nostr keypair.
- Publish/subscribe text events.
- Show relay connection status.
- Duplicate packet protection.

Bluetooth should remain a native-app roadmap item until the browser version is modular and stable.
