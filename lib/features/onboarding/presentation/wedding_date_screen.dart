import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Wedding date entry, asked right after pairing, per docs/PRD.md §4.1.
class WeddingDateScreen extends ConsumerStatefulWidget {
  const WeddingDateScreen({super.key});

  @override
  ConsumerState<WeddingDateScreen> createState() => _WeddingDateScreenState();
}

class _WeddingDateScreenState extends ConsumerState<WeddingDateScreen> {
  DateTime? _date;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 2),
      firstDate: DateTime(now.year - 70),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _confirm() {
    if (_date == null) return;
    ref.read(onboardingControllerProvider.notifier).confirmWeddingDate(_date!);
    context.go(Routes.notificationPrimer);
  }

  void _skip() => context.go(Routes.notificationPrimer);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💍', style: context.text.display),
              const SizedBox(height: Space.lg),
              Text(l10n.weddingDateTitle, style: context.text.headline),
              const SizedBox(height: Space.xs),
              Text(l10n.weddingDateSubtitle, style: context.text.body.copyWith(color: c.inkMuted)),
              const SizedBox(height: Space.xl),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(Radii.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.lg),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: c.line),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: c.stamp, size: 22),
                      const SizedBox(width: Space.sm),
                      Text(
                        _date == null ? l10n.weddingDatePick : DateFormat.yMMMMd('bn').format(_date!),
                        style: context.text.bodyLarge.copyWith(
                          color: _date == null ? c.inkMuted : c.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.xl),
              AppButton(
                label: l10n.weddingDateConfirm,
                onPressed: _date != null ? _confirm : null,
              ),
              const SizedBox(height: Space.sm),
              Center(
                child: TextButton(
                  onPressed: _skip,
                  child: Text(l10n.weddingDateSkip, style: context.text.label.copyWith(color: c.inkMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
