# Screenshots Gallery

A curated gallery of the Crab Super App admin console across desktop and mobile breakpoints. Screenshots show the production dashboard experience with seeded operational data.

Bộ sưu tập ảnh giao diện admin của Crab Super App trên desktop và mobile viewport. Các ảnh thể hiện trạng thái vận hành có dữ liệu mẫu, không phải màn hình trống.

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

Pending driver applications with license number, vehicle information, plate details, and review actions.

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

## Mobile Viewport (390x812 - iPhone)

The web admin is responsive and keeps the same operations-first layout at an iPhone-sized viewport.

Giao diện web admin hỗ trợ responsive và giữ được bố cục ưu tiên vận hành trên viewport cỡ iPhone:

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

The Flutter mobile app shares the same product surface: authentication, home services, ride booking, food discovery, wallet, notifications, and profile settings.

Ứng dụng Flutter bao phủ cùng bề mặt sản phẩm: đăng nhập, trang chủ dịch vụ, đặt xe, khám phá món ăn, ví, thông báo và hồ sơ cá nhân.

## GIFs

### Admin Release Flow

![Admin release flow](../gifs/admin-release-flow.gif)

A short login → dashboard → users → drivers → rides → orders flow demonstrates the core admin journey.

GIF ngắn minh họa luồng admin cốt lõi từ đăng nhập đến dashboard, users, drivers, rides và orders.
