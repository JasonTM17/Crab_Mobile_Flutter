# Chat Service

Real-time messaging between riders and drivers using Socket.IO with Redis adapter.

## Port: 3006

## Features
- Real-time 1:1 messaging
- Message persistence in MongoDB
- Read receipts
- Typing indicators
- Chat history retrieval
- File/image sharing support
- Online presence tracking

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/chat/conversations` | List conversations |
| GET | `/chat/conversations/:id` | Get conversation messages |
| POST | `/chat/conversations` | Create conversation |
| POST | `/chat/messages` | Send message (REST fallback) |
| PATCH | `/chat/messages/:id/read` | Mark as read |

## Socket.IO Events (namespace: /chat)

| Event | Direction | Description |
|-------|-----------|-------------|
| `message:send` | Client → Server | Send message |
| `message:new` | Server → Client | New message received |
| `message:read` | Both | Read receipt |
| `typing:start` | Both | User started typing |
| `typing:stop` | Both | User stopped typing |
| `user:online` | Server → Client | User came online |
| `user:offline` | Server → Client | User went offline |

## Docker

```bash
docker build -t ghcr.io/jasontm17/crab-chat-service .
docker run -p 3006:3006 --env-file .env ghcr.io/jasontm17/crab-chat-service
```
