from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import json
import time
import asyncio
from typing import List

app = FastAPI(title="P2P Mesh API")

# CORS middleware for web access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Store active connections
clients: List[WebSocket] = []
user_sessions = {}

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except:
                # Remove disconnected clients
                if connection in self.active_connections:
                    self.active_connections.remove(connection)

manager = ConnectionManager()

@app.get("/")
async def root():
    return {"message": "P2P Mesh API", "status": "online", "connections": len(manager.active_connections)}

@app.get("/health")
async def health():
    return {"status": "healthy", "timestamp": time.time()}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            
            # Store user phone number if provided
            if 'sender_phone' in message:
                user_sessions[message['sender_phone']] = websocket
                print(f"User {message['sender_phone']} connected")
            
            # Add connection info to message
            message['connection_count'] = len(manager.active_connections)
            message['active_users'] = list(user_sessions.keys())
            
            # Broadcast to all connected peers
            await manager.broadcast(json.dumps(message))
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        # Remove user from sessions
        for phone, conn in list(user_sessions.items()):
            if conn == websocket:
                del user_sessions[phone]
                print(f"User {phone} disconnected")

@app.get("/users")
async def get_users():
    return {
        "active_users": list(user_sessions.keys()),
        "connection_count": len(manager.active_connections)
    }

# Serve static files
@app.get("/{path:path}")
async def serve_static(path: str):
    if path == "" or path == "/":
        return FileResponse("public/index.html")
    return FileResponse(f"public/{path}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
