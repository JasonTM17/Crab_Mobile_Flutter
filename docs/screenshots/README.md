# Screenshots Gallery / Thư Viện Ảnh

This gallery contains curated release-facing screenshots for Crab Super App. Use only stable, scrubbed images in public documentation.

Thư viện này chứa ảnh đã chọn lọc cho tài liệu public của Crab Super App. Chỉ dùng ảnh ổn định, đã kiểm tra không lộ dữ liệu nhạy cảm.

For a polished bilingual portfolio narrative that uses these assets, see
[Portfolio Case Study](../PORTFOLIO_CASE_STUDY.md).

Để xem bản hồ sơ portfolio song ngữ dùng bộ ảnh này, xem
[Portfolio Case Study](../PORTFOLIO_CASE_STUDY.md).

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

The mobile gallery must show real user-facing Flutter screens: onboarding, login, and signed-in home. These captures are release media, not proof/current/emulator scratch files.

Gallery mobile phải thể hiện màn Flutter dành cho user thật: onboarding, login và home sau đăng nhập. Đây là ảnh release, không phải proof/current/emulator scratch.

The full mobile UI/UX refresh plan and capture quality gate live in [Mobile UI/UX Redesign](../MOBILE_UI_UX_REDESIGN.md).

Portfolio media should tell a short product story: onboarding, login, signed-in home, one core ride or food flow, and one trust surface such as wallet or profile. The final target GIF is `docs/gifs/mobile-client-flow.gif`.

Refresh the current mobile release screenshots with:

```bash
pnpm run mobile:screenshots
```

| Screen | Preview | Notes |
| --- | --- | --- |
| Onboarding | ![Mobile onboarding](mobile-01-onboarding.png) | Verified Flutter onboarding screenshot from the current widget tree |
| Login | ![Mobile client login](mobile-client-01-login.png) | Real user auth screen with phone/email entry |
| Signed-in home | ![Mobile client home](mobile-client-02-home.png) | Real user home surface with services, wallet, and promos |
| Ride booking | ![Mobile ride booking](mobile-client-03-ride-booking.png) | Stitch-guided booking sheet with route, fare, ETA, vehicle choice, and CTA |
| Food discovery | ![Mobile food discovery](mobile-client-04-food.png) | Stitch-guided restaurant discovery with categories, ratings, ETA, and delivery fee |
| Wallet/profile trust | ![Mobile wallet profile](mobile-client-05-wallet-profile.png) | Wallet balance, transaction history, and trust cues for the seeded demo account |

## GIFs / Ảnh Động

| Asset | Preview | Notes |
| --- | --- | --- |
| Admin release flow | ![Admin release flow](../gifs/admin-release-flow.gif) | Login to dashboard and core operations walkthrough |
| Mobile client flow | ![Mobile client flow](../gifs/mobile-client-flow.gif) | Onboarding, auth, home, ride, food, and wallet portfolio walkthrough |

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
