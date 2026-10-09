import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens from docs/DESIGN_SYSTEM.md §4.
@immutable
class AppText extends ThemeExtension<AppText> {
  const AppText({
    required this.display,
    required this.headline,
    required this.title,
    required this.bodyLarge,
    required this.body,
    required this.label,
    required this.caption,
    required this.letter,
  });

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle bodyLarge;
  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle letter;

  static AppText of(Color ink) => AppText(
        display: TextStyle(
          fontFamily: 'BalooDa2',
          fontSize: 36,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        headline: TextStyle(
          fontFamily: 'BalooDa2',
          fontSize: 26,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        title: TextStyle(
          fontFamily: 'BalooDa2',
          fontSize: 20,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'HindSiliguri',
          fontSize: 17,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: ink,
        ),
        body: TextStyle(
          fontFamily: 'HindSiliguri',
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: ink,
        ),
        label: TextStyle(
          fontFamily: 'HindSiliguri',
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        caption: TextStyle(
          fontFamily: 'HindSiliguri',
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
        letter: TextStyle(
          fontFamily: 'TiroBangla',
          fontSize: 18,
          height: 1.75,
          fontWeight: FontWeight.w400,
          color: ink,
        ),
      );

  static final light = AppText.of(AppColors.light.ink);
  static final dark = AppText.of(AppColors.dark.ink);

  @override
  AppText copyWith() => this;

  @override
  AppText lerp(ThemeExtension<AppText>? other, double t) {
    if (other is! AppText) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppText(
      display: l(display, other.display),
      headline: l(headline, other.headline),
      title: l(title, other.title),
      bodyLarge: l(bodyLarge, other.bodyLarge),
      body: l(body, other.body),
      label: l(label, other.label),
      caption: l(caption, other.caption),
      letter: l(letter, other.letter),
    );
  }
}
