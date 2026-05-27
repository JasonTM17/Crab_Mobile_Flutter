# Mobile App (Flutter)

The mobile client lives in `apps/mobile`. It is the rider, driver, and food customer surface for the Crab super-app and talks to the backend services through REST (Dio) and Socket.IO. The app targets Flutter SDK `>=3.0.0 <4.0.0` and is published as `crab_mobile` (see `apps/mobile/pubspec.yaml`).

This document describes how the app is structured, how state, DI, networking, and routing are wired, and what each feature module does.

For the A-Z customer-facing UI/UX completion plan, design-system rules, accessibility gates, and release media checklist, see [Mobile UI/UX Redesign](./MOBILE_UI_UX_REDESIGN.md).

## 1. Architecture

The codebase follows a feature-first Clean Architecture layout. Cross-cutting plumbing lives under `lib/core/`, and every feature is a self-contained module under `lib/features/<name>/`.

Per-feature shape:

```
features/<feature>/
  data/
    models/         # JSON-serializable DTOs (json_annotation)
    repositories/   # Pure Dart classes that wrap DioClient + SocketClient
  presentation/
    bloc/           # <Feature>Bloc + <Feature>Event + <Feature>State
    screens/        # Top-level routed pages (one file per screen)
    widgets/        # Feature-local reusable widgets
```

Shared infrastructure under `lib/core/`:

- `constants/api_constants.dart` — REST endpoint paths, socket namespaces, and the `API_BASE_URL` / `SOCKET_URL` build-time env defaults (`http://10.0.2.2:3000/api/v1` and `http://10.0.2.2:3000`, the Android emulator host loopback).
- `di/injection.dart` — GetIt service-locator wiring.
- `network/dio_client.dart` — Dio factory with auth + 401 refresh interceptor.
- `network/socket_client.dart` — multi-namespace Socket.IO manager.
- `router/app_router.dart` — GoRouter table and redirect guard.
- `router/splash_screen.dart` and `router/onboarding_screen.dart` — bootstrap routes.
- `theme/app_theme.dart` — light + dark `ThemeData` and `AppColors`.

Layer rules:

- `presentation` imports `data`; `data` never imports `presentation`.
- Repositories return models; Blocs translate domain calls into states.
- Sockets are owned by Blocs that need realtime updates (food, ride, chat, notifications). Repositories handle REST only.

## 2. State Management

State is managed with `flutter_bloc ^8.1.6` plus `bloc ^8.1.4` and `equatable ^2.0.5`.

Each feature defines:

- `<Feature>Event` — sealed-style class hierarchy (`extends Equatable`). Examples include `RequestRide`, `DriverMatched`, `RideStatusChanged`, `LoadRestaurants`, `PlaceOrder`, `OrderStatusUpdated`, `LoadConversations`, `MessageReceived`, `LoadNotifications`, `LoadWallet`, `TopUpWallet`, `SubmitRating`.
- `<Feature>State` — typed status enum + payload fields.
- `<Feature>Bloc` — registers handlers via `on<Event>(...)` and pushes new states.

