import 'package:flutter/material.dart';

import 'shimmer_box.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 72,
    this.spacing = 12,
    this.padding = EdgeInsets.zero,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(itemCount, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i == itemCount - 1 ? 0 : spacing),
            child: _SkeletonRow(height: itemHeight),
          );
        }),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          ShimmerBox(width: height - 16, height: height - 16, borderRadius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 160, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
          const ShimmerBox(width: 60, height: 14),
        ],
      ),
    );
  }
}
