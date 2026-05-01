# P2P Mesh v5.1 External FastAPI Signaling Backend

## Goal
Deploy signaling outside Vercel so WebSocket presence and peer discovery are reliable.

## Recommended Host
- Render (simplest)
- Railway
- Fly.io

## Included Files
- `api/main.py`
- `requirements.txt`
- `render.yaml`

## Render Steps
1. Create Render account.
2. New Web Service.
3. Connect GitHub repo: `polydeuces32/p2p-mesh`.
4. Render auto-detects `render.yaml`.
5. Deploy.

## Expected URL
`https://p2p-mesh-signaling.onrender.com`

## Health Check
`/health`

## WebSocket Endpoint
`wss://p2p-mesh-signaling.onrender.com/ws`

## Frontend Update Needed
Replace same-origin signaling with:

```js
const SIGNAL_URL = 'wss://p2p-mesh-signaling.onrender.com/ws'
```

## Production Benefits
- Persistent WebSocket support
- Reliable peer presence updates
- Better separation of frontend/backend
- Safer scaling path
