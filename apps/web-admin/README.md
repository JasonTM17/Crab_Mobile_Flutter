# Web Admin Dashboard

React-based operations console for managing the Crab platform: users, drivers, restaurants, rides, food orders, payments, promos, and notifications.

Bảng điều khiển vận hành viết bằng React để quản lý nền tảng Crab: users, drivers, restaurants, rides, food orders, payments, promos và notifications.

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

## Tính năng
- Dashboard admin với KPI và biểu đồ lấy từ service thật
- Quản lý users, drivers, merchants và restaurants
- Theo dõi lịch sử và trạng thái chuyến xe
- Quản lý đơn giao đồ ăn
- Quản lý promo code và broadcast notifications
- Giám sát payments và transactions
- Layout responsive, dùng same-origin API routing cho production

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

## API Base URL (Tiếng Việt)

- Development: Vite proxy chuyển tiếp `/api/*` đến `http://localhost:3000`
- Production: mặc định dùng same-origin `/api/v1`
- Có thể override bằng `VITE_API_URL`

Không build production trỏ trực tiếp về `http://localhost:3000`.

## Testing

The admin dashboard is verified with static analysis, production builds, and browser smoke checks for the critical operations paths.

Web admin được kiểm chứng bằng static analysis, production build và browser smoke checks cho các luồng vận hành quan trọng.

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

- Serve the dashboard behind the same gateway boundary used by the mobile API.
- Keep ingress, service discovery, and same-origin `/api/` routing aligned across Docker and Kubernetes deployments.
- Regression-test payments and notification views whenever backend contracts change.

## Ghi chú vận hành

- Đặt dashboard phía sau cùng gateway boundary với mobile API.
- Đồng bộ ingress, service discovery và same-origin `/api/` routing giữa Docker và Kubernetes.
- Regression-test payments và notifications khi backend contract thay đổi.

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
