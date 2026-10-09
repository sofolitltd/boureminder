import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppText get text => Theme.of(this).extension<AppText>()!;
}

abstract final class AppTheme {
  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final text = isDark ? AppText.dark : AppText.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.stamp,
      brightness: brightness,
      surface: colors.surface,
      onSurface: colors.ink,
      primary: colors.stamp,
      onPrimary: colors.onStamp,
      error: colors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.paper,
      colorScheme: colorScheme,
      fontFamily: 'HindSiliguri',
      extensions: [colors, text],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.paper,
        foregroundColor: colors.ink,
        elevation: 0,
        titleTextStyle: text.headline,
      ),
      textTheme: TextTheme(
        displayLarge: text.display,
        headlineMedium: text.headline,
        titleLarge: text.title,
        bodyLarge: text.bodyLarge,
        bodyMedium: text.body,
        labelLarge: text.label,
        bodySmall: text.caption,
      ),
      dividerColor: colors.line,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
