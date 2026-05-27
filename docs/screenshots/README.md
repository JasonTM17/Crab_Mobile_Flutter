# Screenshots Gallery

This gallery is intentionally split into separate English and Vietnamese tracks.
It is the source of truth for release-facing screenshots and GIFs used by the
portfolio README and case study.

Thư viện này được tách riêng phần English và phần tiếng Việt. Đây là source of
truth cho screenshot và GIF public được dùng trong README và case study
portfolio.

<!-- SCREENSHOTS-EN:START -->

## English Screenshots Gallery

Use only stable, scrubbed, release-facing images in public documentation. These
screenshots should show successful populated states, not loading placeholders,
404 pages, stack traces, or temporary emulator captures.

For the polished portfolio narrative that uses these assets, see
[Portfolio Case Study](../PORTFOLIO_CASE_STUDY.md#english-case-study).

### Web Admin

Refresh admin release screenshots with:

```bash
pnpm run admin:screenshots
```

| Screen | Preview | Notes |
| --- | --- | --- |
| Login | ![Admin login](admin-01-login.png) | Phone or email login form with JWT auth flow |
| Dashboard | ![Admin dashboard](admin-02-dashboard.png) | KPI cards, corrected charts, and operations navigation |
| Users | ![Admin users](admin-03-users.png) | Paginated user operations table |
| Drivers | ![Admin drivers](admin-04-drivers.png) | Driver verification and vehicle details |
| Rides | ![Admin rides](admin-05-rides.png) | Ride monitoring with status, fare, and distance |
| Orders | ![Admin orders](admin-06-orders.png) | Food order monitoring and status timeline |
| Dashboard final | ![Admin dashboard final](admin-07-dashboard-final.png) | Re-captured dashboard after navigation smoke test |

### Web Admin Responsive

| Screen | Preview |
| --- | --- |
| Dashboard | ![Admin mobile dashboard](admin-mobile-01-dashboard.png) |
| Login | ![Admin mobile login](admin-mobile-02-login.png) |
| Users | ![Admin mobile users](admin-mobile-03-users.png) |
| Drivers | ![Admin mobile drivers](admin-mobile-04-drivers.png) |
| Rides | ![Admin mobile rides](admin-mobile-05-rides.png) |
| Orders | ![Admin mobile orders](admin-mobile-06-orders.png) |

### Mobile Client

The mobile gallery must show real user-facing Flutter screens: onboarding,
login, signed-in home, ride booking, food discovery, and wallet or profile
trust surfaces.

The full mobile UI/UX refresh plan and capture quality gate live in
[Mobile UI/UX Redesign](../MOBILE_UI_UX_REDESIGN.md).

Refresh mobile release screenshots with:

```bash
pnpm run mobile:screenshots
```

| Screen | Preview | Notes |
| --- | --- | --- |
| Onboarding | ![Mobile onboarding](mobile-01-onboarding.png) | Verified Flutter onboarding screenshot from the current widget tree |
| Login | ![Mobile client login](mobile-client-01-login.png) | Real user auth screen with phone or email entry |
| Signed-in home | ![Mobile client home](mobile-client-02-home.png) | Real user home surface with services, wallet, and promos |
| Ride booking | ![Mobile ride booking](mobile-client-03-ride-booking.png) | Booking sheet with route, fare, ETA, vehicle choice, and CTA |
| Food discovery | ![Mobile food discovery](mobile-client-04-food.png) | Restaurant discovery with categories, ratings, ETA, and delivery fee |
| Wallet/profile trust | ![Mobile wallet profile](mobile-client-05-wallet-profile.png) | Wallet balance, transaction history, and trust cues for the seeded demo account |

### GIFs

| Asset | Preview | Notes |
| --- | --- | --- |
| Admin release flow | ![Admin release flow](../gifs/admin-release-flow.gif) | Login to dashboard and core operations walkthrough |
| Mobile client flow | ![Mobile client flow](../gifs/mobile-client-flow.gif) | Onboarding, auth, home, ride, food, and wallet portfolio walkthrough |

### Capture Checklist

- Use seeded, non-sensitive demo data.
- Wait for loading states to settle before capture.
- Do not capture 404 pages, raw stack traces, real credentials, real addresses,
  real phone numbers, tokens, or payment details.
- Prefer success states with populated tables, cards, charts, or forms.
- Put release-facing images under `docs/screenshots/` with stable names such as
  `admin-*.png`, `admin-mobile-*.png`, or `mobile-*.png`.
- Keep temporary proof, current, or emulator captures local-only and do not
  reference them from public docs.

<!-- SCREENSHOTS-EN:END -->

---

<!-- SCREENSHOTS-VI:START -->

## Vietnamese Screenshots Gallery

Chỉ dùng ảnh ổn định, đã kiểm tra và phù hợp cho tài liệu public. Screenshot
public phải thể hiện trạng thái thành công có dữ liệu, không dùng loading
placeholder, trang 404, stack trace hoặc ảnh emulator tạm.

Để xem bản trình bày portfolio dùng các asset này, mở
[Hồ sơ portfolio](../PORTFOLIO_CASE_STUDY.md#vietnamese-case-study).

### Giao Diện Admin

Chụp lại screenshot admin bằng lệnh:

```bash
pnpm run admin:screenshots
```

| Màn hình | Preview | Ghi chú |
| --- | --- | --- |
| Đăng nhập | ![Admin login](admin-01-login.png) | Form đăng nhập bằng phone hoặc email với JWT auth flow |
| Dashboard | ![Admin dashboard](admin-02-dashboard.png) | KPI cards, biểu đồ đã chỉnh đúng và điều hướng vận hành |
| Users | ![Admin users](admin-03-users.png) | Bảng user có phân trang cho vận hành |
| Drivers | ![Admin drivers](admin-04-drivers.png) | Xác minh tài xế và thông tin phương tiện |
| Rides | ![Admin rides](admin-05-rides.png) | Theo dõi chuyến xe với trạng thái, fare và distance |
| Orders | ![Admin orders](admin-06-orders.png) | Theo dõi đơn đồ ăn và timeline trạng thái |
| Dashboard final | ![Admin dashboard final](admin-07-dashboard-final.png) | Dashboard chụp lại sau navigation smoke test |

### Admin Responsive

| Màn hình | Preview |
| --- | --- |
| Dashboard | ![Admin mobile dashboard](admin-mobile-01-dashboard.png) |
| Đăng nhập | ![Admin mobile login](admin-mobile-02-login.png) |
| Users | ![Admin mobile users](admin-mobile-03-users.png) |
| Drivers | ![Admin mobile drivers](admin-mobile-04-drivers.png) |
| Rides | ![Admin mobile rides](admin-mobile-05-rides.png) |
| Orders | ![Admin mobile orders](admin-mobile-06-orders.png) |

### Ứng Dụng Mobile Client

Gallery mobile phải thể hiện màn Flutter thật hướng tới user: onboarding, login,
home sau đăng nhập, đặt xe, tìm đồ ăn và bề mặt tin cậy như ví hoặc hồ sơ.

Kế hoạch UI/UX refresh và capture quality gate nằm trong
[Mobile UI/UX Redesign](../MOBILE_UI_UX_REDESIGN.md).

Chụp lại screenshot mobile bằng lệnh:

```bash
pnpm run mobile:screenshots
```

| Màn hình | Preview | Ghi chú |
| --- | --- | --- |
| Onboarding | ![Mobile onboarding](mobile-01-onboarding.png) | Screenshot onboarding Flutter đã kiểm chứng từ widget tree hiện tại |
| Đăng nhập | ![Mobile client login](mobile-client-01-login.png) | Màn auth thật của user với nhập phone hoặc email |
| Home sau đăng nhập | ![Mobile client home](mobile-client-02-home.png) | Home thật của user với services, wallet và promos |
| Đặt xe | ![Mobile ride booking](mobile-client-03-ride-booking.png) | Booking sheet có route, fare, ETA, chọn xe và CTA |
| Tìm đồ ăn | ![Mobile food discovery](mobile-client-04-food.png) | Tìm nhà hàng với categories, ratings, ETA và delivery fee |
| Ví và hồ sơ | ![Mobile wallet profile](mobile-client-05-wallet-profile.png) | Số dư ví, lịch sử giao dịch và trust cues cho demo account |

### GIFs

| Asset | Preview | Ghi chú |
| --- | --- | --- |
| Admin release flow | ![Admin release flow](../gifs/admin-release-flow.gif) | Walkthrough đăng nhập vào dashboard và vận hành chính |
| Mobile client flow | ![Mobile client flow](../gifs/mobile-client-flow.gif) | Walkthrough onboarding, auth, home, gọi xe, đồ ăn và ví |

### Checklist Khi Chụp Ảnh

- Dùng dữ liệu demo không nhạy cảm.
- Chờ trạng thái loading hoàn tất trước khi chụp.
- Không chụp trang 404, stack trace, credential thật, địa chỉ thật, số điện
  thoại thật, token hoặc thông tin thanh toán.
- Ưu tiên trạng thái thành công có bảng, cards, biểu đồ hoặc form đã có dữ
  liệu.
- Đặt ảnh public trong `docs/screenshots/` với tên ổn định như `admin-*.png`,
  `admin-mobile-*.png` hoặc `mobile-*.png`.
- Proof, current hoặc emulator captures chỉ dùng local và không reference từ
  tài liệu public.

<!-- SCREENSHOTS-VI:END -->
