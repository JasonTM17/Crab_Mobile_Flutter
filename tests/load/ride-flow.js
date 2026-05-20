// Crab ride-flow load test.
//
// Steady-state simulation of the most contended user journey: signing in,
// requesting a ride, then polling the ride status until it terminates.
//
// Run:
//   k6 run tests/load/ride-flow.js
//   k6 run -e BASE_URL=https://staging.crab.app -e JWT_TOKEN=... tests/load/ride-flow.js

import http from 'k6/http';
import { check, sleep, group, fail } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const JWT_TOKEN = __ENV.JWT_TOKEN || '';
const LOGIN_EMAIL = __ENV.LOGIN_EMAIL || 'loadtest@crab.dev';
const LOGIN_PASSWORD = __ENV.LOGIN_PASSWORD || 'LoadTest!2026';

const errorRate = new Rate('crab_ride_errors');
const rideLatency = new Trend('crab_ride_request_ms', true);

export const options = {
  scenarios: {
    ride_flow: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 200 },
        { duration: '5m', target: 200 },
        { duration: '1m', target: 0 },
      ],
      gracefulRampDown: '30s',
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
    crab_ride_errors: ['rate<0.01'],
  },
  tags: { suite: 'ride-flow' },
};

function loginIfNeeded() {
  if (JWT_TOKEN) return JWT_TOKEN;
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
  errorRate.add(0);
  const body = res.json();
  return (body && (body.access_token || body.accessToken || body.token)) || '';
}

export function setup() {
  // One-shot login when JWT_TOKEN is supplied so VUs share it.
  if (JWT_TOKEN) return { token: JWT_TOKEN };
  return { token: loginIfNeeded() };
}

export default function (data) {
  const token = data.token || loginIfNeeded();
  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };

  let rideId;

  group('request_ride', () => {
    const payload = JSON.stringify({
      pickup: { lat: 10.7769, lng: 106.7009 },
      dropoff: { lat: 10.7626, lng: 106.6823 },
      vehicle_type: 'bike',
    });
    const started = Date.now();
    const res = http.post(`${BASE_URL}/api/v1/rides/request`, payload, {
      headers,
      tags: { endpoint: 'rides_request' },
    });
    rideLatency.add(Date.now() - started);
    const ok = check(res, {
      'request 200/201': (r) => r.status === 200 || r.status === 201,
      'has ride id': (r) => {
        try {
          const b = r.json();
          rideId = (b && (b.id || b.ride_id)) || null;
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

  for (let i = 0; i < 5; i++) {
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
