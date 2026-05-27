// Crab order-flow load test.
//
// Browses seeded restaurants, selects a menu item, creates an order, and checks
// status through the gateway. Defaults align with scripts/seed.sql.
//
// Run:
//   k6 run tests/load/order-flow.js
//   k6 run -e CRAB_ORDER_TARGET_VUS=10 -e CRAB_ORDER_DURATION=1m tests/load/order-flow.js
//   k6 run -e BASE_URL=https://staging.crab.app tests/load/order-flow.js

import http from 'k6/http';
import { check, sleep, group, fail } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const JWT_TOKEN = __ENV.JWT_TOKEN || '';
const RIDER_ID = __ENV.RIDER_ID || '';
const LOGIN_EMAIL = __ENV.LOGIN_EMAIL || 'rider@crab.app';
const LOGIN_PASSWORD = __ENV.LOGIN_PASSWORD || 'User123!';
const TARGET_VUS = positiveInt(__ENV.CRAB_ORDER_TARGET_VUS, 3);
const RAMP_DURATION = __ENV.CRAB_ORDER_RAMP_DURATION || '10s';
const STEADY_DURATION = __ENV.CRAB_ORDER_DURATION || '30s';

const errorRate = new Rate('crab_order_errors');
const orderLatency = new Trend('crab_order_create_ms', true);

export const options = {
  scenarios: {
    order_flow: {
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
    http_req_failed: ['rate<0.02'],
    http_req_duration: ['p(95)<900'],
    crab_order_errors: ['rate<0.02'],
  },
  tags: { suite: 'order-flow' },
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

  let restaurantId;
  let menuItemId;
  let orderId;

  group('list_restaurants', () => {
    const res = http.get(`${BASE_URL}/api/v1/restaurants/search`, {
      headers,
      tags: { endpoint: 'restaurants_search' },
    });
    const ok = check(res, {
      'list 200': (r) => r.status === 200,
      'has restaurants': (r) => {
        try {
          const body = r.json();
          const items = (body && body.data) || [];
          if (Array.isArray(items) && items.length > 0) {
            restaurantId = items[0].id;
            return true;
          }
          return false;
        } catch (_e) {
          return false;
        }
      },
    });
    errorRate.add(!ok);
  });

  if (!restaurantId) {
    sleep(1);
    return;
  }

  group('get_menu', () => {
    const res = http.get(`${BASE_URL}/api/v1/menus/items/restaurant/${restaurantId}`, {
      headers,
      tags: { endpoint: 'menu_items' },
    });
    const ok = check(res, {
      'menu 200': (r) => r.status === 200,
      'has items': (r) => {
        try {
          const items = res.json();
          if (Array.isArray(items) && items.length > 0) {
            menuItemId = items[0].id;
            return true;
          }
          return false;
        } catch (_e) {
          return false;
        }
      },
    });
    errorRate.add(!ok);
  });

  if (!menuItemId) {
    sleep(1);
    return;
  }

  group('place_order', () => {
    const payload = JSON.stringify({
      customerId: session.userId,
      restaurantId,
      items: [{ menuItemId, quantity: 1 }],
      deliveryLat: 10.7769,
      deliveryLng: 106.7009,
      deliveryAddress: 'Crab Load Delivery Address',
      paymentMethod: 'WALLET',
    });
    const started = Date.now();
    const res = http.post(`${BASE_URL}/api/v1/orders`, payload, {
      headers,
      tags: { endpoint: 'orders_create' },
    });
    orderLatency.add(Date.now() - started);
    const ok = check(res, {
      'order 200/201': (r) => r.status === 200 || r.status === 201,
      'has order id': (r) => {
        try {
          const body = r.json();
          orderId = body && body.id;
          return Boolean(orderId);
        } catch (_e) {
          return false;
        }
      },
    });
    errorRate.add(!ok);
  });

  if (!orderId) {
    sleep(1);
    return;
  }

  group('get_order_status', () => {
    const res = http.get(`${BASE_URL}/api/v1/orders/${orderId}`, {
      headers,
      tags: { endpoint: 'orders_get' },
    });
    const ok = check(res, { 'status 200': (r) => r.status === 200 });
    errorRate.add(!ok);
  });

  sleep(2);
}

function positiveInt(value, fallback) {
  const parsed = Number.parseInt(value || '', 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}
