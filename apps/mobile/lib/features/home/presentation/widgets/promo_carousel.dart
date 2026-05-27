import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../../../payment/data/models/payment_models.dart';
import '../../../payment/data/repositories/payment_repository.dart';
import '../../../../shared/widgets/animated_dot_indicator.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {

  late final Future<List<_PromoSlide>> _slidesFuture;
  int _slideCount = 0;

  static const _gradients = <LinearGradient>[
    AppGradients.sunset,
    AppGradients.primary,
    AppGradients.walletHero,
    AppGradients.violet,
  ];

  static const _fallbackSlides = <_PromoSlide>[
    _PromoSlide(
      title: 'Ưu đãi Crab đang được cập nhật',
      cta: 'Mở trung tâm ưu đãi',
      route: '/promos',
      gradient: AppGradients.walletHero,
      badge: 'Ưu đãi',
    ),
  ];

  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    _slidesFuture = _loadSlides();
    _timer = Timer.periodic(const Duration(seconds: 4), _autoAdvance);
  }

  Future<List<_PromoSlide>> _loadSlides() async {
    try {
      final promos = await sl<PaymentRepository>().getAvailablePromos();
      if (promos.isEmpty) return _fallbackSlides;
      return promos.take(5).map(_slideFromPromo).toList(growable: false);
    } catch (_) {
      return _fallbackSlides;
    }
  }

  _PromoSlide _slideFromPromo(PromoModel promo) {
    final index = promo.code.hashCode.abs() % _gradients.length;
    final title = promo.description.trim().isEmpty
        ? 'Ưu đãi ${promo.code}'
        : promo.description.trim();
    return _PromoSlide(
      title: title,
      cta: 'Dùng mã ${promo.code}',
      route: '/promos',
      gradient: _gradients[index],
      badge: promo.displayDiscount,
    );
  }

  void _autoAdvance(Timer _) {
    if (!mounted || !_controller.hasClients) return;
    if (_slideCount <= 1) return;
    final next = (_index + 1) % _slideCount;
    _controller.animateToPage(next,
        duration: AppMotion.carousel, curve: AppMotion.emphasis);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_PromoSlide>>(
      future: _slidesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 176,
            width: double.infinity,
            child: ShimmerBox(height: 176, borderRadius: AppRadii.xl),
          );
        }

        final slides = snapshot.data?.isNotEmpty == true
            ? snapshot.data!
            : _fallbackSlides;
        _slideCount = slides.length;

        return Column(
          children: [
            SizedBox(
              height: 176,
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        right: index == slides.length - 1 ? 0 : AppSpacing.sm),
                    child: _PromoCard(slide: slides[index]),
                  );
                },
              ),
            ),
            if (slides.length > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              AnimatedDotIndicator(count: slides.length, activeIndex: _index),
            ],
          ],
        );
      },
    );
  }
}

class _PromoSlide {
  const _PromoSlide({
    required this.title,
    required this.cta,
    required this.route,
    required this.gradient,
    required this.badge,
  });

  final String title;
  final String cta;
  final String route;
  final String badge;
  final LinearGradient gradient;
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.slide});

  final _PromoSlide slide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(slide.route),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Ink(
          decoration: BoxDecoration(
            gradient: slide.gradient,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppShadows.shadowElevated,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.42)
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24)),
                    ),
                    child: Text(
                      slide.badge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slide.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slide.cta,
                              style: const TextStyle(
                                  color: AppColors.textPrimaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 16, color: AppColors.textPrimaryLight),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
