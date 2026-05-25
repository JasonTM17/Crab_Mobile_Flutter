import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../shared/services/auth_storage.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';

import '../../features/home/presentation/screens/activity_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/services_screen.dart';

import '../../features/ride/presentation/screens/ride_booking_screen.dart';
import '../../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../../features/ride/presentation/screens/location_search_screen.dart';
import '../../features/ride/presentation/screens/ride_history_screen.dart';
import '../../features/ride/driver/presentation/screens/driver_mode_screen.dart';
import '../../features/ride/driver/presentation/screens/driver_earnings_screen.dart';

import '../../features/food/presentation/screens/restaurant_list_screen.dart';
import '../../features/food/presentation/screens/restaurant_detail_screen.dart';
import '../../features/food/presentation/screens/restaurant_menu_screen.dart';
import '../../features/food/presentation/screens/cart_screen.dart';
import '../../features/food/presentation/screens/order_tracking_screen.dart';
import '../../features/food/presentation/screens/order_history_screen.dart';

import '../../features/payment/presentation/screens/wallet_screen.dart';
import '../../features/payment/presentation/screens/top_up_screen.dart';
import '../../features/payment/presentation/screens/promos_screen.dart';
import '../../features/payment/presentation/screens/transaction_history_screen.dart';
import '../../features/payment/presentation/screens/transfer_screen.dart';

import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';

import '../../features/notifications/presentation/screens/notifications_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/saved_addresses_screen.dart';
import '../../features/profile/presentation/screens/security_screen.dart';

import '../../features/rating/presentation/screens/submit_rating_screen.dart';

import 'splash_screen.dart';
import 'onboarding_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // ── Bootstrap ─────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Auth ─────────────────────────────────────────────────
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Home ─────────────────────────────────────────────────
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/activity',
        builder: (_, __) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (_, __) => const ServicesScreen(),
      ),
      GoRoute(
        path: '/promos',
        builder: (_, __) => const PromosScreen(),
      ),

      // ── Ride (rider) ─────────────────────────────────────────
      GoRoute(
        path: '/ride/book',
        builder: (_, __) => const RideBookingScreen(),
      ),
      GoRoute(
        path: '/ride/search',
        builder: (_, state) {
          final title = state.uri.queryParameters['title'] ?? 'Search';
          final hint = state.uri.queryParameters['hint'] ?? 'Search location';
          return LocationSearchScreen(title: title, hint: hint);
        },
      ),
      GoRoute(
        path: '/ride/history',
        builder: (_, __) => const RideHistoryScreen(),
      ),
      GoRoute(
        path: '/ride/:id',
        builder: (_, state) =>
            RideTrackingScreen(rideId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ride/:id/rate',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final driverName = state.uri.queryParameters['name'] ?? 'your driver';
          return SubmitRatingScreen(
            targetType: 'ride',
            targetId: id,
            targetName: driverName,
          );
        },
      ),

      // ── Driver mode ──────────────────────────────────────────
      GoRoute(
        path: '/driver/dashboard',
        builder: (_, __) => const DriverModeScreen(),
      ),
      GoRoute(
        path: '/driver/earnings',
        builder: (_, __) => const DriverEarningsScreen(),
      ),

      // ── Food ─────────────────────────────────────────────────
      GoRoute(path: '/food', builder: (_, __) => const RestaurantListScreen()),
      GoRoute(
        path: '/food/restaurant/:id',
        builder: (_, state) => const RestaurantMenuScreen(),
      ),
      GoRoute(
        path: '/food/restaurant/:id/info',
        builder: (_, __) => const RestaurantDetailScreen(),
      ),
      GoRoute(path: '/food/cart', builder: (_, __) => const CartScreen()),
      GoRoute(
        path: '/food/order/:id',
        builder: (_, state) =>
            OrderTrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/food/orders',
        builder: (_, __) => const OrderHistoryScreen(),
      ),

      // ── Wallet / Payment ─────────────────────────────────────
      GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
      GoRoute(path: '/wallet/topup', builder: (_, __) => const TopUpScreen()),
      GoRoute(
        path: '/wallet/transfer',
        builder: (_, __) => const TransferScreen(),
      ),
      GoRoute(
        path: '/wallet/transactions',
        builder: (_, __) => const TransactionHistoryScreen(),
      ),

      // ── Chat ─────────────────────────────────────────────────
      GoRoute(path: '/chat', builder: (_, __) => const ConversationsScreen()),
      GoRoute(
        path: '/chat/:roomId',
        builder: (_, state) =>
            ChatRoomScreen(roomId: state.pathParameters['roomId']!),
      ),

      // ── Notifications ────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),

      // ── Profile ──────────────────────────────────────────────
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/addresses',
        builder: (_, __) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: '/profile/security',
        builder: (_, __) => const SecurityScreen(),
      ),
    ],
    redirect: (context, state) async {
      // Public routes that never require auth
      const publicPaths = <String>{
        '/splash',
        '/onboarding',
        '/login',
        '/register',
        '/otp',
        '/forgot-password',
      };
      if (publicPaths.contains(state.uri.path)) return null;

      try {
        final isAuthed = await sl<AuthStorage>().isAuthenticated();
        if (!isAuthed) return '/login';
      } catch (_) {
        return '/login';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Route not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