Top-level providers are wired in `apps/mobile/lib/main.dart`:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested())),
    BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
    BlocProvider<RideBloc>(create: (_) => sl<RideBloc>()),
    BlocProvider<DriverBloc>(create: (_) => sl<DriverBloc>()),
    BlocProvider<FoodBloc>(create: (_) => sl<FoodBloc>()),
    BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
    BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
    BlocProvider<NotificationBloc>(create: (_) => sl<NotificationBloc>()),
    BlocProvider<RatingBloc>(create: (_) => sl<RatingBloc>()),
    BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
  ],
  child: MaterialApp.router(...),
)
```

Because every Bloc is a global provider, screens can `context.read<XxxBloc>()` without rewiring providers per route. `AuthBloc` is kicked off with `AuthCheckRequested` so the splash screen can decide between `/onboarding`, `/login`, and `/home`.

## 3. Dependency Injection

DI uses `get_it ^9.2.1` as a service-locator. The single registration pass is `configureDependencies()` in `lib/core/di/injection.dart`, called from `main()` before `runApp`.

Registration tiers:

- **Storage** — `FlutterSecureStorage`, `AuthStorage` (lazy singleton).
- **Networking** — `Dio` (created via `DioClient.create`), `DioClient` wrapper, `SocketClient` (lazy singleton).
- **Repositories** — `AuthRepository`, `RideRepository`, `DriverRepository`, `FoodRepository`, `PaymentRepository`, `ChatRepository`, `NotificationRepository`, `RatingRepository`, `ProfileRepository` (lazy singleton).
- **Blocs** — registered as `factory` so each navigation gets a fresh instance.

Resolve via the exported `sl` instance: `sl<RideRepository>()`, `sl<AuthBloc>()`, `sl<SocketClient>()`. The Bloc providers in `main.dart` resolve from `sl`.

`injectable ^2.4.4` and `injectable_generator ^2.6.2` are declared and several files carry `@injectable` annotations (e.g. `food_bloc.dart`, `chat_bloc.dart`, `ride_bloc.dart`, `home_bloc.dart`, `payment_bloc.dart`, `profile_bloc.dart`, `notification_bloc.dart`, `chat_repository.dart`, `notification_repository.dart`, `profile_repository.dart`). However, no generated `injection.config.dart` is invoked — registrations are written by hand. Annotations are effectively dead weight today (see Caveats).

## 4. Networking

### 4.1 REST — DioClient

`lib/core/network/dio_client.dart` exposes a static `DioClient.create({ required AuthStorage authStorage })` that returns a configured `Dio`:

- `baseUrl` from `ApiConstants.baseUrl` (`API_BASE_URL` build-time define, defaulting to `http://10.0.2.2:3000/api/v1`).
- 30s connect / receive timeouts.
- JSON content-type and accept headers.
- A single `InterceptorsWrapper`:
  - `onRequest` reads the access token from `AuthStorage` and adds `Authorization: Bearer <token>`.
  - `onError` catches `401` responses, calls `POST /auth/refresh` with the stored refresh token, persists the new pair via `AuthStorage.saveTokens`, replays the original request, and resolves the retry. Refresh failures clear storage so the redirect guard kicks the user back to `/login`.

Repositories accept either the raw `Dio` (auth, ride) or the `DioClient` wrapper (food, payment, chat, notifications, rating, profile). Both go through the same instance of `Dio`.

### 4.2 Realtime — SocketClient

`lib/core/network/socket_client.dart` manages multiple Socket.IO namespaces concurrently. It uses `socket_io_client ^3.1.4`.

- One `Map<String, io.Socket>` keyed by namespace path.
- `connect(namespace)` re-uses an existing connected socket, otherwise pulls the access token from `AuthStorage`, builds an `io.OptionBuilder()` with `transports: ['websocket']`, `auth: { token }`, and `forceNew: true`, then connects.
- `disconnect(namespace)` and `disconnectAll()` close sockets without recreating them.
- Convenience getters: `rideSocket`, `foodSocket`, `chatSocket`, `notificationSocket`, mapped to namespaces `/ride`, `/food`, `/chat`, `/notification` (defined in `ApiConstants`).

Blocs that need realtime updates (`FoodBloc`, `ChatBloc`, `NotificationBloc`, `RideBloc`, `DriverBloc`) register listeners against the namespace socket and dispatch domain events back into themselves (e.g. `socket.on('order:status', ...) -> add(OrderStatusUpdated(...))`).

## 5. Routing

Navigation uses `go_router ^17.2.3`, configured statically in `lib/core/router/app_router.dart`.

`initialLocation` is `/splash`. The full route table covers bootstrap (`/splash`, `/onboarding`), auth (`/login`, `/register`, `/otp`, `/forgot-password`), home (`/home`, `/activity`, `/services`, `/promos`), rider flow (`/ride/book`, `/ride/search`, `/ride/history`, `/ride/:id`, `/ride/:id/rate`), driver mode (`/driver/dashboard`, `/driver/earnings`), food (`/food`, `/food/restaurant/:id`, `/food/restaurant/:id/info`, `/food/cart`, `/food/order/:id`, `/food/orders`), wallet (`/wallet`, `/wallet/topup`, `/wallet/transfer`, `/wallet/transactions`), chat (`/chat`, `/chat/:roomId`), notifications (`/notifications`), and profile (`/profile`, `/profile/edit`, `/profile/addresses`, `/profile/security`).

### 5.1 Redirect guard

A single `redirect:` callback enforces auth on every navigation. Public routes (no auth required):

```
/splash
/onboarding
/login
/register
/otp
/forgot-password
```

Any other path runs `await sl<AuthStorage>().isAuthenticated()`. Unauthenticated requests are rewritten to `/login`; thrown errors also fall through to `/login`. There is no `/404` page — instead, `errorBuilder` renders a Scaffold with a "Go Home" button that pushes `/home`.

