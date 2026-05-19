import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../shared/services/auth_storage.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';

import '../../features/ride/presentation/screens/ride_booking_screen.dart';
import '../../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../../features/ride/presentation/screens/location_search_screen.dart';
import '../../features/ride/driver/presentation/screens/driver_mode_screen.dart';

import '../../features/food/presentation/screens/restaurant_list_screen.dart';
import '../../features/food/presentation/screens/restaurant_detail_screen.dart';
import '../../features/food/presentation/screens/restaurant_menu_screen.dart';
import '../../features/food/presentation/screens/cart_screen.dart';
import '../../features/food/presentation/screens/order_tracking_screen.dart';

import '../../features/payment/presentation/screens/wallet_screen.dart';
import '../../features/payment/presentation/screens/top_up_screen.dart';

import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/chat/presentation/screens/chat_detail_screen.dart';

import '../../features/notifications/presentation/screens/notifications_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/rating/presentation/screens/submit_rating_screen.dart';

import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'placeholder_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // ── Bootstrap ─────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Auth ─────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Forgot Password',
          message: 'Password reset is being wired up.',
        ),
      ),

      // ── Home ─────────────────────────────────────────────────
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/activity',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Activity',
          message: 'Recent rides and orders will appear here.',
        ),
      ),
      GoRoute(
        path: '/services',
        builder: (_, __) => const PlaceholderScreen(
          title: 'All Services',
          message: 'Mart, Express and more services coming.',
        ),
      ),
      GoRoute(
        path: '/promos',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Promotions',
          message: 'Active promo codes will be listed here.',
        ),
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
        builder: (_, __) => const PlaceholderScreen(
          title: 'Ride History',
          message: 'Past rides will appear here.',
        ),
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
          final driverName =
              state.uri.queryParameters['name'] ?? 'your driver';
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
        builder: (_, __) => const PlaceholderScreen(
          title: 'Earnings',
          message: 'Daily and weekly earnings dashboard.',
        ),
      ),

      // ── Food ─────────────────────────────────────────────────
      GoRoute(
        path: '/food',
        builder: (_, __) => const RestaurantListScreen(),
      ),
      GoRoute(
        path: '/food/restaurant/:id',
        builder: (_, state) => RestaurantMenuScreen(
          // restaurantId surfaced via query for now
          key: ValueKey(state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/food/restaurant/:id/info',
        builder: (_, __) => const RestaurantDetailScreen(),
      ),
      GoRoute(
        path: '/food/cart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: '/food/order/:id',
        builder: (_, __) => const OrderTrackingScreen(),
      ),
      GoRoute(
        path: '/food/orders',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Order History',
          message: 'Your past food orders.',
        ),
      ),

      // ── Wallet / Payment ─────────────────────────────────────
      GoRoute(
        path: '/wallet',
        builder: (_, __) => const WalletScreen(),
      ),
      GoRoute(
        path: '/wallet/topup',
        builder: (_, __) => const TopUpScreen(),
      ),
      GoRoute(
        path: '/wallet/transfer',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Transfer',
          message: 'Send money to another Crab user.',
        ),
      ),
      GoRoute(
        path: '/wallet/transactions',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Transactions',
          message: 'Wallet transaction history.',
        ),
      ),

      // ── Chat ─────────────────────────────────────────────────
      GoRoute(
        path: '/chat',
        builder: (_, __) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:roomId',
        builder: (_, state) => PlaceholderScreen(
          title: 'Chat ${state.pathParameters['roomId']}',
          message: 'Open chat from the conversation list to load messages.',
        ),
      ),

      // ── Notifications ────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),

      // ── Profile ──────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Edit Profile',
          message: 'Update your name, phone, avatar.',
        ),
      ),
      GoRoute(
        path: '/profile/addresses',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Saved Addresses',
          message: 'Home, Work and other places.',
        ),
      ),
      GoRoute(
        path: '/profile/security',
        builder: (_, __) => const PlaceholderScreen(
          title: 'Security',
          message: 'Password, biometric and 2FA.',
        ),
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
