import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// OTP verification, 6 boxes, per docs/PRD.md §6 (screen 3). Mocked: any
/// 6-digit code succeeds (see [OnboardingController.verifyOtp]).
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());
  bool _error = false;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _error = false);
    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_code.length == _length) {
      _verify();
    }
  }

  void _verify() {
    final ok = ref.read(onboardingControllerProvider.notifier).verifyOtp(_code);
    if (ok) {
      context.go(Routes.profile);
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final phone = ref.watch(onboardingControllerProvider).phone ?? '';

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(Space.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.otpTitle, style: context.text.headline),
            const SizedBox(height: Space.xs),
            Text(
              l10n.otpSubtitle(phone),
              style: context.text.body.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: Space.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _length; i++)
                  SizedBox(
                    width: 44,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      autofocus: i == 0,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: context.text.title,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: c.surface,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Radii.md),
                          borderSide: BorderSide(color: _error ? c.danger : c.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Radii.md),
                          borderSide: BorderSide(color: _error ? c.danger : c.line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Radii.md),
                          borderSide: BorderSide(color: c.stamp, width: 1.5),
                        ),
                      ),
                      onChanged: (value) => _onDigitChanged(i, value),
                    ),
                  ),
              ],
            ),
            if (_error) ...[
              const SizedBox(height: Space.md),
              Text(l10n.otpWrong, style: context.text.caption.copyWith(color: c.danger)),
            ],
            const SizedBox(height: Space.xl),
            Center(
              child: TextButton(
                onPressed: _secondsLeft == 0 ? _startCountdown : null,
                child: Text(
                  _secondsLeft == 0 ? l10n.otpResend : l10n.otpResendIn(_secondsLeft),
                  style: context.text.label.copyWith(color: c.inkMuted),
                ),
              ),
            ),
            const Spacer(),
            AppButton(
              label: l10n.otpVerify,
              onPressed: _code.length == _length ? _verify : null,
            ),
          ],
        ),
      ),
    );
  }
}
