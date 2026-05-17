import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Rate & Review')),
      body: BlocListener<RatingBloc, RatingState>(
        listener: (context, state) {
          if (state is RatingSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thank you for your review!')),
            );
            Navigator.of(context).pop(true);
          }
          if (state is RatingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Text(
                'How was your experience with\n${widget.targetName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        size: 48,
                        color: Colors.amber,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getRatingLabel(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _tags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a review (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<RatingBloc, RatingState>(
              builder: (context, state) {
                return SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _rating > 0 && state is! RatingLoading
                        ? _submit
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is RatingLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit Review',
                            style: TextStyle(fontSize: 16)),
                  ),
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
