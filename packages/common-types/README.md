# Crab Super App - Shared Types

Shared TypeScript type definitions used across all backend services and the web admin dashboard.

## Installation

This package is automatically available in the monorepo via pnpm workspaces:

```typescript
import { UserRole, RideStatus, Location } from '@crab/common-types';
```

## Contents

### Enums

- `UserRole` - rider, driver, restaurant_owner, admin
- `RideStatus` - SEARCHING, ACCEPTED, ARRIVING, IN_PROGRESS, COMPLETED, CANCELLED, NO_DRIVER
- `FoodOrderStatus` - PENDING, CONFIRMED, PREPARING, READY, PICKED_UP, DELIVERED, CANCELLED, REJECTED
- `VehicleType` - bike, car, car_plus
- `TransactionType` - topup, ride_payment, food_payment, refund, withdrawal
- `NotificationType` - ride_accepted, ride_completed, order_confirmed, etc.

### Interfaces

- `Location` - lat/lng/address
- `PaginationMeta` - page/limit/total/totalPages
- `PaginatedResponse<T>` - generic paginated response
- `ApiError` - standard error response
- `UserPayload` - JWT token payload
- `TokenPair` - access + refresh tokens

## Build

```bash
pnpm --filter @crab/common-types build
```
