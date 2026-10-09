import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/paper_card.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Notification permission primer + battery-optimization guide, per
/// docs/PRD.md §4.1 and docs/CONTENT_BN.md §7.3. The last onboarding screen.
///
/// No permission plugin is wired up yet, so this just records the user's
/// choice locally — hook up a real permission request (and the OEM battery
/// settings deep link) once a plugin like `permission_handler` is added.
class NotificationPrimerScreen extends ConsumerWidget {
  const NotificationPrimerScreen({super.key});

  void _finish(BuildContext context, WidgetRef ref, {required bool granted}) {
    ref.read(onboardingControllerProvider.notifier).setNotificationsGranted(granted);
    ref.read(onboardingControllerProvider.notifier).complete();
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('🔔', style: context.text.display),
              const SizedBox(height: Space.lg),
              Text(l10n.notifPrimerTitle, style: context.text.headline),
              const SizedBox(height: Space.sm),
              Text(l10n.notifPrimerBody, style: context.text.body.copyWith(color: c.inkMuted)),
              const SizedBox(height: Space.xl),
              PaperCard(
                tab: l10n.batteryGuideTitle,
                tabColor: c.marigold,
                child: Text(l10n.batteryGuideBody, style: context.text.body),
              ),
              const Spacer(),
              AppButton(
                label: l10n.notifPrimerAllow,
                onPressed: () => _finish(context, ref, granted: true),
              ),
              const SizedBox(height: Space.sm),
              Center(
                child: TextButton(
                  onPressed: () => _finish(context, ref, granted: false),
                  child: Text(l10n.notifPrimerLater, style: context.text.label.copyWith(color: c.inkMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
