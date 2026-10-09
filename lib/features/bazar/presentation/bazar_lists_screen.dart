import 'package:flutter/material.dart';

import '../../../core/widgets/mascot_state.dart';
import '../../../l10n/app_localizations.dart';

class BazarListsScreen extends StatelessWidget {
  const BazarListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navBazar)),
      body: Center(
        child: MascotState(
          mascot: Mascot.ginni,
          title: l10n.emptyBazarTitle,
          body: l10n.emptyBazarBody,
          actionLabel: l10n.emptyBazarAction,
          onAction: () {},
        ),
      ),
    );
  }
}
