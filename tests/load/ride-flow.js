// Crab ride-flow load test.
//
// Steady-state simulation of signing in, requesting a ride, then polling the
// ride status. Defaults align with scripts/seed.sql demo accounts.
//
// Run:
//   k6 run tests/load/ride-flow.js
//   k6 run -e CRAB_RIDE_TARGET_VUS=10 -e CRAB_RIDE_DURATION=1m tests/load/ride-flow.js
//   k6 run -e BASE_URL=https://staging.crab.app -e JWT_TOKEN=... -e RIDER_ID=... tests/load/ride-flow.js

import http from 'k6/http';
import { check, sleep, group, fail } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const JWT_TOKEN = __ENV.JWT_TOKEN || '';
const RIDER_ID = __ENV.RIDER_ID || '';
const LOGIN_EMAIL = __ENV.LOGIN_EMAIL || 'rider@crab.app';
const LOGIN_PASSWORD = __ENV.LOGIN_PASSWORD || 'User123!';
const TARGET_VUS = positiveInt(__ENV.CRAB_RIDE_TARGET_VUS, 3);
const RAMP_DURATION = __ENV.CRAB_RIDE_RAMP_DURATION || '10s';
const STEADY_DURATION = __ENV.CRAB_RIDE_DURATION || '30s';

const errorRate = new Rate('crab_ride_errors');
const rideLatency = new Trend('crab_ride_request_ms', true);

export const options = {
  scenarios: {
    ride_flow: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: RAMP_DURATION, target: TARGET_VUS },
        { duration: STEADY_DURATION, target: TARGET_VUS },
        { duration: RAMP_DURATION, target: 0 },
      ],
      gracefulRampDown: '15s',
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<700'],
    crab_ride_errors: ['rate<0.01'],
  },
  tags: { suite: 'ride-flow' },
};

function login() {
  const res = http.post(
    `${BASE_URL}/api/v1/auth/login`,
    JSON.stringify({ email: LOGIN_EMAIL, password: LOGIN_PASSWORD }),
    { headers: { 'Content-Type': 'application/json' }, tags: { endpoint: 'login' } },
  );
  const ok = check(res, { 'login 200': (r) => r.status === 200 });
  if (!ok) {
    errorRate.add(1);
    fail(`login failed status=${res.status}`);
  }

  const body = res.json();
  const token = body && body.tokens && body.tokens.access_token;
  const userId = body && body.user && body.user.id;
  if (!token || !userId) {
    errorRate.add(1);
    fail('login response missing token or user id');
  }

  errorRate.add(0);
  return { token, userId };
}

export function setup() {
  if (JWT_TOKEN) return { token: JWT_TOKEN, userId: RIDER_ID };
  return login();
}

export default function (data) {
  const session = data.token ? data : login();
  if (!session.userId) {
    fail('RIDER_ID is required when JWT_TOKEN is provided');
  }

  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${session.token}`,
  };

  let rideId;

  group('request_ride', () => {
    const payload = JSON.stringify({
      rider_id: session.userId,
      pickup_lat: 10.7769,
      pickup_lng: 106.7009,
      pickup_address: 'Crab Load Pickup',
      dropoff_lat: 10.8015,
      dropoff_lng: 106.7147,
      dropoff_address: 'Crab Load Dropoff',
    });
    const started = Date.now();
    const res = http.post(`${BASE_URL}/api/v1/rides`, payload, {
      headers,
      tags: { endpoint: 'rides_create' },
    });
    rideLatency.add(Date.now() - started);
    const ok = check(res, {
      'request 200/201': (r) => r.status === 200 || r.status === 201,
      'has ride id': (r) => {
        try {
          const body = r.json();
          rideId = body && body.data && body.data.id;
          return Boolean(rideId);
        } catch (_e) {
          return false;
        }
      },
    });
    errorRate.add(!ok);
  });

  if (!rideId) {
    sleep(1);
    return;
  }

  for (let i = 0; i < 3; i++) {
    group('poll_ride', () => {
      const res = http.get(`${BASE_URL}/api/v1/rides/${rideId}`, {
        headers,
        tags: { endpoint: 'rides_get' },
      });
      const ok = check(res, { 'poll 200': (r) => r.status === 200 });
      errorRate.add(!ok);
    });
    sleep(2);
  }
}

function positiveInt(value, fallback) {
  const parsed = Number.parseInt(value || '', 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}
