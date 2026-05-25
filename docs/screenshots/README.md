# Screenshots Gallery / Thư Viện Ảnh

This gallery contains curated release-facing screenshots for Crab Super App. Use only stable, scrubbed images in public documentation.

Thư viện này chứa ảnh đã chọn lọc cho tài liệu public của Crab Super App. Chỉ dùng ảnh ổn định, đã kiểm tra không lộ dữ liệu nhạy cảm.

## Web Admin / Giao Diện Admin

The admin gallery shows populated operations screens: login, dashboard, users, drivers, rides, orders, and responsive mobile viewport checks.

Bộ ảnh admin thể hiện các màn vận hành có dữ liệu: đăng nhập, dashboard, users, drivers, rides, orders và kiểm tra responsive mobile viewport.

| Screen | Preview | Notes |
| --- | --- | --- |
| Login | ![Admin login](admin-01-login.png) | Phone/email login form with JWT auth flow |
| Dashboard | ![Admin dashboard](admin-02-dashboard.png) | KPI cards, charts, and navigation |
| Users | ![Admin users](admin-03-users.png) | Paginated user operations table |
| Drivers | ![Admin drivers](admin-04-drivers.png) | Driver verification and vehicle details |
| Rides | ![Admin rides](admin-05-rides.png) | Ride monitoring with status/fare/distance |
| Orders | ![Admin orders](admin-06-orders.png) | Food order monitoring and status timeline |
| Dashboard final | ![Admin dashboard final](admin-07-dashboard-final.png) | Re-captured dashboard after navigation smoke test |

## Web Admin Responsive / Admin Trên Mobile Viewport

| Screen | Preview |
| --- | --- |
| Dashboard | ![Admin mobile dashboard](admin-mobile-01-dashboard.png) |
| Login | ![Admin mobile login](admin-mobile-02-login.png) |
| Users | ![Admin mobile users](admin-mobile-03-users.png) |
| Drivers | ![Admin mobile drivers](admin-mobile-04-drivers.png) |
| Rides | ![Admin mobile rides](admin-mobile-05-rides.png) |
| Orders | ![Admin mobile orders](admin-mobile-06-orders.png) |

## Mobile Client / Ứng Dụng Client

The current verified mobile release screenshot is captured from the Flutter onboarding widget tree. Older proof/current/emulator captures and proof-derived copies must not be presented as primary release media.

Ảnh mobile release hiện tại được chụp từ widget tree onboarding của Flutter. Không dùng ảnh proof/current/emulator cũ hoặc bản sao bắt nguồn từ proof capture làm media phát hành chính.

| Screen | Preview | Notes |
| --- | --- | --- |
| Onboarding | ![Mobile onboarding](mobile-01-onboarding.png) | Verified Flutter onboarding screenshot from the current widget tree |

## GIFs / Ảnh Động

| Asset | Preview | Notes |
| --- | --- | --- |
| Admin release flow | ![Admin release flow](../gifs/admin-release-flow.gif) | Login to dashboard and core operations walkthrough |

## Capture Checklist / Checklist Khi Chụp Ảnh

- Use seeded, non-sensitive demo data.
- Wait for loading states to settle before capture.
- Do not capture 404 pages, raw stack traces, real credentials, real addresses, real phone numbers, tokens, or payment details.
- Prefer success states with populated tables/cards.
- Put release-facing images under `docs/screenshots/` with stable names such as `admin-*.png`, `admin-mobile-*.png`, or `mobile-*.png`.
- Keep temporary proof/current/emulator captures local-only and do not reference them from public docs.

- Dùng dữ liệu demo không nhạy cảm.
- Chờ màn hình load xong trước khi chụp.
- Không chụp 404, stack trace, credentials thật, địa chỉ thật, số điện thoại thật, token hoặc thông tin thanh toán.
- Ưu tiên trạng thái thành công có dữ liệu.
- Ảnh public đặt dưới `docs/screenshots/` với tên ổn định như `admin-*.png`, `admin-mobile-*.png` hoặc `mobile-*.png`.
- Proof/current/emulator captures chỉ dùng local, không reference trong public docs.
