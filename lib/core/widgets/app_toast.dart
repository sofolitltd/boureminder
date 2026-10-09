import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// A banner that slides down from the top — used for foreground pushes and
/// success confirmations, per docs/DESIGN_SYSTEM.md §6.1.
class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_rounded,
    Color? color,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _ToastBanner(message: message, icon: icon, color: color),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), entry.remove);
  }
}

class _ToastBanner extends StatefulWidget {
  const _ToastBanner({required this.message, required this.icon, this.color});

  final String message;
  final IconData icon;
  final Color? color;

  @override
  State<_ToastBanner> createState() => _ToastBannerState();
}

class _ToastBannerState extends State<_ToastBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Motion.normal)..forward();
  late final Animation<Offset> _offset = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Motion.enter));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Positioned(
      top: MediaQuery.paddingOf(context).top + Space.sm,
      left: Space.lg,
      right: Space.lg,
      child: SlideTransition(
        position: _offset,
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.color ?? c.leaf),
                const SizedBox(width: Space.sm),
                Expanded(child: Text(widget.message, style: context.text.body)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
