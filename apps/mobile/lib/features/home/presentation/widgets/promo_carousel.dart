import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../shared/widgets/animated_dot_indicator.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  static const _slides = <_PromoSlide>[
    _PromoSlide(
      title: '50% OFF',
      subtitle: 'First ride with code WELCOME50',
      tag: 'New users',
      icon: Icons.local_offer,
      gradient: AppGradients.primary,
      route: '/promos',
    ),
    _PromoSlide(
      title: 'Free delivery',
      subtitle: 'On orders over 100K this week',
      tag: 'Food',
      icon: Icons.restaurant_menu,
      gradient: AppGradients.sunset,
      route: '/food',
    ),
    _PromoSlide(
      title: 'Earn 5x points',
      subtitle: 'Every Crab Pay transfer until Sunday',
      tag: 'Pay',
      icon: Icons.workspace_premium,
      gradient: AppGradients.violet,
      route: '/wallet',
    ),
  ];

  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _timer = Timer.periodic(const Duration(seconds: 4), _autoAdvance);
  }

  void _autoAdvance(Timer _) {
    if (!mounted || !_controller.hasClients) return;
    final next = (_index + 1) % _slides.length;
    _controller.animateToPage(
      next,
      duration: AppMotion.carousel,
      curve: AppMotion.emphasis,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final s = _slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PromoCard(slide: s),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        AnimatedDotIndicator(
          count: _slides.length,
          activeIndex: _index,
        ),
      ],
    );
  }
}

class _PromoSlide {
  const _PromoSlide({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.gradient,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final LinearGradient gradient;
  final String route;
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.slide});

  final _PromoSlide slide;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(slide.route),
      child: Container(
        decoration: BoxDecoration(
          gradient: slide.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.coloredGlow(
            slide.gradient.colors.first,
            opacity: 0.25,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -20,
              child: Icon(
                slide.icon,
                size: 140,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    slide.tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slide.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
