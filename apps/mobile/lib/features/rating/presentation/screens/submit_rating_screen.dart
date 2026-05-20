import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../bloc/rating_bloc.dart';
import '../bloc/rating_event.dart';
import '../bloc/rating_state.dart';

class SubmitRatingScreen extends StatefulWidget {
  final String targetType;
  final String targetId;
  final String targetName;
  final String? rideId;
  final String? orderId;

  const SubmitRatingScreen({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    this.rideId,
    this.orderId,
  });

  @override
  State<SubmitRatingScreen> createState() => _SubmitRatingScreenState();
}

class _SubmitRatingScreenState extends State<SubmitRatingScreen> {
  double _rating = 0;
  final _commentController = TextEditingController();
  final _tags = <String>[];

  final _availableTags = [
    'Friendly',
    'On time',
    'Clean vehicle',
    'Good food',
    'Fast delivery',
    'Professional',
    'Safe driving',
    'Great service',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rate & review',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocListener<RatingBloc, RatingState>(
        listener: (context, state) {
          if (state is RatingSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Thank you for your review!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.of(context).pop(true);
          }
          if (state is RatingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                'How was your experience\nwith ${widget.targetName}?',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _StarRow(
              rating: _rating,
              onSelect: (v) => setState(() => _rating = v.toDouble()),
            ),
            const SizedBox(height: 12),
            Center(
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Text(
                  _getRatingLabel(),
                  key: ValueKey(_rating.toInt()),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _rating == 0
                        ? cs.onSurfaceVariant
                        : cs.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Highlight what was great',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _availableTags.map((tag) {
                final selected = _tags.contains(tag);
                return _TagChip(
                  label: tag,
                  selected: selected,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _tags.remove(tag);
                      } else {
                        _tags.add(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tell us more (optional)',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            BlocBuilder<RatingBloc, RatingState>(
              builder: (context, state) {
                final loading = state is RatingLoading;
                return GradientButton(
                  label: 'Submit review',
                  icon: Icons.send_rounded,
                  height: 56,
                  onPressed: _rating > 0 && !loading ? _submit : null,
                  loading: loading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    context.read<RatingBloc>().add(SubmitRating(
          targetType: widget.targetType,
          targetId: widget.targetId,
          score: _rating,
          comment: _commentController.text.trim().isNotEmpty
              ? _commentController.text.trim()
              : null,
          tags: _tags.isNotEmpty ? _tags : null,
          rideId: widget.rideId,
          orderId: widget.orderId,
        ));
  }

  String _getRatingLabel() {
    switch (_rating.toInt()) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap a star to rate';
    }
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.onSelect});
  final double rating;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return GestureDetector(
          onTap: () => onSelect(index + 1),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()..scale(filled ? 1.08 : 1.0),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 52,
              color: filled
                  ? const Color(0xFFFBBF24)
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? cs.primary : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded, size: 14, color: cs.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? cs.primary : cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
