import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// A paper-styled text field: rounded, filled with [AppColors.surface], a
/// soft border that turns stamp-red on focus. Used across sign-in, profile
/// setup and pairing per docs/DESIGN_SYSTEM.md §6.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.autofocus = false,
    this.style,
    this.onChanged,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final bool autofocus;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.text.label.copyWith(color: c.inkMuted)),
          const SizedBox(height: Space.xs),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: textAlign,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          autofocus: autofocus,
          onChanged: onChanged,
          style: style ?? context.text.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.text.bodyLarge.copyWith(color: c.inkMuted),
            filled: true,
            fillColor: c.surface,
            counterText: '',
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              borderSide: BorderSide(color: c.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              borderSide: BorderSide(color: c.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              borderSide: BorderSide(color: c.stamp, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
