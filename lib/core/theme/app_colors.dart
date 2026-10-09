import 'package:flutter/material.dart';

/// Design tokens from docs/DESIGN_SYSTEM.md §3.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.paper,
    required this.paperDeep,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.stamp,
    required this.onStamp,
    required this.marigold,
    required this.sticky,
    required this.leaf,
    required this.mint,
    required this.blush,
    required this.gold,
    required this.danger,
  });

  final Color paper;
  final Color paperDeep;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color line;
  final Color stamp;
  final Color onStamp;
  final Color marigold;
  final Color sticky;
  final Color leaf;
  final Color mint;
  final Color blush;
  final Color gold;
  final Color danger;

  static const light = AppColors(
    paper: Color(0xFFFFF8EE),
    paperDeep: Color(0xFFF6ECDC),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2B2A4C),
    inkMuted: Color(0xFF6B6880),
    line: Color(0xFFE8DCCB),
    stamp: Color(0xFFD7263D),
    onStamp: Color(0xFFFFFFFF),
    marigold: Color(0xFFF4A259),
    sticky: Color(0xFFFFE58A),
    leaf: Color(0xFF3E8E41),
    mint: Color(0xFF2EC4B6),
    blush: Color(0xFFF7C5CC),
    gold: Color(0xFFC9A227),
    danger: Color(0xFFB3261E),
  );

  static const dark = AppColors(
    paper: Color(0xFF1C1714),
    paperDeep: Color(0xFF14100E),
    surface: Color(0xFF2A231F),
    ink: Color(0xFFF3EDE4),
    inkMuted: Color(0xFFB5ADA3),
    line: Color(0xFF3A322C),
    stamp: Color(0xFFFF5A6E),
    onStamp: Color(0xFF1C1714),
    marigold: Color(0xFFF7B57A),
    sticky: Color(0xFF5C4E1E),
    leaf: Color(0xFF7BC96F),
    mint: Color(0xFF4FD8CB),
    blush: Color(0xFF5A3A40),
    gold: Color(0xFFE0BE4A),
    danger: Color(0xFFF2B8B5),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      paper: l(paper, other.paper),
      paperDeep: l(paperDeep, other.paperDeep),
      surface: l(surface, other.surface),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      line: l(line, other.line),
      stamp: l(stamp, other.stamp),
      onStamp: l(onStamp, other.onStamp),
      marigold: l(marigold, other.marigold),
      sticky: l(sticky, other.sticky),
      leaf: l(leaf, other.leaf),
      mint: l(mint, other.mint),
      blush: l(blush, other.blush),
      gold: l(gold, other.gold),
      danger: l(danger, other.danger),
    );
  }
}
