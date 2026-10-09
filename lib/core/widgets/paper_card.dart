import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// A white card with 20-radius corners and an optional file-tab label,
/// per docs/DESIGN_SYSTEM.md §6.3.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.tab,
    this.tabColor,
    this.onTap,
  });

  final Widget child;
  final String? tab;
  final Color? tabColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tab != null)
          Container(
            margin: const EdgeInsets.only(left: Space.xl),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: tabColor ?? c.marigold,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Radii.sm),
              ),
            ),
            child: Text(tab!, style: context.text.caption.copyWith(color: c.ink)),
          ),
        Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Radii.card),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.card),
                border: Border.all(color: c.line),
                boxShadow: dark
                    ? null
                    : [
                        BoxShadow(
                          color: c.ink.withValues(alpha: .06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              padding: const EdgeInsets.all(Space.lg + 2),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
