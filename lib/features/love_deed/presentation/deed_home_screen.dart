import 'package:flutter/material.dart';

import '../../../core/widgets/mascot_state.dart';
import '../../../l10n/app_localizations.dart';

class DeedHomeScreen extends StatelessWidget {
  const DeedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDeed)),
      body: Center(
        child: MascotState(
          mascot: Mascot.korta,
          title: l10n.emptyDeedTitle,
          body: l10n.emptyDeedBody,
          actionLabel: l10n.emptyDeedAction,
          onAction: () {},
        ),
      ),
    );
  }
}
