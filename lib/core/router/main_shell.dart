import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Bottom nav shell: হোম · ফর্দ · ➕ · দলিল · আরও, per
/// docs/SYSTEM_DESIGN.md §8. The middle ➕ isn't a branch — it opens a
/// bottom sheet of quick-add actions.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);

    void goBranch(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.navHome,
                  selected: shell.currentIndex == 0,
                  onTap: () => goBranch(0),
                ),
                _NavItem(
                  icon: Icons.shopping_bag_rounded,
                  label: l10n.navBazar,
                  selected: shell.currentIndex == 1,
                  onTap: () => goBranch(1),
                ),
                _QuickAddButton(onTap: () => _showQuickAdd(context, l10n)),
                _NavItem(
                  icon: Icons.mail_rounded,
                  label: l10n.navDeed,
                  selected: shell.currentIndex == 2,
                  onTap: () => goBranch(2),
                ),
                _NavItem(
                  icon: Icons.menu_rounded,
                  label: l10n.navMore,
                  selected: shell.currentIndex == 3,
                  onTap: () => goBranch(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickAdd(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      builder: (context) => _QuickAddSheet(l10n: l10n),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.stamp : c.inkMuted;
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(label, style: context.text.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Semantics(
        label: 'নতুন যোগ করুন',
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c.stamp,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: c.ink.withValues(alpha: .2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(Icons.add_rounded, color: c.onStamp, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      (Icons.shopping_bag_rounded, l10n.quickAddBazar),
      (Icons.checklist_rounded, l10n.quickAddChore),
      (Icons.mail_rounded, l10n.quickAddDeed),
      (Icons.gavel_rounded, l10n.quickAddCase),
      (Icons.task_alt_rounded, l10n.quickAddChoreLog),
      (Icons.handshake_rounded, l10n.quickAddPromise),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (icon, label) in items)
                    ListTile(
                      leading: Icon(icon, color: context.colors.stamp),
                      title: Text(label, style: context.text.bodyLarge),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
