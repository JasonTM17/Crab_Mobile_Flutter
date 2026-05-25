# Testing Guide

## Overview

Crab uses a multi-layer testing strategy:

| Layer | Tool | Scope |
|-------|------|-------|
| Unit Tests | Jest | Individual functions, services, utilities |
| Integration Tests | Jest + Supertest | API endpoints, database queries |
| E2E Tests | Jest + Supertest | Full request lifecycle through Gateway |
| Load Tests | k6 | Performance under concurrent load |
| WebSocket Tests | Jest + socket.io-client | Real-time event flows |
| Mobile Tests | Flutter test | Widget and BLoC tests |

## Running Tests

```bash
# Run all tests
pnpm test

# Run tests for specific service
pnpm --filter @crab/auth-service test
pnpm --filter @crab/ride-service test

# Run with coverage
pnpm test -- --coverage

# Run in watch mode
pnpm --filter @crab/gateway test:watch

# Run E2E tests (requires running services)
pnpm test:e2e
```

## Test Structure

```
apps/backend/<service>/
├── src/
│   ├── modules/
│   │   └── auth/
│   │       ├── auth.service.ts
│   │       ├── auth.controller.ts
│   │       └── __tests__/
│   │           ├── auth.service.spec.ts    # Unit tests
│   │           └── auth.controller.spec.ts # Integration tests
│   └── ...
└── test/
    ├── e2e/
    │   └── auth.e2e-spec.ts            # E2E tests
    ├── load/
    │   └── auth.load.js                # k6 load tests
    └── fixtures/
        └── users.fixture.ts            # Test data
```

## Unit Tests

Test individual service methods in isolation.

```typescript
// auth.service.spec.ts
import { Test } from '@nestjs/testing';
import { AuthService } from '../auth.service';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../../users/users.service';

describe('AuthService', () => {
  let authService: AuthService;
  let jwtService: JwtService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: JwtService, useValue: { sign: jest.fn(), verify: jest.fn() } },
        { provide: UsersService, useValue: { findByEmail: jest.fn() } },
      ],
    }).compile();

    authService = module.get(AuthService);
    jwtService = module.get(JwtService);
  });

  describe('validateUser', () => {
    it('should return user when credentials are valid', async () => {
      // arrange, act, assert
    });

    it('should throw UnauthorizedException for invalid password', async () => {
      // ...
    });
  });
});
```

## Integration Tests

Test API endpoints with real database connections.

```typescript
// auth.controller.spec.ts
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../../app.module';

describe('AuthController (Integration)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = module.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /auth/register', () => {
    it('should register a new user', () => {
      return request(app.getHttpServer())
        .post('/auth/register')
        .send({
          email: 'test@example.com',
          password: 'SecurePass123!',
          fullName: 'Test User',
          phone: '+84901234567',
          role: 'rider',
        })
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body.email).toBe('test@example.com');
        });
    });

    it('should reject duplicate email', () => {
      return request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'test@example.com', password: 'Pass123!' })
        .expect(409);
    });

    it('should validate email format', () => {
      return request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'invalid', password: 'Pass123!' })
        .expect(400);
    });
  });

  describe('POST /auth/login', () => {
    it('should return tokens for valid credentials', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'test@example.com', password: 'SecurePass123!' })
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('tokens.access_token');
          expect(res.body).toHaveProperty('tokens.refresh_token');
        });
    });

    it('should reject invalid password', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'test@example.com', password: 'wrong' })
        .expect(401);
    });
  });
});
```

## Load Tests (k6)

Performance testing under concurrent load.

```javascript
// test/load/auth.load.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 50 },   // ramp up
    { duration: '1m', target: 100 },   // sustained load
    { duration: '30s', target: 200 },  // peak
    { duration: '30s', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    errors: ['rate<0.05'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  // Login flow
  const loginRes = http.post(`${BASE_URL}/api/v1/auth/login`, JSON.stringify({
    email: `user${__VU}@test.com`,
    password: 'TestPass123!',
  }), { headers: { 'Content-Type': 'application/json' } });

  check(loginRes, {
    'login status 200': (r) => r.status === 200,
    'has access token': (r) => JSON.parse(r.body).tokens?.access_token !== undefined,
  }) || errorRate.add(1);

  if (loginRes.status === 200) {
    const token = JSON.parse(loginRes.body).tokens.access_token;
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    };

    // Get profile
    const profileRes = http.get(`${BASE_URL}/api/v1/profiles/${__VU}`, { headers });
    check(profileRes, { 'profile status 200': (r) => r.status === 200 });

    // List restaurants
    const restaurantsRes = http.get(
      `${BASE_URL}/api/v1/restaurants/search?latitude=10.77&longitude=106.70&radiusKm=5`,
      { headers }
    );
    check(restaurantsRes, { 'restaurants status 200': (r) => r.status === 200 });
  }

  sleep(1);
}
```

