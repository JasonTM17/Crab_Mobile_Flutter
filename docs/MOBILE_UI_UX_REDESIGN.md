# Mobile User UI/UX Redesign Plan

This document is the execution guide for finishing the customer-facing Flutter app UI/UX from end to end. It covers the design system, user flows, accessibility, release media, and verification gates for the rider, food, wallet, chat, notifications, and profile surfaces.

## Source Guidance

The plan follows the current Flutter and Material guidance:

- Flutter Material Design: https://docs.flutter.dev/ui/design/material
- Material 3 default migration notes: https://docs.flutter.dev/release/breaking-changes/material-3-default
- Flutter adaptive and responsive design: https://docs.flutter.dev/ui/adaptive-responsive
- Flutter layout guidance: https://docs.flutter.dev/ui/layout
- Flutter accessibility testing: https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Flutter accessible UI design and styling: https://docs.flutter.dev/ui/accessibility/ui-design-and-styling

Key rules applied to Crab:

- Material 3 is the baseline; app styling should flow from `ColorScheme`, `TextTheme`, and component themes.
- Layouts must survive small screens, large font settings, orientation changes, and dense real data.
- Accessibility checks must include contrast, target size, target labels, large text, and semantics for custom controls.
- Public media must use seeded success states and never expose real credentials, locations, phone numbers, balances, or tokens.

## Product Direction

Crab mobile should feel like a trustworthy Vietnam-first super app: operationally clear like Grab and Be, warmer and more local in tone, but quieter and more premium than a colorful demo app. Use those products as category references for speed, trust, and daily utility; do not copy their logos, exact palettes, illustrations, or proprietary UI assets.

Portfolio goal:

- The repo should look like a production product case study, not only a code archive.
- A reviewer should understand the mobile app in under 60 seconds from README media.
- Screenshots must show real app surfaces with believable demo data, strong hierarchy, and no debug/test artifacts.
- The GIF should demonstrate a complete user journey, not random screen switching.

Design principles:

- Trust first: wallet, login, ride, order, and profile screens must feel safe and predictable.
- One task per viewport: every screen should make the next action obvious.
- Calm density: lists can be rich, but spacing, hierarchy, and icon weight must prevent clutter.
- Local clarity: Vietnamese copy is preferred for user-facing labels, with concise action verbs.
- Real states: screenshots and demos must show populated success states, not skeletons or empty placeholders.

## Design System Targets

Canonical files:

- `apps/mobile/lib/core/theme/app_theme.dart`
- `apps/mobile/lib/core/theme/app_gradients.dart`
- `apps/mobile/lib/core/theme/app_motion.dart`
- `apps/mobile/lib/core/theme/app_shadows.dart`
- `apps/mobile/lib/shared/widgets/`

Rules:

- Keep `useMaterial3: true`.
- Use green as the brand anchor, amber for rewards/promos and high-intent CTAs, and teal/blue only for supporting trust/status moments.
- Keep `letterSpacing` at `0` for readability, especially with Vietnamese copy.
- Prefer component themes and shared widgets over one-off styling inside screens.
- Cards should carry grouped information, not wrap whole page sections.
- Primary CTAs use `GradientButton` or `FilledButton`; secondary actions use `OutlinedButton` or `TextButton`.
- Touch targets should be at least 44 px and ideally 48-56 px for primary controls.
- Text must not rely on viewport-scaled font sizes; use stable theme tokens.
- Pressed/loading/disabled states must be visible without changing layout bounds.
- Async ride, food, wallet, and chat surfaces should show skeleton or progress feedback instead of blank screens.

## Current Design Pass

The 2026-05-27 ClaudeKit design pass used `ck:ui-ux-pro-max`,
`ck:ui-styling`, and `ck:stitch` as references for the portfolio polish pass.

- UI direction: vibrant consumer super-app, high trust, dense but scannable.
- Interaction floor: 44 px minimum tap targets, 8 px spacing between adjacent controls, visible pressed feedback within 100 ms, and 150-300 ms motion for state changes.
- Accessibility floor: primary text contrast at least 4.5:1, secondary text at least 3:1, semantic labels for icon-only controls, and no status conveyed by color alone.
- Web/admin styling note: use existing Tailwind/shadcn patterns and semantic tokens; do not introduce mobile-only visual effects into operational admin screens.
- Stitch exploration project: `projects/4717497996278762059` (`Crab Super App Portfolio Redesign`).

## Stitch Design Handoff

Google Stitch has been used as the visual north star for the remaining mobile polish pass.

