# P2P Mesh v5.3a

A decentralized-ready browser messenger using WebRTC DataChannels for direct peer-to-peer messaging and FastAPI WebSockets only for signaling.

Live demo: https://p2p-mesh-simple.vercel.app

## Current Status

P2P Mesh v5.3a is now a browser-based peer messaging prototype with external Render signaling, WebRTC DataChannels, cryptographic browser identity, QR pairing export, paste-based pairing import, diagnostics, and one-click imported peer connect.

## What Works Now

- Vercel-hosted frontend
- Render-hosted FastAPI signaling backend
- WebRTC direct browser-to-browser messaging
- FastAPI WebSocket signaling server
- Browser-generated public/private key identity
- Public identity export
- QR pairing export
- Paste-based pairing import
- Imported peer storage in browser local storage
- One-click imported peer connect
- Live peer presence
- Offer / answer / ICE candidate routing
- Direct RTCDataChannel chat payloads
- Diagnostics panel for WebSocket, WebRTC, ICE, DataChannel, peers, ACKs, and retry queue
- No persistent server-side message storage
- Mobile-responsive browser UI

## What Is Not Supported Yet

- Camera QR scanning
- Native Bluetooth messaging
- Native iOS app
- Native Android app
- Production TURN relay fallback for strict NAT networks
- Production authentication
- Audited end-to-end encryption

## Network Model

```text
Browser A ── WebSocket signaling ── Render FastAPI ── WebSocket signaling ── Browser B

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

## Production URLs

Frontend:

```text
https://p2p-mesh-simple.vercel.app
```

Signaling backend:

```text
https://p2p-mesh-signaling.onrender.com
```

WebSocket endpoint:

```text
wss://p2p-mesh-signaling.onrender.com/ws
```

## Tech Stack

- Frontend: HTML5, CSS3, JavaScript
- Peer transport: WebRTC RTCDataChannel
- Signaling: FastAPI WebSocket
- Backend: Python, FastAPI, Uvicorn
- Frontend deployment: Vercel
- Backend deployment: Render
- NAT traversal: STUN by default; TURN-ready configuration hook

## Local Development

```bash
git clone https://github.com/polydeuces32/p2p-mesh.git
cd p2p-mesh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn api.main:app --host 0.0.0.0 --port 8000
```

Open:

```text
http://localhost:8000
```

## Testing

Use two browser windows, two browsers, or two devices.

1. Open the live app on both clients.
2. Click `Create / Load` on both clients.
3. Click `Wake Backend` if Render is asleep.
4. Click `Connect` on both clients.
5. Copy pairing payload from Device A.
6. Paste it into `Import Pairing` on Device B.
7. Click `Import Peer`.
8. Click `Connect Imported`.
9. Send a message.

## Security Notes

This is still a prototype. Do not treat it as production-secure yet.

Current security limitations:

- Browser keys are stored in local storage.
- The app has message signing, but it has not been independently audited.
- CORS is open for development.
- STUN is configured, but production TURN fallback is not deployed yet.
- The Render signaling server should be rate-limited before public launch.

## Bluetooth Direction

This browser app does not send messages through Bluetooth devices yet.

Bluetooth mesh requires a separate native layer:

- iOS: Swift + CoreBluetooth
- Android: Kotlin + Bluetooth LE
- Shared packet protocol
- Local encrypted identity
- Offline relay / forwarding rules

The browser WebRTC version should remain the internet/direct-browser transport. Bluetooth should be treated as a future native mobile module.

## Project Direction

```text
v5.3a: pairing import + one-click connect
v5.3b: camera QR scanner + auto-import
v5.4: TURN relay + stronger mobile network traversal
v6: native Bluetooth offline mode
```

## Author

GiancarloV — https://github.com/polydeuces32
