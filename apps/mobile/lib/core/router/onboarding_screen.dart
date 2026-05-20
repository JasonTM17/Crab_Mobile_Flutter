import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_shadows.dart';
import '../../shared/widgets/animated_dot_indicator.dart';
import '../../shared/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = <_OnboardSlide>[
    _OnboardSlide(
      icon: Icons.directions_car_filled_rounded,
      gradient: AppGradients.primary,
      title: 'Rides on demand',
      body:
          'Book bikes, cars and 7-seaters in seconds. See real-time fare and live ETA from matched drivers.',
    ),
    _OnboardSlide(
      icon: Icons.restaurant_menu_rounded,
      gradient: AppGradients.sunset,
      title: 'Food, Mart, Express',
      body:
          'Order from your favorite restaurants, get groceries, send packages — all in one beautiful app.',
    ),
    _OnboardSlide(
      icon: Icons.account_balance_wallet_rounded,
      gradient: AppGradients.violet,
      title: 'Pay your way',
      body:
          'Use Crab Wallet or cash. Earn loyalty points and apply promo codes at checkout — instantly.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppShadows.shadowGlow,
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) =>
                    _SlideView(slide: _slides[i], active: i == _index),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDotIndicator(count: _slides.length, activeIndex: _index),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => context.go('/register'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 1.4,
                          ),
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: isLast ? 'Get Started' : 'Next',
                      icon:
                          isLast ? Icons.arrow_forward_rounded : Icons.east_rounded,
                      onPressed: () {
                        if (isLast) {
                          context.go('/login');
                        } else {
                          _controller.nextPage(
                            duration: AppMotion.normal,
                            curve: AppMotion.standard,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String body;
  const _OnboardSlide({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.body,
  });
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.active});
  final _OnboardSlide slide;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: active ? 1.0 : 0.92,
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                gradient: slide.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: slide.gradient.colors.first.withValues(alpha: 0.32),
                    blurRadius: 36,
                    spreadRadius: 4,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Icon(slide.icon, size: 96, color: Colors.white),
            ),
          ),
          const SizedBox(height: 44),
          AnimatedSlide(
            offset: active ? Offset.zero : const Offset(0, 0.04),
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            child: AnimatedOpacity(
              opacity: active ? 1.0 : 0.6,
              duration: AppMotion.normal,
              child: Column(
                children: [
                  Text(
                    slide.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    slide.body,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
