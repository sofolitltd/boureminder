import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../theme/app_spacing.dart';
import 'paper_card.dart';

/// A skeleton placeholder for a list of PaperCards while data loads.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: const EdgeInsets.all(Space.screen),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: Space.lg),
        itemBuilder: (context, index) => PaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 18, width: 160, color: Colors.black12),
              const SizedBox(height: Space.sm),
              Container(height: 14, width: double.infinity, color: Colors.black12),
              const SizedBox(height: Space.xs),
              Container(height: 14, width: 220, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}
