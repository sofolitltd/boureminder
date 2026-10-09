import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Which mascot to show. Rive assets aren't wired up yet, so this renders a
/// static icon fallback per docs/DESIGN_SYSTEM.md §10 ("প্রতিটি অ্যানিমেশনের
/// একটি স্থির ফলব্যাক রাখুন").
enum Mascot { ginni, korta }

/// Empty / error / loading state: mascot + one line of copy + optional
/// button, per docs/DESIGN_SYSTEM.md §6.1 and §8.7.
class MascotState extends StatelessWidget {
  const MascotState({
    super.key,
    required this.mascot,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final Mascot mascot;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = switch (mascot) {
      Mascot.ginni => Icons.receipt_long_rounded,
      Mascot.korta => Icons.shopping_bag_rounded,
    };
    return Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: c.paperDeep,
            child: Icon(icon, size: 40, color: c.marigold),
          ),
          const SizedBox(height: Space.lg),
          Text(title, style: context.text.title, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: Space.sm),
            Text(
              body!,
              style: context.text.body.copyWith(color: c.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: Space.lg),
            AppButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
