import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/security/privacy_mode.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/data/sync/sync_status.dart';
import 'package:my_wallet/features/auth/presentation/sign_out_dialog.dart';
import 'package:my_wallet/features/dashboard/application/home_widget_sync.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/sync/presentation/sync_status_badge.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Ilova qobig'i: byudjet almashtirgich, sinxron holati, oflayn va texnik
/// ishlar bannerlari; pastda 4 bo'lim + o'rtada "＋" (ARXITEKTURA 7).
/// Har bo'lim o'z holatini saqlaydi (StatefulShellRoute).
class AppShell extends ConsumerWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) => navigationShell.goBranch(
    index,
    // Faol bo'lim qayta bosilsa — uning bosh sahifasiga qaytadi.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      appBar: AppBar(
        title: const _HouseholdSwitcher(),
        titleSpacing: AppSpacing.lg,
        actions: const [_PrivacyToggle(), SyncStatusBadge(), _AccountMenu()],
      ),
      // E33-T01: bosh ekran vidjeti — hisob o'zgarganda yangilanadi.
      body: HomeWidgetSync(
        child: Column(
          children: [
            const _Banners(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // BR-011: kuzatuvchi faqat o'qiydi — qo'shish tugmasi yo'q.
      floatingActionButton: ref.watch(canWriteProvider)
          ? FloatingActionButton(
              tooltip: l10n.navAddLabel,
              onPressed: () => context.push('/add'),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        // Balandligi qat'iy: yorliqlar katta shriftda ham sig'sin (Material
        // NavigationBar kabi cheklangan kattalashuv, nom qisqaradi).
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _navMaxTextScale,
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
      ),
    );
  }
}

/// Pastki navigatsiya yorliqlari uchun eng katta shrift koeffitsiyenti.
const double _navMaxTextScale = 1.3;

/// Joriy byudjet nomi; bosilganda — ro'yxat (BR-011 roli bilan).
class _HouseholdSwitcher extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(startupProvider);
    if (state is! StartupReady) return const SizedBox.shrink();
    return InkWell(
      onTap: () => unawaited(_show(context, ref, state)),
      // Barmoq uchun kamida 48 dp (a11y) — qisqa nomda ham.
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                state.household.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (state.boot.households.length > 1) const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  Future<void> _show(
    BuildContext context,
    WidgetRef ref,
    StartupReady state,
  ) async {
    final l10n = AppL10n.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final household in state.boot.households)
              ListTile(
                leading: Icon(
                  household.id == state.household.id
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                ),
                title: Text(household.name),
                subtitle: Text(household.role.wire),
                onTap: () {
                  Navigator.pop(context);
                  unawaited(
                    ref
                        .read(startupProvider.notifier)
                        .selectHousehold(household.id),
                  );
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.householdAdd),
              onTap: () {
                Navigator.pop(context);
                unawaited(context.push(joinPath));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// BR-212: bir bosishda barcha summalar `•••` bo'ladi.
class _PrivacyToggle extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(privacyModeProvider);
    return IconButton(
      tooltip: AppL10n.of(context).privacyMode,
      icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
      onPressed: ref.read(privacyModeProvider.notifier).toggle,
    );
  }
}

/// Profil menyusi: ilova qulfi, sozlamalar (E19) va chiqish.
class _AccountMenu extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return PopupMenuButton<void>(
      icon: const Icon(Icons.account_circle_outlined),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => unawaited(context.push(settingsPath)),
          child: Text(l10n.settingsTitle),
        ),
        PopupMenuItem(
          onTap: () => unawaited(context.push(lockSettingsPath)),
          child: Text(l10n.lockTitle),
        ),
        PopupMenuItem(
          onTap: () => unawaited(confirmSignOut(context, ref)),
          child: Text(l10n.signOut),
        ),
      ],
    );
  }
}

/// Oflayn va texnik ishlar (BR-214 qo'shnisi) bannerlari.
class _Banners extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final offline = ref.watch(syncStatusProvider).value?.phase;
    final startup = ref.watch(startupProvider);
    final maintenance = startup is StartupReady
        ? startup.boot.maintenance
        : null;

    return Column(
      children: [
        if (maintenance != null && maintenance.isActive(DateTime.now()))
          _Banner(
            icon: Icons.construction,
            text: maintenance.message(locale),
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
        if (offline == SyncPhase.offline)
          _Banner(
            icon: Icons.cloud_off,
            text: l10n.offlineBanner,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const new({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    ),
  );
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
                // M3 NavigationBar yorlig'i (12sp, o'rta qalinlik) — kichik
                // kulrang matn ham o'qiladi (kontrast).
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
