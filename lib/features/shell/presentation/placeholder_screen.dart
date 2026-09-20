import 'package:flutter/material.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Hali qurilmagan bo'lim mazmuni (E15–E18 da haqiqiy ekranlar bilan
/// almashtiriladi). Sarlavha panel — qobiqda (E14-T04).
class PlaceholderScreen extends StatelessWidget {
  const new({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: icon,
    title: title,
    message: AppL10n.of(context).comingSoon,
  );
}
