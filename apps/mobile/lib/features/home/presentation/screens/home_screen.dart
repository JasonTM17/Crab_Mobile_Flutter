import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_event.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/saved_places.dart';
import '../widgets/service_grid.dart';
import '../widgets/service_tabs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const LoadWallet());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, next) => previous.status != next.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<PaymentBloc>().add(const LoadWallet());
              await Future<void>.delayed(const Duration(milliseconds: 600));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 116),
              children: const [
                _HeroHeader(),
                SizedBox(height: AppSpacing.lg),
                _HomeContent(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 72,
                backgroundColor: cs.surface,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return theme.textTheme.labelSmall?.copyWith(
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                    size: selected ? 24 : 22,
                  );
                }),
                indicatorColor:
                    cs.primary.withValues(alpha: isDark ? 0.24 : 0.14),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.82)),
                  boxShadow: isDark ? null : AppShadows.shadowElevated,
                ),
                child: NavigationBar(
                  selectedIndex: _bottomIndex,
                  onDestinationSelected: (index) {
                    setState(() => _bottomIndex = index);
                    switch (index) {
                      case 1:
                        context.go('/activity');
                        break;
                      case 2:
                        context.go('/chat');
                        break;
                      case 3:
                        context.go('/notifications');
                        break;
                      case 4:
                        context.go('/profile');
                        break;
                    }
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_rounded),
                      selectedIcon: Icon(Icons.history_toggle_off_rounded),
                      label: 'Activity',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline_rounded),
                      selectedIcon: Icon(Icons.chat_bubble_rounded),
                      label: 'Chat',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications_rounded),
                      label: 'Alerts',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SavedPlaces(),
          SizedBox(height: AppSpacing.md),
          _SectionHeaderRow(
            title: 'Dịch vụ nổi bật',
            subtitle: 'Đi xe, ăn uống, mua sắm và ví Crab trong một chạm.',
            actionLabel: 'Tất cả',
            route: '/services',
          ),
          SizedBox(height: AppSpacing.md),
          ServiceGrid(),
          SizedBox(height: AppSpacing.lg),
          _SectionHeaderRow(
            title: 'Khám phá thêm',
            subtitle: 'Lối tắt cho những nhu cầu thường dùng trong ngày.',
          ),
          SizedBox(height: AppSpacing.md),
          ServiceTabs(),
          SizedBox(height: AppSpacing.lg),
          _SectionHeaderRow(
            title: 'Ưu đãi cho bạn',
            subtitle: 'Deal nổi bật giúp chuyến đi và đơn hàng tiết kiệm hơn.',
            actionLabel: 'Xem deal',
            route: '/promos',
          ),
          SizedBox(height: AppSpacing.md),
          PromoCarousel(),
        ],
      ),
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.route,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && route != null) ...[
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () => context.push(route!),
            child: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AuthBloc>().state;
    final user = state.user;
    final name = user?.firstName ?? 'bạn';
    final initials = _initials(user?.firstName, user?.lastName);
    final avatarUrl = user?.avatarUrl;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.shadowElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department_rounded,
                      size: 12, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Crab Super App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Avatar(url: avatarUrl, initials: initials),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào trở lại',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.14),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  tooltip: 'Thông báo',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Đặt xe, ăn uống hay nạp ví - mọi thứ đều ở ngay trước mắt bạn.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _HeroSearchBar(),
          const SizedBox(height: AppSpacing.md),
          const _HeroActionStrip(),
          const SizedBox(height: AppSpacing.md),
          const _WalletPill(),
        ],
      ),
    );
  }

  String _initials(String? first, String? last) {
    final f = (first ?? '').trim();
    final l = (last ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'C';
    if (f.isNotEmpty && l.isNotEmpty) {
      return (f.characters.first + l.characters.first).toUpperCase();
    }
    final source = f.isNotEmpty ? f : l;
    return source.characters.first.toUpperCase();
  }
}

class _HeroSearchBar extends StatelessWidget {
  const _HeroSearchBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: () => context.push(
          '/ride/search?title=Tìm kiếm dịch vụ&hint=Nhập điểm đến, món ăn hoặc ưu đãi',
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'Tìm chuyến xe, món ăn, khuyến mãi...',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroActionStrip extends StatelessWidget {
  const _HeroActionStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HeroActionCard(
            title: 'Đặt xe',
            subtitle: 'Đi ngay',
            icon: Icons.motorcycle_rounded,
            gradient: AppGradients.ocean,
            onTap: () => context.push('/ride/book'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _HeroActionCard(
            title: 'Đồ ăn',
            subtitle: 'Giao nhanh',
            icon: Icons.restaurant_rounded,
            gradient: AppGradients.sunset,
            onTap: () => context.push('/food'),
          ),
        ),
      ],
    );
  }
}

class _HeroActionCard extends StatelessWidget {
  const _HeroActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: AppShadows.shadowGlow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.initials});

  final String? url;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        initials,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );

    if (url == null || url!.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 52,
        height: 52,
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (_, __) => fallback,
          errorWidget: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  const _WalletPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        final isLoading = state is PaymentLoading || state is PaymentInitial;
        String balance = '—';
        if (state is WalletLoaded) {
          balance = _formatVND(state.wallet.balance);
        } else if (state is TopUpSuccess) {
          balance = _formatVND(state.wallet.balance);
        }

        return Semantics(
          button: true,
          label: isLoading
              ? 'Mở ví Crab, đang tải số dư'
              : 'Mở ví Crab, số dư $balance đồng',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/wallet'),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Ink(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.14)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CrabPay balance',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (isLoading)
                            const ShimmerBox(
                              width: 118,
                              height: 24,
                              borderRadius: 10,
                            )
                          else
                            Text(
                              '$balance đ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatVND(num value) {
    final source = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var index = 0; index < source.length; index++) {
      buffer.write(source[index]);
      final remaining = source.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }
}
