import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// A tilted rubber-stamp label — "মঞ্জুর", "দোষী", "সম্পন্ন" — per
/// docs/DESIGN_SYSTEM.md §6.2.
class Stamp extends StatelessWidget {
  const Stamp({super.key, required this.label, this.color, this.animate = true});

  final String label;
  final Color? color;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.stamp;
    final stamp = Transform.rotate(
      angle: -0.14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: c, width: 3),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Text(
            label,
            style: context.text.display.copyWith(fontSize: 26, color: c),
          ),
        ),
      ),
    );
    if (!animate || MediaQuery.disableAnimationsOf(context)) return stamp;
    return stamp
        .animate()
        .scale(
          begin: const Offset(2.2, 2.2),
          end: const Offset(1, 1),
          duration: Motion.normal,
          curve: Motion.stamp,
        )
        .fadeIn(duration: Motion.fast)
        .then()
        .shakeX(hz: 4, amount: 2, duration: const Duration(milliseconds: 160));
  }
}
