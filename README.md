# P2P Mesh v2

A decentralized-ready browser messenger using WebRTC DataChannels for direct peer-to-peer messaging and FastAPI WebSockets only for signaling.

Live demo: https://p2p-mesh.vercel.app

## Current Status

P2P Mesh v2 is no longer a basic WebSocket broadcast chat. The server is now a signaling layer. Chat messages are intended to move directly between browsers over WebRTC after peers connect.

## What Works Now

- WebRTC direct browser-to-browser messaging
- FastAPI WebSocket signaling server
- Peer ID registration
- Live peer presence
- Offer / answer / ICE candidate routing
- Direct RTCDataChannel chat payloads
- No persistent message storage
- Mobile-responsive browser UI

## What Is Not Supported Yet

- Bluetooth messaging
- Native iOS app
- Native Android app
- Multi-hop mesh forwarding
- Public/private key identity
- App-level end-to-end encryption
- TURN relay fallback for strict NAT networks
- Production authentication

## Network Model

```text
Browser A ── WebSocket signaling ── FastAPI ── WebSocket signaling ── Browser B

After negotiation:

Browser A ───────────── WebRTC RTCDataChannel ───────────── Browser B
```

The FastAPI server should exchange only signaling messages:

- `register`
- `presence`
- `offer`
- `answer`
- `ice-candidate`
- `ping` / `pong`

Chat payloads should move over the direct WebRTC data channel.

## Tech Stack

- Frontend: HTML5, CSS3, JavaScript
- Peer transport: WebRTC RTCDataChannel
- Signaling: FastAPI WebSocket
- Backend: Python, FastAPI, Uvicorn
- Deployment: Vercel
- NAT traversal: STUN only for now

## Local Development

```bash
git clone https://github.com/polydeuces32/p2p-mesh.git
cd p2p-mesh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python api/main.py
```

Open:

```text
http://localhost:8000
```

## Testing

Use two browser windows, two browsers, or two devices.

1. Open the app in both clients.
2. Set a different Peer ID in each client.
3. Click `Connect` on both clients.
4. Select the other peer from the live peer list.
5. Click `Open P2P Channel`.
6. Send a message.

## Security Notes

This is an early prototype. Do not treat it as production-secure yet.

Current security limitations:

- Peer IDs are user-entered and not verified.
- There is no public/private key identity yet.
- There is no app-level message signing yet.
- CORS is open for development.
- STUN is configured, but TURN fallback is not.

## Bluetooth Direction

This browser app does not send messages through Bluetooth devices.

Bluetooth mesh requires a separate native layer:

- iOS: Swift + CoreBluetooth
- Android: Kotlin + Bluetooth LE
- Shared packet protocol
- Local encrypted identity
- Offline relay / forwarding rules

The browser WebRTC version should remain the internet/direct-browser transport. Bluetooth should be treated as a future native mobile module.

## Project Direction

The strongest product path is:

```text
v2: WebRTC direct messaging
v3: cryptographic identity + message signing
v4: multi-peer mesh forwarding
v5: native Bluetooth offline mode
```

## Author

GiancarloV — https://github.com/polydeuces32
