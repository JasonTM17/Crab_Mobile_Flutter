import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/rating_model.dart';
import '../bloc/rating_bloc.dart';
import '../bloc/rating_event.dart';
import '../bloc/rating_state.dart';
import '../widgets/rating_stats_card.dart';
import '../widgets/review_tile.dart';

class ReviewsScreen extends StatefulWidget {
  final String targetType;
  final String targetId;
  final String targetName;

  const ReviewsScreen({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RatingBloc>().add(
          LoadReviews(
            targetType: widget.targetType,
            targetId: widget.targetId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.targetName} Reviews')),
      body: BlocBuilder<RatingBloc, RatingState>(
        builder: (context, state) {
          if (state is RatingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RatingError) {
            return Center(child: Text(state.message));
          }
          if (state is ReviewsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.stats != null)
                  RatingStatsCard(stats: state.stats!),
                const SizedBox(height: 16),
                if (state.reviews.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('No reviews yet',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...state.reviews.map((r) => ReviewTile(review: r)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
