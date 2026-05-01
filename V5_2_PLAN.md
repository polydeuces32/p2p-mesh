# P2P Mesh v5.2 Plan

## Goal

Make v5.1 usable across real devices and real networks by improving peer pairing, connection diagnostics, and NAT traversal readiness.

## v5.2 Scope

### 1. QR Peer Pairing
- Generate a QR code for local peer identity.
- Include peer ID, public key fingerprint, and optional room code.
- Allow another browser/device to paste or scan pairing data.
- Use pairing to reduce manual peer selection friction.

### 2. TURN Relay Readiness
- Keep Google STUN as default.
- Add config-ready TURN support through `window.P2P_ICE_SERVERS`.
- Document future TURN providers: Twilio Network Traversal, Metered.ca, Xirsys, self-hosted coturn.
- Do not hardcode paid TURN credentials in frontend code.

### 3. Mobile NAT Diagnostics
- Show signaling status.
- Show WebRTC connection state.
- Show ICE gathering state.
- Show selected peer and data channel state.
- Show clear failure messages when peers cannot connect.

### 4. Connection Quality Panel
- Display peer count.
- Display active channel state.
- Display pending ACK count.
- Display retry queue count.
- Display endpoint used for signaling.

### 5. Safer Fallback Behavior
- If Render signaling is asleep, show wake-up guidance.
- Keep identity available offline.
- Do not crash if WebSocket fails.
- Let user retry signaling manually.

## Not Included Yet

- Native Bluetooth transport.
- Persistent encrypted database.
- Real TURN credentials.
- Mobile app wrappers.
- Lightning/BTC extensions.

## Production Rule

v5.2 must preserve the working v5.1 deployment.

No backend-breaking changes unless paired with a deploy/test path.

## Suggested Implementation Order

1. Add diagnostics panel to frontend.
2. Add QR export/import pairing data.
3. Add ICE config override support.
4. Add connection state telemetry.
5. Test with two browsers on same machine.
6. Test with phone + desktop.
7. Add TURN provider documentation.
