import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/time_format.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/data/sync/sync_status.dart';
import 'package:my_wallet/features/sync/presentation/sync_status_badge.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// "Sinxron holati" (E13-T06): navbat, oxirgi sinxron, muammolar (BR-006) va
/// qo'lda amallar.
class SyncStatusScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final status = ref.watch(syncStatusProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncStatusTitle)),
      body: status == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _Summary(status: status),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: status.running
                      ? null
                      : () => unawaited(_syncNow(ref)),
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.syncNow),
                ),
                for (final issue in status.issues) ...[
                  const SizedBox(height: AppSpacing.md),
                  _IssueCard(issue: issue),
                ],
                const SizedBox(height: AppSpacing.xl),
                TextButton.icon(
                  onPressed: status.running
                      ? null
                      : () => unawaited(_confirmReload(context, ref)),
                  icon: const Icon(Icons.restart_alt),
                  label: Text(l10n.syncFullReload),
                ),
              ],
            ),
    );
  }

  static Future<void> _syncNow(WidgetRef ref) async {
    final scheduler = await ref.read(syncSchedulerProvider.future);
    await scheduler?.refresh();
  }

  static Future<void> _confirmReload(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.syncFullReload),
        content: Text(l10n.syncFullReloadConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.syncFullReload),
          ),
        ],
      ),
    );
    final householdId = ref.read(currentHouseholdIdProvider);
    if (confirmed != true || householdId == null) return;
    await ref.read(syncIssueActionsProvider).resetHousehold(householdId);
    await _syncNow(ref);
  }
}

class _Summary extends StatelessWidget {
  const new({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final (icon, color, label) = syncPhaseVisual(context, status);
    final lastSync = status.lastSyncAt;
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  lastSync == null
                      ? l10n.syncNever
                      : l10n.syncLastAt(formatEventTime(lastSync)),
                  style: theme.textTheme.bodySmall,
                ),
                if (status.pendingCount > 0 &&
                    status.phase != SyncPhase.pending)
                  Text(
                    l10n.syncPending(status.pendingCount),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends ConsumerWidget {
  const new({required this.issue});

  final SyncIssueRow issue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final actions = ref.read(syncIssueActionsProvider);
    final conflict = issue.status == 'conflict';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: context.appColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.syncRecordKind(issue.targetTable),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                formatEventTime(issue.createdAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            conflict
                ? l10n.syncIssueConflict
                : l10n.syncIssueRejected(issue.code ?? '?'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (conflict)
                OutlinedButton(
                  onPressed: () => unawaited(actions.keepMine(issue)),
                  child: Text(l10n.syncKeepMine),
                ),
              TextButton(
                onPressed: () => unawaited(actions.dismiss(issue)),
                child: Text(l10n.syncDismiss),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