- Stitch project: `projects/11313197299470137632`
- Stitch screen: `projects/11313197299470137632/screens/7ddff908d78c4ceaa549f61704c12038`
- Stitch screen title: `Crab Flow Command`
- Stitch design system asset: `assets/309e16af633a470f8690156d571c644b`
- Local execution notes: `plans/260527-0929-mobile-user-redesign-and-release-media/stitch-design-handoff.md`

Implementation should preserve the Stitch direction: premium operational super app, compact 4px/8px rhythm, 16px mobile margins, 44px minimum touch targets, clear route/fare/ETA decisions, scannable restaurant cards, and a reusable wallet/support/profile trust strip.

## A-Z Flow Scope

| Area | Screens | UX Goal | Done When |
| --- | --- | --- | --- |
| Bootstrap | Splash, onboarding | Clear value, trust, fast CTA path | Onboarding explains rides, food, wallet in 3 focused slides |
| Auth | Login, register, OTP, forgot password | Safe, fast, low-friction account entry | Forms are readable, error states clear, auth behavior unchanged |
| Home | Home, activity, services | Top tasks are obvious | Ride, food, wallet, promos, activity, alerts are one tap away |
| Ride | Booking, search, tracking, history, rating handoff | Calm decisions under pressure | Pickup/dropoff, fare, ETA, driver, status are easy to scan |
| Food | Restaurant list/detail/menu/cart/tracking/history | Fast discovery and safe checkout | Menu, cart totals, order status, and delivery progress are clear |
| Wallet | Wallet, top-up, transfer, transactions, promos | Financial trust | Balance, actions, transaction rows, and promos are legible |
| Chat | Conversations, chat detail | Quiet realtime messaging | Read/unread, sender, timestamps, and composer are clear |
| Notifications | Notification center | Low-noise updates | Notification groups and read state are obvious |
| Profile | Profile, edit, saved addresses, security | Account confidence | Identity, addresses, security, and logout are grouped predictably |
| Release media | Screenshots, GIFs | Public polish proof | Docs show current seeded success states and at least one mobile GIF |

## Portfolio Media Matrix

These assets are the target public set for the portfolio version of the project.

| Asset | File | Purpose | Required State |
| --- | --- | --- | --- |
| Onboarding hero | `docs/screenshots/mobile-01-onboarding.png` | First impression and brand story | Localized copy, clear CTA, no placeholder art |
| Login | `docs/screenshots/mobile-client-01-login.png` | Auth trust and polish | Phone/email form visible, safe demo copy, no real credentials |
| Signed-in home | `docs/screenshots/mobile-client-02-home.png` | Super-app breadth | Populated wallet, services, promos, and clear top actions |
| Ride booking | `docs/screenshots/mobile-client-03-ride-booking.png` | Core ride value | Pickup/dropoff, fare/ETA, vehicle choice, confirm CTA |
| Food discovery | `docs/screenshots/mobile-client-04-food.png` | Food product depth | Populated restaurant/menu state with ratings and delivery time |
| Wallet/profile trust | `docs/screenshots/mobile-client-05-wallet-profile.png` | Account and financial trust | Demo balance, transactions, profile/security cues |
| Customer GIF | `docs/gifs/mobile-client-flow.gif` | Portfolio walkthrough | Onboarding or home to booking/order flow, stable and readable |

Minimum acceptable portfolio set:

- Onboarding
- Login
- Signed-in home
- One core flow screenshot: ride or food
- One mobile GIF

Preferred final set:

- All screenshots in the matrix plus one GIF.

## Implementation Phases

The active project plan lives under `plans/260527-0929-mobile-user-redesign-and-release-media/`.

1. Design System and Content Direction
   - Lock color, type, spacing, motion, card, CTA, list, and copy rules.
   - Build the screen-state matrix for success, loading, empty, error, and permission states.
   - Add accessibility acceptance rules before expanding the redesign.

2. Onboarding, Login, Home
   - Finish the highest-visibility user surfaces first.
   - Keep routing/auth behavior stable.
   - Refresh screenshot tests for onboarding, login, and signed-in home.

3. Ride and Food Core Flows
   - Redesign ride booking/search/tracking/history.
   - Redesign restaurant discovery/menu/cart/order tracking/history.
   - Normalize status chips, pricing, ETAs, progress indicators, maps, and bottom sheets.

4. Wallet, Chat, Notifications, Profile
   - Finish trust and retention surfaces.
   - Normalize list rows, section headers, quick actions, empty states, and account/security cues.