## 6. Theming

`lib/core/theme/app_theme.dart` declares `AppColors` (Grab green `#00B14F` primary, amber secondary, neutral surface tones for light + dark) plus two `ThemeData` getters wired into `MaterialApp.router`:

- `AppTheme.lightTheme` — Material 3, light scheme, `backgroundLight = #F5F7FA`, white surface, primary-green elevated buttons (52pt minimum height, 12pt radius), bordered text fields, bordered cards.
- `AppTheme.darkTheme` — Material 3, dark scheme, `backgroundDark = #111827`, dark surface, the same primary-green button styling.

Both themes share `_textTheme(primary, secondary)` for consistent typography. The app passes both to `MaterialApp.router` so the OS theme setting toggles between them automatically.

## 7. Feature Catalogue

### auth
- **Purpose**: registration, password and OTP login, phone verification, password reset, logout, session bootstrapping.
- **Screens**: `login_screen.dart`, `register_screen.dart`, `otp_screen.dart`, `forgot_password_screen.dart`.
- **BLoC events**: `AuthCheckRequested`, `AuthRegisterRequested`, `AuthEmailLoginRequested`, `AuthPhoneLoginRequested`, `AuthOtpVerifyRequested`, `AuthPasswordResetRequested`, `AuthPasswordResetConfirmed`, `AuthLogoutRequested`.

### home
- **Purpose**: dashboard shell with bottom-tab navigation between home, activity, and services hubs.
- **Screens**: `home_screen.dart`, `activity_screen.dart`, `services_screen.dart`.
- **BLoC events**: `HomeTabChanged`.

### ride (rider)
- **Purpose**: fare estimation, ride booking, location search, live tracking with driver telemetry, ride history, post-trip rating handoff.
- **Screens**: `ride_booking_screen.dart`, `location_search_screen.dart`, `ride_tracking_screen.dart`, `ride_history_screen.dart`.
- **BLoC events**: `RequestRide`, `CancelRide`, `DriverMatched`, `LocationUpdate`, `RideStatusChanged`, `RideCompleted`, `EstimateFareRequested`, `PickupLocationSelected`, `DropoffLocationSelected`.

### ride/driver
- **Purpose**: driver-side dashboard for going online/offline, accepting/rejecting incoming requests with countdown, lifecycle (start/complete) actions, and earnings view.
- **Screens**: `driver_mode_screen.dart`, `driver_earnings_screen.dart`.
- **BLoC events**: `GoOnline`, `GoOffline`, `RideRequestReceived`, `AcceptRide`, `RejectRide`, `StartRide`, `CompleteRide`, `UpdateLocation`, `CountdownTick`.

### food
- **Purpose**: restaurant browsing, menu, cart management, checkout, order tracking with realtime status updates, order history.
- **Screens**: `restaurant_list_screen.dart`, `restaurant_detail_screen.dart`, `restaurant_menu_screen.dart`, `cart_screen.dart`, `order_tracking_screen.dart`, `order_history_screen.dart`.
- **BLoC events**: `LoadRestaurants`, `LoadRestaurantMenu`, `AddToCart`, `RemoveFromCart`, `ClearCart`, `PlaceOrder`, `LoadOrderHistory`, `LoadOrder`, `LoadActiveOrder`, `OrderStatusUpdated`, `CancelOrder`, `FilterCategoryChanged`.

### payment
- **Purpose**: wallet balance + transactions, top-up flow, peer transfer, promo discovery and code redemption.
- **Screens**: `wallet_screen.dart`, `top_up_screen.dart`, `transfer_screen.dart`, `transaction_history_screen.dart`, `promos_screen.dart`.
- **BLoC events**: `LoadWallet`, `LoadTransactions`, `TopUpWallet`, `LoadPromos`, `ApplyPromoCode`.

### chat
- **Purpose**: realtime conversation list and message thread for rider/driver and food contexts.
- **Screens**: `conversations_screen.dart`, `chat_room_screen.dart`, `chat_detail_screen.dart`.
- **BLoC events**: `LoadConversations`, `LoadMessages`, `SendMessage`, `MessageReceived`, `MarkConversationRead`, `TypingStarted`, `TypingStopped`.

