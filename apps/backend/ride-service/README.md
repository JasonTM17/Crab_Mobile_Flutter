# Ride Service

Manages ride-hailing operations including booking, driver matching, tracking, and fare calculation.

## Port: 3003

## Features
- Ride creation and fare estimation
- Real-time driver matching algorithm
- Live location tracking via Socket.IO
- Ride status management (pending → searching → matched → pickup → in_progress → completed)
- Driver online/offline management
- Ride history and analytics
- Surge pricing calculation

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/rides` | Create new ride |
| POST | `/rides/estimate` | Estimate fare |
| GET | `/rides/active` | Get active ride |
| GET | `/rides/history` | Get ride history |
| POST | `/rides/:id/cancel` | Cancel ride |
| POST | `/rides/:id/accept` | Driver accepts ride |
| POST | `/rides/:id/reject` | Driver rejects ride |
| PATCH | `/rides/:id/status` | Update ride status |
| POST | `/driver/online` | Go online |
| POST | `/driver/offline` | Go offline |
| POST | `/driver/location` | Update driver location |

## Socket.IO Events (namespace: /ride)

| Event | Direction | Description |
|-------|-----------|-------------|
| `ride:request` | Server → Driver | New ride request |
| `ride:accepted` | Server → Rider | Driver accepted |
| `ride:status` | Server → Both | Status change |
| `driver:location` | Server → Rider | Driver position update |
| `ride:completed` | Server → Both | Ride summary |

## Docker

```bash
docker build -f apps/backend/ride-service/Dockerfile -t jasontm17/ride-service .
docker run -p 3003:3003 --env-file .env jasontm17/ride-service
```
