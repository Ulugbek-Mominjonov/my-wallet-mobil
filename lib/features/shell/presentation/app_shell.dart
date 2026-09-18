import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Pastki navigatsiya: 4 bo'lim + o'rtada "＋" (ARXITEKTURA 7-bo'lim).
/// Har bo'lim o'z holatini saqlaydi (StatefulShellRoute).
class AppShell extends StatelessWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) => navigationShell.goBranch(
    index,
    // Faol bo'lim qayta bosilsa — uning bosh sahifasiga qaytadi.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = [
      (Icons.space_dashboard_outlined, Icons.space_dashboard, l10n.tabHome),
      (Icons.receipt_long_outlined, Icons.receipt_long, l10n.tabTransactions),
      (Icons.event_note_outlined, Icons.event_note, l10n.tabPayments),
      (
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet,
        l10n.tabWallet,
      ),
    ];

    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.navAddLabel,
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          children: [
            for (final (index, (icon, selectedIcon, label))
                in items.indexed) ...[
              // O'rtada "＋" tugmasi uchun joy.
              if (index == 2) const SizedBox(width: 72),
              Expanded(
                child: _NavItem(
                  icon: icon,
                  selectedIcon: selectedIcon,
                  label: label,
                  selected: navigationShell.currentIndex == index,
                  onTap: () => _goBranch(index),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
