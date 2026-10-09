import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/paper_card.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Couple pairing: share my code/QR, or enter/scan the partner's, per
/// docs/PRD.md §4.1 & §6 (screen 5) and docs/CONTENT_BN.md §7.2.
class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _codeController = TextEditingController();
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final existing = ref.read(onboardingControllerProvider).myCode;
      if (existing == null) {
        ref.read(onboardingControllerProvider.notifier).generateMyCode();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pairingCopied)));
  }

  void _submitCode([String? scanned]) {
    final code = scanned ?? _codeController.text;
    final error = ref.read(onboardingControllerProvider.notifier).submitPartnerCode(code);
    if (!mounted) return;
    if (error == null) {
      final data = ref.read(onboardingControllerProvider);
      if (data.sameRoleAsPartner) {
        _showSameRoleWarning();
      } else {
        context.go(Routes.pairingSuccess);
      }
    } else {
      setState(() => _errorKey = error);
    }
  }

  void _showSameRoleWarning() {
    final l10n = AppLocalizations.of(context);
    final data = ref.read(onboardingControllerProvider);
    final roleLabel = data.role == CoupleRole.husband ? l10n.profileRoleHusband : l10n.profileRoleWife;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.pairingSameRoleWarning(roleLabel)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(Routes.pairingSuccess);
            },
            child: Text(l10n.pairingSameRoleContinue),
          ),
        ],
      ),
    );
  }

  Future<void> _openScanner() async {
    final result = await context.push<String>(Routes.pairingScan);
    if (result != null) {
      _codeController.text = result;
      _submitCode(result);
    }
  }

  String? _errorText(AppLocalizations l10n) => switch (_errorKey) {
        'pairingErrorInvalid' => l10n.pairingErrorInvalid,
        'pairingErrorExpired' => l10n.pairingErrorExpired,
        'pairingErrorOwnCode' => l10n.pairingErrorOwnCode,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pairingTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: c.stamp,
          unselectedLabelColor: c.inkMuted,
          indicatorColor: c.stamp,
          tabs: [
            Tab(text: l10n.pairingTabShare),
            Tab(text: l10n.pairingTabEnter),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ShareCodeTab(onCopy: _copyCode),
          Padding(
            padding: const EdgeInsets.all(Space.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pairingEnterHint, style: context.text.body.copyWith(color: c.inkMuted)),
                const SizedBox(height: Space.lg),
                AppTextField(
                  controller: _codeController,
                  label: l10n.pairingEnterLabel,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: context.text.title.copyWith(letterSpacing: 4),
                  onChanged: (_) => setState(() => _errorKey = null),
                ),
                if (_errorText(l10n) != null) ...[
                  const SizedBox(height: Space.sm),
                  Text(_errorText(l10n)!, style: context.text.caption.copyWith(color: c.danger)),
                ],
                const SizedBox(height: Space.lg),
                AppButton(
                  label: l10n.pairingScanButton,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: _openScanner,
                ),
                const SizedBox(height: Space.lg),
                AppButton(
                  label: l10n.pairingSubmit,
                  onPressed: _codeController.text.trim().length == 6 ? () => _submitCode() : null,
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(onboardingControllerProvider.notifier).skipPairing();
                      context.go(Routes.home);
                    },
                    child: Text(l10n.pairingSkip, style: context.text.label.copyWith(color: c.inkMuted)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCodeTab extends ConsumerStatefulWidget {
  const _ShareCodeTab({required this.onCopy});

  final Future<void> Function(String code) onCopy;

  @override
  ConsumerState<_ShareCodeTab> createState() => _ShareCodeTabState();
}

class _ShareCodeTabState extends ConsumerState<_ShareCodeTab> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(onboardingControllerProvider);
    final code = data.myCode ?? '------';
    final remaining = data.codeRemaining ?? Duration.zero;
    final hoursLeft = remaining.inMinutes / 60;

    return Padding(
      padding: const EdgeInsets.all(Space.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: Space.lg),
          Text(
            l10n.pairingShareHint,
            style: context.text.body.copyWith(color: c.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Space.xl),
          PaperCard(
            child: Column(
              children: [
                QrImageView(
                  data: code,
                  size: 180,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: c.ink),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: Space.lg),
                Text(
                  code,
                  style: context.text.display.copyWith(letterSpacing: 8, fontSize: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          Text(
            l10n.pairingCodeExpiry(hoursLeft.ceil()),
            style: context.text.caption.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: Space.xl),
          AppButton(
            label: l10n.pairingCopyCode,
            icon: Icons.copy_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => widget.onCopy(code),
          ),
        ],
      ),
    );
  }
}
