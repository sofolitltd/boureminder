import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_toast.dart';
import '../core/widgets/mascot_state.dart';
import '../core/widgets/paper_card.dart';
import '../core/widgets/skeleton_list.dart';
import '../core/widgets/stamp.dart';
import '../core/widgets/sticky_note.dart';
import '../l10n/app_localizations.dart';

/// Dev-only screen that shows every shared component in light and dark
/// mode, per docs/TASKS.md M0 ("একটা /_gallery ডেভ-স্ক্রিন").
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Theme(
      data: _mode == ThemeMode.dark ? AppTheme.dark : AppTheme.light,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.galleryTitle),
          actions: [
            IconButton(
              icon: Icon(_mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () => setState(() {
                _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              }),
            ),
          ],
        ),
        body: Builder(
          builder: (context) => ListView(
            padding: const EdgeInsets.all(Space.screen),
            children: [
              Text('AppButton', style: context.text.title),
              const SizedBox(height: Space.sm),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  AppButton(label: 'পাঠিয়ে দিন', onPressed: () {}),
                  AppButton(label: 'বাতিল', variant: AppButtonVariant.secondary, onPressed: () {}),
                  AppButton(label: 'স্কিপ', variant: AppButtonVariant.text, onPressed: () {}),
                  const AppButton(label: 'নিষ্ক্রিয়'),
                ],
              ),
              const SizedBox(height: Space.xl),
              Text('PaperCard', style: context.text.title),
              const SizedBox(height: Space.sm),
              PaperCard(
                tab: 'আজকের বাজার',
                tabColor: context.colors.leaf,
                child: Text('এক ট্যাপে বাজারের ফর্দ পাঠান।', style: context.text.body),
              ),
              const SizedBox(height: Space.xl),
              Text('StickyNote', style: context.text.title),
              const SizedBox(height: Space.sm),
              StickyNote(child: Text('বিবাহবার্ষিকী ৯ দিন বাকি 💍', style: context.text.bodyLarge)),
              const SizedBox(height: Space.xl),
              Text('Stamp', style: context.text.title),
              const SizedBox(height: Space.sm),
              Wrap(
                spacing: Space.lg,
                children: [
                  Stamp(label: 'সম্পন্ন', color: context.colors.leaf),
                  Stamp(label: 'দোষী'),
                  Stamp(label: 'খালাস', color: context.colors.mint),
                ],
              ),
              const SizedBox(height: Space.xl),
              Text('MascotState', style: context.text.title),
              const SizedBox(height: Space.sm),
              PaperCard(
                child: MascotState(
                  mascot: Mascot.ginni,
                  title: l10n.emptyBazarTitle,
                  body: l10n.emptyBazarBody,
                  actionLabel: l10n.emptyBazarAction,
                  onAction: () {},
                ),
              ),
              const SizedBox(height: Space.xl),
              Text('AppToast', style: context.text.title),
              const SizedBox(height: Space.sm),
              AppButton(
                label: 'টোস্ট দেখান',
                variant: AppButtonVariant.secondary,
                onPressed: () => AppToast.show(context, message: 'ফর্দ পৌঁছে গেছে! 🛒'),
              ),
              const SizedBox(height: Space.xl),
              Text('SkeletonList', style: context.text.title),
              const SizedBox(height: Space.sm),
              const SizedBox(height: 220, child: SkeletonList()),
            ],
          ),
        ),
      ),
    );
  }
}
