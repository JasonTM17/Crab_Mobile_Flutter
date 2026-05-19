import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const rateLimitHits = new Rate('rate_limit_hits');

export const options = {
  scenarios: {
    burst: {
      executor: 'per-vu-iterations',
      vus: 1,
      iterations: 150,
      maxDuration: '30s',
    },
  },
  thresholds: {
    rate_limit_hits: ['rate>0.3'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export function setup() {
  const res = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
    email: 'ratelimit@test.com',
    password: 'TestPass123!',
  }), { headers: { 'Content-Type': 'application/json' } });

  if (res.status === 200) {
    return { token: JSON.parse(res.body).accessToken };
  }
  return { token: null };
}

export default function (data) {
  if (!data.token) return;

  const res = http.get(`${BASE_URL}/api/users/me`, {
    headers: { Authorization: `Bearer ${data.token}` },
  });

  if (res.status === 429) {
    rateLimitHits.add(1);

    check(res, {
      'rate limit returns 429': (r) => r.status === 429,
      'rate limit has retry header': (r) => r.headers['X-Ratelimit-Reset'] !== undefined,
    });
  } else {
    rateLimitHits.add(0);
    check(res, {
      'normal request returns 200': (r) => r.status === 200,
    });
  }
}
