// Crab order-flow load test.
//
// Spike profile that emulates the food ordering surge experienced at
// lunch and dinner peaks: 100 concurrent VUs browsing restaurants,
// inspecting menus, placing orders, and polling status.
//
// Run:
//   k6 run tests/load/order-flow.js
//   k6 run -e BASE_URL=https://staging.crab.app tests/load/order-flow.js

import http from 'k6/http';
import { check, sleep, group, fail } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const JWT_TOKEN = __ENV.JWT_TOKEN || '';
const LOGIN_EMAIL = __ENV.LOGIN_EMAIL || 'loadtest@crab.dev';
const LOGIN_PASSWORD = __ENV.LOGIN_PASSWORD || 'LoadTest!2026';

const errorRate = new Rate('crab_order_errors');
const orderLatency = new Trend('crab_order_create_ms', true);

export const options = {
  scenarios: {
    order_spike: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 100 },
        { duration: '3m', target: 100 },
        { duration: '30s', target: 0 },
      ],
      gracefulRampDown: '15s',
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.02'],
    http_req_duration: ['p(95)<800'],
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
  errorRate.add(0);
  const body = res.json();
  return (body && (body.access_token || body.accessToken || body.token)) || '';
}

export function setup() {
  if (JWT_TOKEN) return { token: JWT_TOKEN };
  return { token: login() };
}

export default function (data) {
  const token = data.token || login();
  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };

  let restaurantId;
  let menuItemId;
  let orderId;

  group('list_restaurants', () => {
    const res = http.get(`${BASE_URL}/api/v1/restaurants?limit=20`, {
      headers,
      tags: { endpoint: 'restaurants_list' },
    });
    const ok = check(res, {
      'list 200': (r) => r.status === 200,
      'has restaurants': (r) => {
        try {
          const b = r.json();
          const items = (b && (b.data || b.items || b.restaurants)) || [];
          if (Array.isArray(items) && items.length > 0) {
            restaurantId = items[0].id || items[0]._id;
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
    const res = http.get(`${BASE_URL}/api/v1/restaurants/${restaurantId}/menu`, {
      headers,
      tags: { endpoint: 'restaurant_menu' },
    });
    const ok = check(res, {
      'menu 200': (r) => r.status === 200,
      'has items': (r) => {
        try {
          const b = r.json();
          const items = (b && (b.data || b.items || b.menu)) || [];
          if (Array.isArray(items) && items.length > 0) {
            menuItemId = items[0].id || items[0]._id;
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
      restaurant_id: restaurantId,
      items: [{ menu_item_id: menuItemId, quantity: 1 }],
      delivery_address: { lat: 10.7769, lng: 106.7009 },
      payment_method: 'wallet',
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
          const b = r.json();
          orderId = (b && (b.id || b.order_id)) || null;
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
