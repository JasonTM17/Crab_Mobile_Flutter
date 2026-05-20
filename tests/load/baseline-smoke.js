// Crab baseline smoke test.
//
// Hits the liveness endpoint of every backend service so a failing pod
// surfaces immediately, before bigger scenarios (ride-flow, order-flow)
// run. Designed to be cheap enough to run on every PR.
//
// Run:
//   k6 run tests/load/baseline-smoke.js
//   k6 run -e BASE_HOST=staging.crab.app tests/load/baseline-smoke.js
//
// Thresholds: p99 < 200ms across all requests, 0% error rate.

import http from 'k6/http';
import { check, group, sleep } from 'k6';

const BASE_HOST = __ENV.BASE_HOST || 'localhost';
const SCHEME = __ENV.SCHEME || 'http';

// Service catalog: keep aligned with docker-compose.yml port mapping.
const SERVICES = [
  { name: 'gateway', port: 3000 },
  { name: 'auth', port: 3001 },
  { name: 'user', port: 3002 },
  { name: 'ride', port: 3003 },
  { name: 'food', port: 3004 },
  { name: 'payment', port: 3005 },
  { name: 'chat', port: 3006 },
  { name: 'notification', port: 3007 },
  { name: 'rating', port: 3008 },
];

export const options = {
  vus: 10,
  duration: '30s',
  thresholds: {
    http_req_failed: ['rate==0'],
    http_req_duration: ['p(99)<200'],
    checks: ['rate==1'],
  },
  tags: { suite: 'baseline-smoke' },
};

export default function () {
  for (const svc of SERVICES) {
    group(`healthz:${svc.name}`, () => {
      const url = `${SCHEME}://${BASE_HOST}:${svc.port}/healthz`;
      const res = http.get(url, {
        tags: { service: svc.name, endpoint: 'healthz' },
        timeout: '2s',
      });
      check(res, {
        [`${svc.name} healthz 200`]: (r) => r.status === 200,
        [`${svc.name} healthz body has status`]: (r) => {
          try {
            const body = r.json();
            return body && body.status === 'ok';
          } catch (_e) {
            return false;
          }
        },
      });
    });
  }
  sleep(1);
}
