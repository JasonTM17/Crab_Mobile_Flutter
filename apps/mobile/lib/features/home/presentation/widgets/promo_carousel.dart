import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_motion.dart';
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
      image:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      route: '/promos',
    ),
    _PromoSlide(
      title: 'Freeship đơn từ 100K',
      cta: 'Đặt ngay',
      image:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
      route: '/food',
    ),
    _PromoSlide(
      title: 'Hoàn 5% mỗi chuyến',
      cta: 'Tìm hiểu',
      image: null,
      route: '/wallet',
    ),
    _PromoSlide(
      title: 'Đổi điểm lấy quà',
      cta: 'Nhận thưởng',
      image: null,
      route: '/promos',
    ),
  ];

  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
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
          height: 160,
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
    required this.cta,
    required this.route,
    this.image,
  });

  final String title;
  final String cta;
  final String? image;
  final String route;
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.slide});

  final _PromoSlide slide;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(slide.route),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A3D), Color(0xFFC2185B)],
            ),
          ),
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
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC000000)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        slide.cta,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
