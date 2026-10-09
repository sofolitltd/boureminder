import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// "সংসার জুড়ে গেল!" celebration, per docs/PRD.md §4.1 acceptance criteria.
class PairingSuccessScreen extends ConsumerStatefulWidget {
  const PairingSuccessScreen({super.key});

  @override
  ConsumerState<PairingSuccessScreen> createState() => _PairingSuccessScreenState();
}

class _PairingSuccessScreenState extends ConsumerState<PairingSuccessScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final partner = ref.watch(onboardingControllerProvider).partnerName ?? '';

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(Space.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💞', style: TextStyle(fontSize: 96))
                      .animate()
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        duration: Motion.celebrate,
                        curve: Motion.stamp,
                      )
                      .fadeIn(duration: Motion.normal),
                  const SizedBox(height: Space.xl),
                  Text(l10n.pairingSuccessTitle, style: context.text.headline, textAlign: TextAlign.center),
                  const SizedBox(height: Space.sm),
                  Text(
                    l10n.pairingSuccessBody(partner),
                    style: context.text.body.copyWith(color: c.inkMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Space.xxl),
                  AppButton(
                    label: l10n.pairingSuccessContinue,
                    onPressed: () => context.go(Routes.weddingDate),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 2,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 24,
            gravity: 0.25,
            colors: [c.stamp, c.marigold, c.leaf, c.mint, c.gold],
          ),
        ],
      ),
    );
  }
}
