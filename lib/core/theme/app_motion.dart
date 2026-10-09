import 'package:flutter/animation.dart';

/// Motion tokens from docs/DESIGN_SYSTEM.md §7.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);

  /// Love-deed screens use a slower, softer rhythm.
  static const Duration emotional = Duration(milliseconds: 700);
  static const Duration celebrate = Duration(milliseconds: 1400);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;

  /// A slight overshoot, used for stamps landing.
  static const Curve stamp = Cubic(0.2, 1.4, 0.4, 1.0);
  static const Curve gentle = Curves.easeInOutSine;
}
