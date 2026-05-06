# Nostr + Bluetooth Mesh Transport Plan

## Goal

Extend P2P Mesh into a dual-transport communication system:

1. **Nostr Protocol over the internet** for global relay-based messaging.
2. **Bluetooth Low Energy mesh** for local offline messaging.

The browser WebRTC version remains the current working transport. Nostr and Bluetooth should be added as separate transport modules, not mixed directly into the existing signaling logic.

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
- Private messaging using modern NIP-based encryption flows.
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
- Multi-hop forwarding where supported.
- No internet requirement.
- Useful for offline communication, protests, disasters, remote areas, events, and local coordination.

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

All transports should share a compact message envelope.

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
  "ttl": 8,
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
- Use the same packet envelope.
- Forward packets by TTL.
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
- Public relay abuse/spam requires moderation and filtering.

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
