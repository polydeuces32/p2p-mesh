# P2P Mesh v5 Safe Upgrade Plan

## Goal

Move P2P Mesh from a recovered frontend prototype into a real decentralized communications system without breaking the current production deployment.

## Current Stable State

- Root `index.html` serves the working v4.1 frontend.
- Vercel deployment works for the browser UI.
- Browser identity, signed messages, ACK/retry queue, TTL packet schema, and mesh-ready hooks exist in the frontend.

## v5 Principle

Do not overload Vercel with persistent WebSocket signaling.

Use this split:

```text
Frontend: Vercel
Signaling backend: Render, Railway, or Fly.io
Peer transport: WebRTC DataChannel
Future local transport: native Bluetooth app layer
```

## Why This Split

Vercel is strong for static frontends and serverless endpoints. Persistent WebSocket signaling is better handled by a long-running backend host.

## v5 Architecture

```text
Browser Client
  |
  | HTTPS static UI
  v
Vercel Frontend

Browser Client
  |
  | WSS signaling
  v
Render/Railway/Fly.io FastAPI Signaling Server

Browser A <-------- WebRTC DataChannel --------> Browser B
```

## v5 Frontend Changes

- Add configurable signaling URL.
- Prefer `window.P2P_SIGNALING_URL` when available.
- Fall back to same-origin `/ws` for local development.
- Show active signaling endpoint in the UI.
- Keep v4.1 identity and message reliability intact.

## v5 Backend Changes

- Deploy `api/main.py` to Render/Railway/Fly.io.
- Expose `/health` for uptime checks.
- Expose `/ws` for peer signaling.
- Restrict CORS before production use.
- Add rate limiting before public launch.

## v5 Security Work

- Signed device identity stays in browser.
- Message signatures stay client-side.
- Backend routes only offers, answers, ICE candidates, and presence.
- Backend should not store chat payloads.

## v5 Roadmap

### v5.0
- Stable Vercel frontend
- External signaling backend plan
- Configurable signaling endpoint

### v5.1
- Deploy backend to Render/Railway/Fly.io
- Connect frontend to remote `wss://.../ws`
- Add health/status diagnostics

### v5.2
- QR peer pairing
- Fingerprint verification UI
- Connection quality indicators

### v5.3
- Multi-peer channel map
- Real mesh relay graph
- Group broadcast routing

### v5.4
- PWA install support
- Offline queue persistence
- Local message history

### v6
- Native Bluetooth transport
- iOS CoreBluetooth
- Android BLE
- Optional Lightning/BTC extensions

## Production Rule

Keep the frontend deployable even if the signaling backend is offline.

The app should degrade gracefully:

```text
Frontend online
Identity available
Signaling offline warning shown
No hard crash
```
