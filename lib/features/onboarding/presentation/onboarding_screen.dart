import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';

class _Slide {
  const _Slide(this.emoji, this.title, this.body);
  final String emoji;
  final String title;
  final String body;
}

/// 4-slide onboarding carousel per docs/PRD.md §6 (screen 2) and
/// docs/CONTENT_BN.md §7.1.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.go(Routes.signIn);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final slides = [
      _Slide('⏰', l10n.obTitle1, l10n.obBody1),
      _Slide('🛒', l10n.obTitle2, l10n.obBody2),
      _Slide('💌', l10n.obTitle3, l10n.obBody3),
      _Slide('⚖️', l10n.obTitle4, l10n.obBody4),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(Space.md),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(l10n.obSkip, style: context.text.label.copyWith(color: c.inkMuted)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(slide.emoji, style: const TextStyle(fontSize: 96))
                            .animate(key: ValueKey(index))
                            .fadeIn(duration: Motion.normal)
                            .scale(begin: const Offset(0.7, 0.7), curve: Motion.spring),
                        const SizedBox(height: Space.xxl),
                        Text(
                          slide.title,
                          style: context.text.headline,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Space.md),
                        Text(
                          slide.body,
                          style: context.text.bodyLarge.copyWith(color: c.inkMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: Motion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? c.stamp : c.line,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(Space.screen),
              child: AppButton(
                label: isLast ? l10n.obStart : l10n.obNext,
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(duration: Motion.normal, curve: Motion.enter);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
