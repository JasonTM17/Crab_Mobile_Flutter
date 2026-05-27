// Crab baseline smoke load test.
//
// Cheap k6 check for the local production-like gateway. It intentionally
// targets gateway routes only because docker-compose.prod.yml exposes the
// gateway/nginx edge, not every internal microservice port.
//
// Run:
//   k6 run tests/load/baseline-smoke.js
//   k6 run -e BASE_URL=https://staging.crab.app tests/load/baseline-smoke.js

import http from 'k6/http';
import { check, group, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export const options = {
  vus: 5,
  duration: '30s',
  thresholds: {
    http_req_failed: ['rate==0'],
    http_req_duration: ['p(99)<500'],
    checks: ['rate==1'],
  },
  tags: { suite: 'baseline-smoke' },
};

export default function () {
  group('gateway_health', () => {
    const res = http.get(`${BASE_URL}/health`, {
      tags: { service: 'gateway', endpoint: 'health' },
      timeout: '2s',
    });
    check(res, {
      'gateway health 200': (r) => r.status === 200,
      'gateway status ok': (r) => {
        try {
          return r.json().status === 'ok';
        } catch (_e) {
          return false;
        }
      },
    });
  });

  group('proxy_health', () => {
    const res = http.get(`${BASE_URL}/api/v1/proxy/health`, {
      tags: { service: 'gateway', endpoint: 'proxy_health' },
      timeout: '2s',
    });
    check(res, {
      'proxy health 200': (r) => r.status === 200,
      'proxy gateway ok': (r) => {
        try {
          return r.json().gateway === 'ok';
        } catch (_e) {
          return false;
        }
      },
    });
  });

  sleep(1);
}
