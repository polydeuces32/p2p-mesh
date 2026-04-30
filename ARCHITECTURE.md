# P2P Mesh Architecture

## Current Version: v2

P2P Mesh v2 uses a hybrid model:

- Centralized signaling
- Decentralized peer transport

The server helps peers discover each other and exchange connection metadata. After that, browsers communicate directly.

## Components

### Frontend Browser Client

Responsibilities:

- create or store Peer ID
- connect to signaling server
- display live peers
- create WebRTC offers
- answer inbound offers
- exchange ICE candidates
- open RTCDataChannel
- send direct messages

### FastAPI Signaling Server

Responsibilities:

- accept WebSocket clients
- register Peer IDs
- track online presence
- route `offer` messages
- route `answer` messages
- route `ice-candidate` messages
- remove disconnected peers

The server should not permanently store chat payloads.

## Message Flow

### Connection Setup

1. Browser connects to `/ws`
2. Browser sends `register`
3. Server broadcasts presence list
4. User selects target peer
5. Initiator sends WebRTC `offer`
6. Receiver responds with `answer`
7. Both sides exchange ICE candidates
8. Direct channel opens

### Chat Flow

After the direct channel opens:

```text
Browser A <-> RTCDataChannel <-> Browser B
```

Chat messages should bypass the server.

## Current Limitations

- No TURN relay fallback
- No signed identities
- No native Bluetooth transport
- No message persistence
- No group routing
- No multi-hop relay

## Recommended Next Architecture

## v3 Identity Layer

Add:

- public/private key pair per device
- signed peer handshake
- signed messages
- local key storage

## v4 Mesh Layer
nAdd:

- peer forwarding table
- TTL / hop count
- duplicate suppression by message ID
- optional store-and-forward queue

## v5 Mobile Bluetooth Layer

Add native transports:

- iOS CoreBluetooth
- Android BLE stack
- offline local packet relay

## Design Principle

Keep transports modular:

```text
identity layer
message layer
routing layer
transport layer
```

Where transport can be:

- WebRTC
- Bluetooth
- LAN / Wi-Fi Direct
- Future radio modules
