import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/data/sync/sync_status.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// ARXITEKTURA 5: ✓ sinxron · ↻ yuborilmoqda · 📴 oflayn · ⚠️ N ta muammo.
/// Bosilsa — "Sinxron holati" ekrani. Byudjet tanlanmagan — ko'rinmaydi.
class SyncStatusBadge extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    if (status == null) return const SizedBox.shrink();
    final (icon, color, label) = syncPhaseVisual(context, status);
    return IconButton(
      tooltip: label,
      onPressed: () => context.push('/sync'),
      icon: Badge(
        isLabelVisible: status.issues.isNotEmpty,
        label: Text('${status.issues.length}'),
        child: Icon(icon, color: color),
      ),
    );
  }
}

/// Holat → ikon, rang, matn (nishon va ekran uchun bir xil).
(IconData, Color, String) syncPhaseVisual(
  BuildContext context,
  SyncStatus status,
) {
  final l10n = AppL10n.of(context);
  final scheme = Theme.of(context).colorScheme;
  final colors = context.appColors;
  return switch (status.phase) {
    SyncPhase.synced => (
      Icons.cloud_done_outlined,
      colors.income,
      l10n.syncSynced,
    ),
    SyncPhase.syncing => (Icons.sync, scheme.primary, l10n.syncSyncing),
    SyncPhase.pending => (
      Icons.cloud_upload_outlined,
      scheme.onSurfaceVariant,
      l10n.syncPending(status.pendingCount),
    ),
    SyncPhase.offline => (
      Icons.cloud_off_outlined,
      scheme.outline,
      l10n.syncOffline,
    ),
    SyncPhase.issues => (
      Icons.warning_amber_rounded,
      colors.warning,
      l10n.syncIssues(status.issues.length),
    ),
    SyncPhase.signedOut => (
      Icons.lock_outline,
      colors.expense,
      l10n.syncSignedOut,
    ),
  };
}
