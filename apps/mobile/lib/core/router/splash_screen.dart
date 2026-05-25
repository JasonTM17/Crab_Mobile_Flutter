import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_motion.dart';
import '../../shared/services/auth_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final AnimationController _orbController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _logoController.forward();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _logoController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final delay = Future<void>.delayed(const Duration(milliseconds: 1100));

    bool authed = false;
    try {
      authed = await sl<AuthStorage>().isAuthenticated();
    } catch (_) {
      authed = false;
    }

    await delay;
    if (!mounted) return;
    context.go(authed ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.primary),
        child: Stack(
          children: [
            // Floating glow orbs
            AnimatedBuilder(
              animation: _orbController,
              builder: (_, __) {
                final t = _orbController.value;
                return Stack(
                  children: [
                    Positioned(
                      top: -80 + (t * 24),
                      right: -60 - (t * 16),
                      child: _orb(220, Colors.white.withValues(alpha: 0.18)),
                    ),
                    Positioned(
                      bottom: -100 - (t * 32),
                      left: -80 + (t * 20),
                      child: _orb(260, Colors.white.withValues(alpha: 0.10)),
                    ),
                  ],
                );
              },
            ),

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_taxi_rounded,
                            size: 64,
                            color: Color(0xFF00B14F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FadeTransition(
                      opacity: _logoFade,
                      child: const Text(
                        'Crab',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _logoFade,
                      child: Text(
                        'One app, every ride',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    const _DotsLoader(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _DotsLoader extends StatefulWidget {
  const _DotsLoader();

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (_c.value + i * 0.18) % 1.0;
          final scale =
              0.7 + (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0) * 0.6;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 9,
            height: 9,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()..scaleByDouble(scale, scale, 1, 1),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
