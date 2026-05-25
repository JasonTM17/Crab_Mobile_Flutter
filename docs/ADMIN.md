# Web Admin Dashboard

Source: `apps/web-admin/`

## Purpose

Single-page admin console for the Crab platform. Operators manage users, drivers, merchants, rides, food orders, promotions, payments, and notification broadcasts from one authenticated React app. The dashboard talks to the gateway service (default `http://localhost:3000`) which fans requests out to the backend microservices.

## Tech stack

- React 18 + TypeScript 5 (`tsc && vite build`)
- Vite 5 (dev server on port 3001, `/api` proxied to `http://localhost:3000`)
- Tailwind CSS 3 with `tailwindcss-animate`
- shadcn/ui style primitives over Radix UI (`@radix-ui/react-dialog`, `react-dropdown-menu`, `react-toast`, `react-tooltip`, `react-avatar`, `react-label`, `react-separator`, `react-slot`)
- React Router DOM 6 for routing
- TanStack React Query 5 for server state (`staleTime: 5min`, `retry: 1`)
- axios 1.7 for HTTP with a request and response interceptor pair
- sonner for toast notifications
- recharts for the dashboard charts
- lucide-react for icons

Path alias: `@` resolves to `./src` (configured in `vite.config.ts` and mirrored in `tsconfig`).

## Pages catalog

Routes are declared in `src/App.tsx`. Every authenticated page is rendered inside `MainLayout` (sidebar plus header) under `/dashboard/*`.

```text
/                       redirect -> /dashboard
/login                  Login.tsx
/dashboard              Dashboard.tsx        KPI cards, recharts panels
/dashboard/users        Users.tsx            user list and detail
/dashboard/drivers      Drivers.tsx          driver list, status, rating
/dashboard/merchants    Restaurants.tsx      alias of restaurants
/dashboard/restaurants  Restaurants.tsx
/dashboard/rides        Rides.tsx            ride history and live tracking entry
/dashboard/orders       Orders.tsx           food order list
/dashboard/promos       Promos.tsx           promo CRUD
/dashboard/notifications NotificationBroadcast.tsx  push to user/driver segments
/dashboard/payments     Payments.tsx         transaction history
*                       redirect -> /dashboard
```

Sidebar nav items are declared in `src/components/layout/Sidebar.tsx`.

## Auth flow with refresh token

`src/hooks/useAuth.ts` exposes `loginMutation`, `logout`, `isAuthenticated`, `currentUser`.

1. Login form posts to `POST /auth/admin/login` with `{ email, password }`.
2. Response shape: `{ user: { id, email, name, role, avatar? }, tokens: { access_token, refresh_token } }`.
3. `useAuth` rejects any role outside `['ADMIN', 'SUPER_ADMIN']`. Allowed values are checked client-side before storing tokens.
4. Tokens and `user` JSON are stored in `localStorage` under keys `access_token`, `refresh_token`, `user`.
5. Every request goes through `src/lib/axios.ts`. The request interceptor attaches `Authorization: Bearer <access_token>`.
6. On `401 Unauthorized` the response interceptor calls `POST /auth/refresh` with `{ refresh_token }`, swaps in the new pair, marks the original request `_retry`, and replays it once.
7. If refresh fails, both tokens and `user` are cleared and the browser is redirected to `/login`.
8. `<AuthGuard>` in `App.tsx` blocks unauthenticated access to `/dashboard/*` by checking `isAuthenticated`.

## Theme tokens

Tailwind config (`tailwind.config.js`) uses HSL CSS variables defined in `src/index.css` so the same tokens drive light and dark mode (`darkMode: ['class']`). Color slots:

```text
border, input, ring, background, foreground,
primary / primary-foreground,           brand green base
secondary / secondary-foreground,
destructive / destructive-foreground,
muted / muted-foreground,
accent / accent-foreground,
popover / popover-foreground,
card / card-foreground
```

Dashboard charts use a fixed palette `['#00B14F', '#0EA5E9', '#F59E0B', '#EF4444']` defined in `Dashboard.tsx`. The brand green `#00B14F` is the source of truth for the `primary` token.

Border radius is driven by `--radius` and exposed as `rounded-lg`, `rounded-md`, `rounded-sm`. Animations are wired through `tailwindcss-animate` plus custom `accordion-down` / `accordion-up` keyframes.

## Build and dev commands

```bash
cd apps/web-admin
pnpm install
pnpm dev          # vite dev server on http://localhost:3001
pnpm build        # tsc && vite build, outputs dist/
pnpm preview      # serve the built bundle
pnpm lint         # eslint with unused-disable-directives reporting
```

The `dev` server proxies `/api/*` to `http://localhost:3000` so requests can stay same-origin during development without CORS configuration.

## Environment variables

Vite reads `VITE_*` vars from `.env*` files in `apps/web-admin/`. Used at runtime today:

| Name           | Required | Default                  | Used by         |
|----------------|----------|--------------------------|-----------------|
| `VITE_API_URL` | no       | `http://localhost:3000`  | `src/lib/axios.ts` |

Set `VITE_API_URL=https://api.example.com` for staging or production builds. The bundle is static after `vite build`, so the value is baked in per environment.

## How to add a new page

1. Create `src/pages/MyFeature.tsx` and export a default React component.
2. Register the route in `src/App.tsx` inside the `MainLayout` block:

   ```tsx
   <Route path="my-feature" element={<MyFeature />} />
   ```

3. Add a sidebar entry in `src/components/layout/Sidebar.tsx`:

   ```tsx
   { to: '/dashboard/my-feature', icon: Sparkles, label: 'My Feature' },
   ```

4. Fetch data with React Query and the shared `api` client:

   ```tsx
   import api from '@/lib/axios'
   const { data, isLoading } = useQuery({
     queryKey: ['my-feature'],
     queryFn: async () => (await api.get('/my-feature')).data,
   })
   ```

5. Reuse `Card`, `Button`, `Skeleton`, `EmptyState`, and `Badge` from `src/components/ui/*` to inherit the design vocabulary.
6. For forms use `react-router-dom` navigation, `sonner.toast` for feedback, and the global `<Toaster>` mounted in `App.tsx`.
7. If the page is admin-only, no extra guard is needed. The wrapping `<AuthGuard>` already blocks anonymous access and `useAuth` enforces the `ADMIN`/`SUPER_ADMIN` role check.

## Related docs

- [../README.md](../README.md)
