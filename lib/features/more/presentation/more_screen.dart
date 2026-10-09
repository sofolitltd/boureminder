import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(IconData, String)>[
      (Icons.gavel_rounded, 'মামলার তালিকা'),
      (Icons.event_rounded, 'বিশেষ দিনের তালিকা'),
      (Icons.checkroom_rounded, 'ওয়ার্ডরোব ও লেজার'),
      (Icons.bar_chart_rounded, 'মাসিক রিপোর্ট'),
      (Icons.sentiment_satisfied_rounded, 'সরি জেনারেটর'),
      (Icons.handshake_rounded, 'প্রতিশ্রুতি'),
      (Icons.settings_rounded, 'সেটিংস'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, _) => Divider(height: 1, color: context.colors.line),
        itemBuilder: (context, index) {
          final (icon, label) = items[index];
          return ListTile(
            leading: Icon(icon, color: context.colors.stamp),
            title: Text(label, style: context.text.bodyLarge),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.comingSoon)),
            ),
          );
        },
      ),
    );
  }
}
