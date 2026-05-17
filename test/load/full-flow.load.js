import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const loginDuration = new Trend('login_duration');
const profileDuration = new Trend('profile_duration');

export const options = {
  scenarios: {
    smoke: {
      executor: 'constant-vus',
      vus: 5,
      duration: '30s',
      tags: { test_type: 'smoke' },
    },
    load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 50 },
        { duration: '3m', target: 50 },
        { duration: '1m', target: 100 },
        { duration: '3m', target: 100 },
        { duration: '1m', target: 0 },
      ],
      startTime: '30s',
      tags: { test_type: 'load' },
    },
    stress: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 200 },
        { duration: '5m', target: 200 },
        { duration: '2m', target: 300 },
        { duration: '5m', target: 300 },
        { duration: '2m', target: 0 },
      ],
      startTime: '9m30s',
      tags: { test_type: 'stress' },
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1500'],
    errors: ['rate<0.05'],
    login_duration: ['p(95)<800'],
    profile_duration: ['p(95)<300'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const headers = { 'Content-Type': 'application/json' };

export function setup() {
  const res = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
    email: 'loadtest@test.com',
    password: 'TestPass123!',
  }), { headers });

  if (res.status !== 200) {
    console.warn('Setup login failed, tests will use per-VU login');
    return { token: null };
  }
  return { token: JSON.parse(res.body).accessToken };
}

export default function (data) {
  let token = data.token;

  group('Authentication', () => {
    if (!token) {
      const start = Date.now();
      const loginRes = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
        email: `user${__VU}@test.com`,
        password: 'TestPass123!',
      }), { headers });

      loginDuration.add(Date.now() - start);

      const success = check(loginRes, {
        'login returns 200': (r) => r.status === 200,
        'login has token': (r) => {
          try { return JSON.parse(r.body).accessToken !== undefined; }
          catch { return false; }
        },
      });

      if (!success) {
        errorRate.add(1);
        return;
      }

      token = JSON.parse(loginRes.body).accessToken;
    }
  });

  if (!token) return;

  const authHeaders = { ...headers, Authorization: `Bearer ${token}` };

  group('User Profile', () => {
    const start = Date.now();
    const res = http.get(`${BASE_URL}/api/users/me`, { headers: authHeaders });
    profileDuration.add(Date.now() - start);

    check(res, {
      'profile returns 200': (r) => r.status === 200,
      'profile has email': (r) => {
        try { return JSON.parse(r.body).email !== undefined; }
        catch { return false; }
      },
    }) || errorRate.add(1);
  });

  group('Restaurants List', () => {
    const res = http.get(
      `${BASE_URL}/api/food/restaurants?lat=10.77&lng=106.70&radius=5&page=1&limit=20`,
      { headers: authHeaders }
    );

    check(res, {
      'restaurants returns 200': (r) => r.status === 200,
      'restaurants has data': (r) => {
        try { return JSON.parse(r.body).data !== undefined; }
        catch { return false; }
      },
    }) || errorRate.add(1);
  });

  group('Ride History', () => {
    const res = http.get(
      `${BASE_URL}/api/rides/history?page=1&limit=10`,
      { headers: authHeaders }
    );

    check(res, {
      'ride history returns 200': (r) => r.status === 200,
    }) || errorRate.add(1);
  });

  group('Notifications', () => {
    const res = http.get(
      `${BASE_URL}/api/notifications?page=1&limit=20`,
      { headers: authHeaders }
    );

    check(res, {
      'notifications returns 200': (r) => r.status === 200,
    }) || errorRate.add(1);
  });

  sleep(Math.random() * 2 + 1);
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    'test/load/results/summary.json': JSON.stringify(data),
  };
}

function textSummary(data, opts) {
  // k6 built-in handles this when not overridden
  return '';
}
