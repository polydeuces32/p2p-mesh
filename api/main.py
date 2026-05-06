from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import json
import time
from pathlib import Path
from typing import Any, Dict, Optional

app = FastAPI(title="P2P Mesh Signaling API", version="0.2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# peer_id -> websocket
peer_sessions: Dict[str, WebSocket] = {}
# websocket -> peer_id
socket_peers: Dict[WebSocket, str] = {}

SIGNAL_TYPES = {"offer", "answer", "ice-candidate"}
PROJECT_ROOT = Path(__file__).resolve().parent.parent
INDEX_FILE = PROJECT_ROOT / "index.html"


def safe_json(raw: str) -> Optional[Dict[str, Any]]:
    try:
        payload = json.loads(raw)
        if isinstance(payload, dict):
            return payload
        return None
    except json.JSONDecodeError:
        return None


async def send_json(websocket: WebSocket, payload: Dict[str, Any]) -> None:
    await websocket.send_text(json.dumps(payload))


async def broadcast_presence() -> None:
    peers = sorted(peer_sessions.keys())
    message = {
        "type": "presence",
        "peers": peers,
        "connection_count": len(peers),
        "timestamp": time.time(),
    }

    dead = []
    for peer_id, websocket in peer_sessions.items():
        try:
            await send_json(websocket, message)
        except Exception:
            dead.append(peer_id)

    for peer_id in dead:
        websocket = peer_sessions.pop(peer_id, None)
        if websocket:
            socket_peers.pop(websocket, None)


async def register_peer(websocket: WebSocket, peer_id: str) -> None:
    old_socket = peer_sessions.get(peer_id)
    if old_socket and old_socket is not websocket:
        socket_peers.pop(old_socket, None)
        try:
            await old_socket.close(code=4000, reason="Peer ID reconnected")
        except Exception:
            pass

    peer_sessions[peer_id] = websocket
    socket_peers[websocket] = peer_id
    await send_json(
        websocket,
        {
            "type": "registered",
            "peer_id": peer_id,
            "peers": sorted(peer_sessions.keys()),
            "timestamp": time.time(),
        },
    )
    await broadcast_presence()


async def unregister_peer(websocket: WebSocket) -> None:
    peer_id = socket_peers.pop(websocket, None)
    if peer_id:
        peer_sessions.pop(peer_id, None)
        await broadcast_presence()


async def route_signal(sender_socket: WebSocket, message: Dict[str, Any]) -> None:
    sender_id = socket_peers.get(sender_socket)
    target_id = message.get("to")
    signal_type = message.get("type")

    if not sender_id:
        await send_json(sender_socket, {"type": "error", "error": "peer_not_registered"})
        return

    if signal_type not in SIGNAL_TYPES:
        await send_json(sender_socket, {"type": "error", "error": "invalid_signal_type"})
        return

    if not target_id or target_id not in peer_sessions:
        await send_json(
            sender_socket,
            {
                "type": "error",
                "error": "target_peer_offline",
                "to": target_id,
            },
        )
        return

    outbound = dict(message)
    outbound["from"] = sender_id
    outbound["timestamp"] = time.time()
    await send_json(peer_sessions[target_id], outbound)


@app.get("/")
async def root():
    return {
        "message": "P2P Mesh Signaling API",
        "status": "online",
        "mode": "webrtc-signaling",
        "connections": len(peer_sessions),
    }


@app.get("/health")
async def health():
    return {"status": "healthy", "timestamp": time.time()}


@app.get("/users")
async def get_users():
    return {
        "active_peers": sorted(peer_sessions.keys()),
        "connection_count": len(peer_sessions),
    }


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            raw = await websocket.receive_text()
            message = safe_json(raw)
            if not message:
                await send_json(websocket, {"type": "error", "error": "invalid_json"})
                continue

            message_type = message.get("type")

            if message_type == "register":
                peer_id = str(message.get("peer_id") or message.get("phone") or "").strip()
                if not peer_id:
                    await send_json(websocket, {"type": "error", "error": "missing_peer_id"})
                    continue
                await register_peer(websocket, peer_id)
                continue

            if message_type in SIGNAL_TYPES:
                await route_signal(websocket, message)
                continue

            if message_type == "ping":
                await send_json(websocket, {"type": "pong", "timestamp": time.time()})
                continue

            await send_json(websocket, {"type": "error", "error": "unknown_message_type"})

    except WebSocketDisconnect:
        await unregister_peer(websocket)
    except Exception:
        await unregister_peer(websocket)
        try:
            await websocket.close()
        except Exception:
            pass


@app.get("/{path:path}")
async def serve_static(path: str):
    requested_path = (PROJECT_ROOT / path).resolve()

    if requested_path.is_file() and PROJECT_ROOT in requested_path.parents:
        return FileResponse(requested_path)

    return FileResponse(INDEX_FILE)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
