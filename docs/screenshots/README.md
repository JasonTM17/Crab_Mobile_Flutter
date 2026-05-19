# Screenshots Gallery

Captured UI screenshots of the Crab Super App admin dashboard. All shots taken at 1440x900 viewport with the production Vite build served locally.

## Web Admin Dashboard

### Login Screen
![Login](admin-01-login.png)

Phone/email login form with Tailwind + shadcn/ui styling. JWT-based auth flow with refresh token rotation.

### Dashboard Overview
![Dashboard](admin-02-dashboard.png)

Top-level KPI cards: total users, active rides, today revenue, pending orders. Sidebar navigation to all admin sections.

### Users Management
![Users](admin-03-users.png)

Paginated user table with name/email/phone search, status badges (ACTIVE / SUSPENDED / PENDING_VERIFICATION), role tags.

### Driver Verification Queue
![Drivers](admin-04-drivers.png)

Pending driver applications with license number, vehicle info, plate, and approve/reject actions. Calls `/verification/drivers/admin/pending`.

### Rides Monitoring
![Rides](admin-05-rides.png)

Real-time rides table with rider/driver IDs, status, fare, distance, and timestamp. For live ride tracking and fraud detection.

### Orders Monitoring
![Orders](admin-06-orders.png)

Food delivery orders by restaurant. Status timeline (PLACED → CONFIRMED → PREPARING → READY → PICKED_UP → DELIVERED).

### Dashboard (Final)
![Dashboard final](admin-07-dashboard-final.png)

Re-captured dashboard after navigating through all sections to verify state persistence.

---

## How these were captured

```bash
# Build web-admin
cd apps/web-admin && pnpm build

# Serve production build
node static-server.js  # serves dist/ on :5174

# Capture via Playwright MCP at 1440x900
playwright_browser_navigate http://localhost:5174
playwright_browser_take_screenshot --fullPage --type png
```

## Mobile Viewport (390x812 - iPhone)

The web admin is also responsive. Same screens captured at iPhone-sized viewport:

### Mobile Dashboard
![Mobile Dashboard](admin-mobile-01-dashboard.png)

### Mobile Login
![Mobile Login](admin-mobile-02-login.png)

### Mobile Users
![Mobile Users](admin-mobile-03-users.png)

### Mobile Drivers
![Mobile Drivers](admin-mobile-04-drivers.png)

### Mobile Rides
![Mobile Rides](admin-mobile-05-rides.png)

### Mobile Orders
![Mobile Orders](admin-mobile-06-orders.png)

---

## Mobile (Flutter) Screenshots

Mobile screenshots are best captured via:

```bash
cd apps/mobile
flutter run -d <device>
# Use device's screenshot capability or `flutter screenshot`
```

Place captures in this directory using prefix `mobile-NN-<screen>.png`.

## GIFs

Animated flow GIFs (login → OTP → home → ride booking) belong in `docs/gifs/` using prefix `flow-NN-<name>.gif`.
