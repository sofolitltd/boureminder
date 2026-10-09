import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// A yellow sticky note tilted between -2° and +2°, with a red pin at the
/// top, per docs/DESIGN_SYSTEM.md §6.1. Used on the home screen for
/// reminders.
class StickyNote extends StatelessWidget {
  const StickyNote({super.key, required this.child, this.seed = 0});

  final Widget child;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final angleDeg = (Random(seed).nextDouble() * 4 - 2);
    return Transform.rotate(
      angle: angleDeg * pi / 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: Space.md),
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
              color: c.sticky,
              borderRadius: BorderRadius.circular(Radii.md),
              boxShadow: [
                BoxShadow(
                  color: c.ink.withValues(alpha: .1),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
          Positioned(
            top: 0,
            left: Space.xl,
            child: Icon(Icons.push_pin_rounded, color: c.stamp, size: 28),
          ),
        ],
      ),
    );
  }
}