5. Release Media and Docs
   - Capture current screenshots from seeded states.
   - Add one user-facing mobile GIF.
   - Sync README, screenshot gallery, deployment docs, and mobile docs.
   - Present mobile media in README as a short product story: first impression, signed-in home, core flow, trust surface.

6. Verification and Release Readiness
   - Run mobile analyze and targeted tests.
   - Check accessibility, large text, contrast, target labels, and state density.
   - Reject screenshots that are empty, stale, low-information, or inconsistent with the live UI.

## Acceptance Criteria

The redesign is not complete until all of these are true:

- The app has one coherent visual language across onboarding, auth, home, ride, food, wallet, chat, notifications, and profile.
- Customer-facing Vietnamese labels are concise, consistent, and not mixed with random English except product names.
- No mobile UI code uses negative `letterSpacing`.
- Critical actions have adequate touch target size and clear disabled/loading/error states.
- Dense screens remain readable with realistic seeded data.
- Core route behavior and business logic remain unchanged unless a change is explicitly documented.
- Release screenshots and GIFs match the final UI and use non-sensitive seeded data.
- `docs/MOBILE.md`, `docs/screenshots/README.md`, and `README.md` reference current mobile assets.
- Targeted mobile tests and screenshot tests pass before release.
- Portfolio media tells a coherent product story: onboarding -> login/home -> core action -> trust/account surface.
- GIF is short, stable, and readable without requiring narration.

## Screenshot Standards

Every public screenshot must pass this checklist:

- Use a real Flutter widget or emulator capture, not a mockup pasted into docs.
- Show a populated success state unless the docs explicitly discuss empty or error states.
- Use demo-safe names, addresses, balances, phone numbers, and message content.
- Avoid status bars, debug banners, overflows, test labels, stack traces, and loading skeletons.
- Keep the viewport consistent, preferably 390 x 844 for phone captures.
- Do not crop out navigation or the primary CTA when that CTA explains the screen.
- Reject screenshots where the main screen purpose is not obvious in 3 seconds.

## GIF Standards

The portfolio GIF should be treated like a mini product demo.

Target specs:

- Length: 6-12 seconds.
- Width: 390 px or a clean 2x export of that size.
- Frame rate: 12-18 fps for smooth but lightweight playback.
- File size target: under 8 MB when practical.
- Flow: onboarding -> login -> home, or home -> ride booking, or home -> food ordering.
- Motion: slow enough to read labels and CTAs.
- State: fully seeded; no loading spinner should dominate the clip.

Reject the GIF if:

- Text is unreadable at README size.
- The cursor/tap path feels random.
- The clip shows blank screens, emulator chrome noise, debug banners, or unstable layout jumps.
- The flow does not communicate a clear user value.

## README Presentation Rules

The README mobile section should read like a compact case study:

1. One sentence describing the customer app.
2. Screenshot row or gallery showing onboarding, login, home, and one core flow.
3. One GIF showing a complete mobile journey.
4. Short bullet list of implemented mobile capabilities.
5. Link to `docs/MOBILE.md` and this redesign guide for technical depth.

Do not overload the README with implementation details that belong in docs. The README should sell the portfolio quickly; detailed architecture belongs in `docs/MOBILE.md`.

## Verification Commands

Run from the repo root unless noted:

```bash
pnpm --filter @crab/mobile lint
pnpm --filter @crab/mobile test
```

For Flutter-native checks:

```bash
cd apps/mobile
flutter analyze
flutter test
```

To refresh release screenshots:

```bash
pnpm run mobile:screenshots
```

To validate the screenshot widget states without rewriting media:

```bash
pnpm --filter @crab/mobile test -- test/release_media_screenshots_test.dart
```

## Documentation Deliverables

- `docs/MOBILE_UI_UX_REDESIGN.md`: this execution guide.
- `docs/MOBILE.md`: architecture plus link to the redesign guide.
- `docs/screenshots/README.md`: release media gallery and capture checklist.
- `README.md`: public-facing mobile screenshots and GIF narrative after media refresh.
- `plans/260527-0929-mobile-user-redesign-and-release-media/`: private phase plan for execution tracking.

## Risks

- Visual polish can hide broken flows. Mitigation: keep route behavior stable and test touched flows.
- Dense ride/food screens can become pretty but slower to use. Mitigation: prioritize task clarity over decoration.
- Screenshots can drift from live UI. Mitigation: use deterministic capture tests where possible.
- Accessibility can regress in custom cards and hero surfaces. Mitigation: add guideline checks and large-font review to the verification phase.
