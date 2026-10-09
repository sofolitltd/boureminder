import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Name, nickname, role & birthday, per docs/PRD.md §4.1 & §6 (screen 4).
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  CoupleRole? _role;
  DateTime? _birthday;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty && _role != null && _birthday != null;

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 28),
      firstDate: DateTime(now.year - 90),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  void _continue() {
    ref.read(onboardingControllerProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          nickname: _nicknameController.text.trim().isEmpty
              ? _nameController.text.trim()
              : _nicknameController.text.trim(),
          role: _role!,
          birthday: _birthday!,
        );
    context.go(Routes.pairing);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.profileTitle, style: context.text.headline),
            const SizedBox(height: Space.xs),
            Text(l10n.profileSubtitle, style: context.text.body.copyWith(color: c.inkMuted)),
            const SizedBox(height: Space.xl),
            AppTextField(
              controller: _nameController,
              label: l10n.profileNameLabel,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Space.lg),
            AppTextField(
              controller: _nicknameController,
              label: l10n.profileNicknameLabel,
              hintText: l10n.profileNicknameHint,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: Space.lg),
            Text(l10n.profileRoleLabel, style: context.text.label.copyWith(color: c.inkMuted)),
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Expanded(
                  child: _RoleChip(
                    emoji: '🤵',
                    label: l10n.profileRoleHusband,
                    selected: _role == CoupleRole.husband,
                    onTap: () => setState(() => _role = CoupleRole.husband),
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: _RoleChip(
                    emoji: '👰',
                    label: l10n.profileRoleWife,
                    selected: _role == CoupleRole.wife,
                    onTap: () => setState(() => _role = CoupleRole.wife),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.lg),
            Text(l10n.profileBirthdayLabel, style: context.text.label.copyWith(color: c.inkMuted)),
            const SizedBox(height: Space.sm),
            InkWell(
              onTap: _pickBirthday,
              borderRadius: BorderRadius.circular(Radii.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: c.line),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cake_rounded, color: c.inkMuted, size: 20),
                    const SizedBox(width: Space.sm),
                    Text(
                      _birthday == null
                          ? l10n.profileBirthdayPick
                          : DateFormat.yMMMMd('bn').format(_birthday!),
                      style: context.text.bodyLarge.copyWith(
                        color: _birthday == null ? c.inkMuted : c.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.xxl),
            AppButton(
              label: l10n.profileContinue,
              onPressed: _canContinue ? _continue : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: Space.lg),
        decoration: BoxDecoration(
          color: selected ? c.sticky : c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: selected ? c.stamp : c.line, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: Space.xs),
            Text(label, style: context.text.label.copyWith(color: c.ink)),
          ],
        ),
      ),
    );
  }
}
