import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, text }

/// Pill-shaped 52px-tall action button, per docs/DESIGN_SYSTEM.md §6.1.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onPressed != null;

    final (Color bg, Color fg, Border? border) = switch (widget.variant) {
      AppButtonVariant.primary => (c.stamp, c.onStamp, null),
      AppButtonVariant.secondary => (
          Colors.transparent,
          c.ink,
          Border.all(color: c.line, width: 1.5),
        ),
      AppButtonVariant.text => (Colors.transparent, c.stamp, null),
    };

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 90),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        child: Material(
          color: enabled ? bg : bg.withValues(alpha: .4),
          borderRadius: BorderRadius.circular(Radii.pill),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(Radii.pill),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: Space.xl),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.pill),
                border: border,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: fg, size: 20),
                    const SizedBox(width: Space.sm),
                  ],
                  Text(widget.label, style: context.text.label.copyWith(color: fg)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
