import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/animated_dot_indicator.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  static const _slides = <_PromoSlide>[
    _PromoSlide(
      title: 'Giảm 50K cho đơn đầu',
      cta: 'Xem ngay',
      route: '/promos',
      image:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      gradient: AppGradients.sunset,
      badge: 'Ưu đãi hot',
    ),
    _PromoSlide(
      title: 'Freeship đơn từ 100K',
      cta: 'Đặt ngay',
      route: '/food',
      image:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
      gradient: AppGradients.primary,
      badge: 'Food',
    ),
    _PromoSlide(
      title: 'Hoàn 5% mỗi chuyến',
      cta: 'Tìm hiểu',
      route: '/wallet',
      gradient: AppGradients.walletHero,
      badge: 'Ví Crab',
    ),
    _PromoSlide(
      title: 'Đổi điểm lấy quà',
      cta: 'Nhận thưởng',
      route: '/promos',
      gradient: AppGradients.violet,
      badge: 'Thành viên',
    ),
  ];

  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    _timer = Timer.periodic(const Duration(seconds: 4), _autoAdvance);
  }

  void _autoAdvance(Timer _) {
    if (!mounted || !_controller.hasClients) return;
    final next = (_index + 1) % _slides.length;
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
    return Column(
      children: [
        SizedBox(
          height: 176,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                    right: index == _slides.length - 1 ? 0 : AppSpacing.sm),
                child: _PromoCard(slide: _slides[index]),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedDotIndicator(count: _slides.length, activeIndex: _index),
      ],
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
    this.image,
  });

  final String title;
  final String cta;
  final String route;
  final String badge;
  final LinearGradient gradient;
  final String? image;
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
                if (slide.image != null)
                  CachedNetworkImage(
                    imageUrl: slide.image!,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 250),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.14),
                        Colors.black.withValues(alpha: 0.52)
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
                          letterSpacing: -0.3,
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
