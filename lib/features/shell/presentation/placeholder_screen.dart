import 'package:flutter/material.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Hali qurilmagan bo'lim ekrani (E15–E18 da haqiqiy ekranlar bilan
/// almashtiriladi).
class PlaceholderScreen extends StatelessWidget {
  const new({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: icon,
        title: AppL10n.of(context).emptyTitle,
        message: AppL10n.of(context).comingSoon,
      ),
    );
  }
}