### notifications
- **Purpose**: notification inbox with realtime push and read-state management.
- **Screens**: `notifications_screen.dart`.
- **BLoC events**: `LoadNotifications`, `MarkNotificationRead`, `MarkAllNotificationsRead`, `NotificationReceived`.

### profile
- **Purpose**: profile view/edit, saved addresses, security settings (password change), logout.
- **Screens**: `profile_screen.dart`, `edit_profile_screen.dart`, `saved_addresses_screen.dart`, `security_screen.dart`.
- **BLoC events**: `LoadProfile`, `UpdateProfile`, `ChangePassword`, `LogoutRequested`.

### rating
- **Purpose**: submit a rating + comment for a ride or order; view aggregated reviews.
- **Screens**: `submit_rating_screen.dart`, `reviews_screen.dart`.
- **BLoC events**: `SubmitRating`, `LoadReviews`, `LoadRatingStats`.

## 8. Build and Run

Run workspace commands from the repo root. Run device/emulator commands from `apps/mobile/`.

```bash
# install Dart packages
node scripts/run-mobile-tool.js flutter pub get

# generate JSON serializers, injectable, etc. only when needed outside lint/test
pnpm --filter @crab/mobile run codegen

# run on a connected device or emulator with the dev backend (Android emulator default)
flutter run

# point at a non-default backend
flutter run \
  --dart-define=API_BASE_URL=https://api.staging.example.com/api/v1 \
  --dart-define=SOCKET_URL=https://api.staging.example.com

# release build
flutter build apk --release
flutter build appbundle --release
flutter build ios --release   # macOS only
```

`API_BASE_URL` and `SOCKET_URL` are read via `String.fromEnvironment` in `lib/core/constants/api_constants.dart`. Without `--dart-define`, the app talks to `http://10.0.2.2:3000` (Android emulator host loopback).

## 9. Testing

```bash
# static analysis (uses analysis_options + flutter_lints ^6.0.0)
pnpm --filter @crab/mobile lint

# unit + widget + bloc tests
pnpm --filter @crab/mobile test

# integration tests (device/emulator required)
cd apps/mobile
flutter test integration_test
```

`bloc_test ^9.1.7` and `mocktail ^1.0.4` are available for Bloc-level testing. `integration_test` is wired through `dev_dependencies`.

## 10. Release Media

Portfolio mobile media is generated from Flutter widget tests so screenshots
stay tied to the current widget tree.

```bash
pnpm run mobile:screenshots
```

Canonical mobile release assets:

| Asset | Path |
| --- | --- |
| Onboarding | `docs/screenshots/mobile-01-onboarding.png` |
| Login | `docs/screenshots/mobile-client-01-login.png` |
| Signed-in home | `docs/screenshots/mobile-client-02-home.png` |
| Ride booking | `docs/screenshots/mobile-client-03-ride-booking.png` |
| Food discovery | `docs/screenshots/mobile-client-04-food.png` |
| Wallet/profile trust | `docs/screenshots/mobile-client-05-wallet-profile.png` |
| Client walkthrough GIF | `docs/gifs/mobile-client-flow.gif` |

## 11. Production Readiness Notes

- **Hardcoded delivery coordinates**. `FoodRepository.placeOrder` defaults `deliveryLat = 10.7769` and `deliveryLng = 106.7009` (`apps/mobile/lib/features/food/data/repositories/food_repository.dart`). Callers from `FoodBloc.PlaceOrder` only pass `deliveryAddress`, so every checkout sends the same Ho Chi Minh City coordinates regardless of the address text. Wire real coordinates from a geocoding step or saved address before going to production.
- **Status casing fragility on socket events**. Socket payloads are matched against typed enums via `OrderStatus`/`RideStatus` parsers. Backend changes to status casing or string values (e.g. `PICKED_UP` vs `picked_up`) silently fall back to default branches in `FoodBloc` (`socket.on('order:status', ...)`) and `RideBloc`, leaving stale UI state. Treat status strings as a contract and bump the API contract whenever the backend changes them.
- **`injectable` declared but unused**. The `injectable` annotation set is present (`@injectable` on most blocs and several repositories) and `injectable_generator` is in `dev_dependencies`, but `configureDependencies()` is hand-written and no `injection.config.dart` is generated or invoked. Either remove the annotations and the generator, or run `pnpm --filter @crab/mobile run codegen` and switch to `getIt.init()` — keeping both invites drift between the manual registrations and the annotation graph.

---

See also: [../README.md](../README.md), [API.md](API.md).
