# Payment Service

Manages digital wallet, transactions, and payment processing.

## Port: 3005

## Features
- Digital wallet management
- Top-up via multiple methods
- Ride/food payment processing
- Transaction history
- Refund handling
- Balance checks

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/payments/wallet` | Get wallet balance |
| POST | `/payments/topup` | Top up wallet |
| POST | `/payments/pay` | Process payment |
| GET | `/payments/transactions` | Transaction history |
| POST | `/payments/refund` | Process refund |
| GET | `/payments/methods` | Payment methods |

## Docker

```bash
docker build -f apps/backend/payment-service/Dockerfile -t nguyenson1710/crab-mobile-payment-service .
docker run -p 3005:3005 --env-file .env nguyenson1710/crab-mobile-payment-service
```
