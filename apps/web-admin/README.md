# Web Admin Dashboard

React-based admin panel for managing the Crab platform.

## Port: 5173 (dev) / 8080 (Docker)

## Tech Stack
- React 18 + TypeScript
- Vite build tool
- TailwindCSS + shadcn/ui components
- TanStack Query for data fetching
- Recharts for analytics
- React Router v6

## Features
- Admin dashboard with live service-backed KPIs and charts
- User management views for users, drivers, merchants, and restaurants
- Ride monitoring and history
- Order management
- Promo management and notification broadcast tools
- Payment and transaction oversight
- Responsive admin layout with same-origin API routing for production

## Pages

| Route | Description |
|-------|-------------|
| `/dashboard` | Dashboard with KPIs and charts |
| `/dashboard/users` | User management table |
| `/dashboard/drivers` | Driver management and verification |
| `/dashboard/merchants` | Merchant list via restaurant data |
| `/dashboard/restaurants` | Restaurant management |
| `/dashboard/rides` | Ride history and live monitoring |
| `/dashboard/orders` | Food order management |
| `/dashboard/promos` | Promo code management |
| `/dashboard/notifications` | Broadcast notifications |
| `/dashboard/payments` | Transaction history |

Current routes are defined in `src/App.tsx` and `src/components/layout/Sidebar.tsx`.

## API Base URL

- Development: Vite proxy forwards `/api/*` to `http://localhost:3000`
- Production: the app uses same-origin `/api/v1` by default
- Optional override: `VITE_API_URL`

Do not point production builds at `http://localhost:3000`.

## Testing

There is currently no dedicated automated test command for `@crab/web-admin`.
Use lint + production build + browser smoke checks until a test harness is added.

```bash
pnpm --filter @crab/web-admin lint
pnpm --filter @crab/web-admin build
```

## Docker

```bash
docker build -f apps/web-admin/Dockerfile -t nguyenson1710/crab-mobile-web-admin .
docker run -p 8080:8080 nguyenson1710/crab-mobile-web-admin
```

For production, place the container behind a reverse proxy that forwards `/api/` to the gateway.
Do not expose it as a standalone app unless API routing is configured.

## Operational Notes

- Release bundles are currently large (~860 kB main JS chunk) and remain a good candidate for future code-splitting work.
- If `admin.crab.example.com` is enabled, keep the matching `web-admin` Kubernetes Deployment/Service in sync with ingress updates.
- Payments views should be regression-tested against backend error responses whenever payment-service contracts change.

## Development

```bash
pnpm --filter @crab/web-admin dev
```

## Runtime Notes

- Development uses the Vite proxy to forward `/api/*` to the gateway on `http://localhost:3000`.
- Production defaults to same-origin `/api/v1` unless `VITE_API_URL` is explicitly provided at build time.
- Deployments behind nginx/ingress must route `/api/` to the gateway.

## Verification

```bash
pnpm --filter @crab/web-admin lint
pnpm --filter @crab/web-admin build
```

Manual smoke coverage should include login, dashboard load, payments, notifications, and logout.
