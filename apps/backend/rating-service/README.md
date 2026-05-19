# Rating Service

Manages ratings, reviews, and feedback for rides and food orders.

## Port: 3008

## Features
- Star ratings (1-5) for rides and orders
- Text reviews with tags
- Rating aggregation and statistics
- Driver/restaurant average scores
- Review replies from drivers/restaurants
- Report inappropriate reviews

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/ratings` | Submit rating |
| GET | `/ratings/driver/:id` | Get driver ratings |
| GET | `/ratings/restaurant/:id` | Get restaurant ratings |
| GET | `/ratings/user/:id` | Get user's given ratings |
| GET | `/ratings/:id/stats` | Rating statistics |
| POST | `/ratings/:id/reply` | Reply to review |
| POST | `/ratings/:id/report` | Report review |

## Rating Tags

**Ride tags:** Clean car, Good driving, Friendly, Fast pickup, Safe driving  
**Food tags:** Fast delivery, Good packaging, Fresh food, Accurate order, Friendly driver

## Docker

```bash
docker build -f apps/backend/rating-service/Dockerfile -t jasontm17/rating-service .
docker run -p 3008:3008 --env-file .env jasontm17/rating-service
```