### Running Load Tests

```bash
# Install k6
brew install grafana/k6/k6  # macOS
# or: docker run --rm -i grafana/k6 run - < test/load/auth.load.js

# Run load test
k6 run test/load/auth.load.js

# With custom base URL
k6 run -e BASE_URL=http://staging.example.com test/load/auth.load.js
```

## WebSocket Tests

```typescript
// test/e2e/ride-socket.e2e-spec.ts
import { io, Socket } from 'socket.io-client';

describe('Ride WebSocket (E2E)', () => {
  let riderSocket: Socket;
  let driverSocket: Socket;

  beforeAll(async () => {
    const riderToken = await getToken('rider@test.com');
    const driverToken = await getToken('driver@test.com');

    riderSocket = io('http://localhost:3000/ride', {
      auth: { token: `Bearer ${riderToken}` },
      transports: ['websocket'],
    });

    driverSocket = io('http://localhost:3000/ride', {
      auth: { token: `Bearer ${driverToken}` },
      transports: ['websocket'],
    });

    await Promise.all([
      new Promise((r) => riderSocket.on('connect', r)),
      new Promise((r) => driverSocket.on('connect', r)),
    ]);
  });

  afterAll(() => {
    riderSocket.disconnect();
    driverSocket.disconnect();
  });

  it('should broadcast a ride request', (done) => {
    driverSocket.on('ride:new_request', (data) => {
      expect(data.pickup).toBeDefined();
      expect(data.dropoff).toBeDefined();
      done();
    });

    riderSocket.emit('ride:request', {
      riderId: 'rider-id',
      pickup: { lat: 10.77, lng: 106.70, address: 'Test' },
      dropoff: { lat: 10.80, lng: 106.71, address: 'Test 2' },
      paymentMethod: 'wallet',
    });
  });

  it('should handle ride cancellation', (done) => {
    riderSocket.on('ride:cancelled', (data) => {
      expect(data.rideId).toBe('test-id');
      done();
    });

    riderSocket.emit('ride:cancel', { rideId: 'test-id', reason: 'Test' });
  });
});
```

## Rate Limiting Tests

```typescript
// test/e2e/rate-limit.e2e-spec.ts
import * as request from 'supertest';

describe('Rate Limiting', () => {
  it('should enforce rate limits (100 req/min)', async () => {
    const requests = Array.from({ length: 105 }, () =>
      request(app).get('/api/v1/profiles/test-user-id').set('Authorization', `Bearer ${token}`)
    );

    const responses = await Promise.all(requests);
    const rateLimited = responses.filter((r) => r.status === 429);

    expect(rateLimited.length).toBeGreaterThan(0);
    expect(rateLimited[0].body.message).toContain('Rate limit exceeded');
  });

  it('should return rate limit headers', async () => {
    const res = await request(app)
      .get('/api/v1/profiles/test-user-id')
      .set('Authorization', `Bearer ${token}`);

    expect(res.headers).toHaveProperty('x-ratelimit-limit');
    expect(res.headers).toHaveProperty('x-ratelimit-remaining');
    expect(res.headers).toHaveProperty('x-ratelimit-reset');
  });
});
```

## Test Configuration

### Jest Config (per service)

```javascript
// jest.config.js
module.exports = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\.spec\\.ts$',
  transform: { '^.+\\.(t|j)s$': 'ts-jest' },
  collectCoverageFrom: ['**/*.(t|j)s', '!**/*.module.ts', '!**/main.ts'],
  coverageDirectory: '../coverage',
  testEnvironment: 'node',
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

### Test Database

Integration tests use a separate database:

```bash
# .env.test
DATABASE_URL=postgresql://crab:crab@localhost:5432/crab_test
MONGODB_URI=mongodb://crab:crab@localhost:27017/crab_test
REDIS_URL=redis://localhost:6379/1
```

## Coverage Requirements

| Service | Min Coverage |
|---------|-------------|
| Auth | 90% |
| Payment | 90% |
| Gateway | 85% |
| Ride | 80% |
| Food | 80% |
| User | 80% |
| Chat | 75% |
| Notification | 75% |
| Rating | 75% |
