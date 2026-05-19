import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Counter } from 'k6/metrics';

const errors = new Rate('errors');
const rideRequests = new Counter('ride_requests');

export const options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '2m', target: 50 },
    { duration: '1m', target: 100 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    errors: ['rate<0.1'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
const headers = { 'Content-Type': 'application/json' };

export function setup() {
  const res = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
    email: 'rider-load@test.com',
    password: 'TestPass123!',
  }), { headers });

  if (res.status === 200) {
    return { token: JSON.parse(res.body).accessToken };
  }
  return { token: null };
}

export default function (data) {
  if (!data.token) return;

  const authHeaders = { ...headers, Authorization: `Bearer ${data.token}` };

  // Request a ride
  const rideRes = http.post(`${BASE_URL}/api/rides`, JSON.stringify({
    pickupLocation: {
      lat: 10.7769 + (Math.random() * 0.01),
      lng: 106.7009 + (Math.random() * 0.01),
      address: `${Math.floor(Math.random() * 999)} Test Street`,
    },
    dropoffLocation: {
      lat: 10.8021 + (Math.random() * 0.01),
      lng: 106.7146 + (Math.random() * 0.01),
      address: `${Math.floor(Math.random() * 999)} Destination Ave`,
    },
    vehicleType: ['bike', 'car', 'car_plus'][Math.floor(Math.random() * 3)],
  }), { headers: authHeaders });

  rideRequests.add(1);

  const success = check(rideRes, {
    'ride request returns 201': (r) => r.status === 201,
    'ride has id': (r) => {
      try { return JSON.parse(r.body).id !== undefined; }
      catch { return false; }
    },
    'ride status is SEARCHING': (r) => {
      try { return JSON.parse(r.body).status === 'SEARCHING'; }
      catch { return false; }
    },
  });

  if (!success) errors.add(1);
  else errors.add(0);

  // Check ride status
  if (rideRes.status === 201) {
    const rideId = JSON.parse(rideRes.body).id;
    sleep(1);

    const statusRes = http.get(`${BASE_URL}/api/rides/${rideId}`, { headers: authHeaders });
    check(statusRes, {
      'ride status returns 200': (r) => r.status === 200,
    });

    // Cancel ride
    const cancelRes = http.post(`${BASE_URL}/api/rides/${rideId}/cancel`, JSON.stringify({
      reason: 'Load test cleanup',
    }), { headers: authHeaders });

    check(cancelRes, {
      'ride cancel returns 200': (r) => r.status === 200,
    });
  }

  sleep(Math.random() * 3 + 1);
}
