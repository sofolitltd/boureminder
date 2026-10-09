import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Sign-in: phone OTP / Google / Apple, per docs/PRD.md §4.1 & §6 (screen 3).
///
/// There's no Firebase project wired into this app yet (see
/// docs/SYSTEM_DESIGN.md §3), so Google/Apple just continue the local mock
/// flow — swap these for real `firebase_auth` calls once that's set up.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canSend => _phoneController.text.trim().length >= 11;

  void _sendOtp() {
    ref.read(onboardingControllerProvider.notifier).sendOtp(_phoneController.text.trim());
    context.push(Routes.otp);
  }

  void _continueWithProvider() {
    ref.read(onboardingControllerProvider.notifier).sendOtp('—');
    ref.read(onboardingControllerProvider.notifier).verifyOtp('000000');
    context.go(Routes.profile);
  }

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
              Text('🔑', style: context.text.display),
              const SizedBox(height: Space.lg),
              Text(l10n.signInTitle, style: context.text.headline),
              const SizedBox(height: Space.xs),
              Text(l10n.signInSubtitle, style: context.text.body.copyWith(color: c.inkMuted)),
              const SizedBox(height: Space.xl),
              AppTextField(
                controller: _phoneController,
                label: l10n.signInPhoneLabel,
                hintText: l10n.signInPhoneHint,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Space.lg),
              AppButton(
                label: l10n.signInSendOtp,
                onPressed: _canSend ? _sendOtp : null,
              ),
              const SizedBox(height: Space.xl),
              Row(
                children: [
                  Expanded(child: Divider(color: c.line)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.md),
                    child: Text(l10n.signInOr, style: context.text.caption.copyWith(color: c.inkMuted)),
                  ),
                  Expanded(child: Divider(color: c.line)),
                ],
              ),
              const SizedBox(height: Space.xl),
              AppButton(
                label: l10n.signInGoogle,
                variant: AppButtonVariant.secondary,
                icon: Icons.g_mobiledata_rounded,
                onPressed: _continueWithProvider,
              ),
              const SizedBox(height: Space.md),
              AppButton(
                label: l10n.signInApple,
                variant: AppButtonVariant.secondary,
                icon: Icons.apple_rounded,
                onPressed: _continueWithProvider,
              ),
              const SizedBox(height: Space.xl),
              Text(
                l10n.signInTerms,
                style: context.text.caption.copyWith(color: c.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
