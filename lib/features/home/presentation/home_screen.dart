import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paper_card.dart';
import '../../../core/widgets/sticky_note.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      >= 5 && < 12 => l10n.homeGreetingMorning,
      >= 12 && < 17 => l10n.homeGreetingAfternoon,
      >= 17 && < 21 => l10n.homeGreetingEvening,
      _ => l10n.homeGreetingNight,
    };

    final cards = <Widget>[
      StickyNote(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('বিবাহবার্ষিকী', style: context.text.title),
                  const SizedBox(height: Space.sm),
                  Text('৯ ফেব্রুয়ারি, সোমবার', style: context.text.caption),
                ],
              ),
            ),
            Text('💍', style: context.text.display),
          ],
        ),
      ),
      PaperCard(
        tab: 'আজকের বাজার',
        tabColor: c.leaf,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🛒 আজকের বাজার', style: context.text.title),
            const SizedBox(height: Space.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.pill),
              child: LinearProgressIndicator(
                value: 7 / 12,
                minHeight: 8,
                backgroundColor: c.paperDeep,
                color: c.leaf,
              ),
            ),
            const SizedBox(height: Space.xs),
            Text('৭/১২ কেনা', style: context.text.caption.copyWith(color: c.inkMuted)),
          ],
        ),
      ),
      PaperCard(
        tab: 'আজকের দলিল',
        tabColor: c.blush,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✍️ আজ সঙ্গীর কোন কথাটা মনে রাখার মতো?', style: context.text.bodyLarge),
            const SizedBox(height: Space.sm),
            Text('🔥 ১২ দিন', style: context.text.caption.copyWith(color: c.inkMuted)),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$greeting, ম্যাডাম 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            tooltip: 'নোটিফিকেশন',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Space.screen),
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: Space.lg),
        itemBuilder: (context, index) => cards[index]
            .animate(delay: Duration(milliseconds: 40 * index))
            .fadeIn(duration: Motion.normal)
            .slideY(begin: 0.05, end: 0, duration: Motion.normal, curve: Motion.enter),
      ),
    );
  }
}
