import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/wallet/application/wallet_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:my_wallet/features/wallet/presentation/debt_form_screen.dart';
import 'package:my_wallet/features/wallet/presentation/wallet_action_runner.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// 💳 Qarzlar (E18-T04, BR-110..118): jamlar (men qarzdorman / menga qarzdor
/// / ⚖️ sof / oylik majburiyat), yo'nalish bo'yicha ro'yxat — progress,
/// qolgan, tugash oyi, holat (BR-116), kutilmoqda summasi (BR-113).
class DebtsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final report = ref.watch(debtsReportProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletDebts)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.debtAdd),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => const DebtFormScreen(),
          ),
        ),
      ),
      body: switch (report) {
        null => const Center(child: CircularProgressIndicator()),
        DebtsReport(:final lines) when lines.isEmpty => EmptyState(
          icon: Icons.handshake_outlined,
          title: l10n.debtsEmpty,
        ),
        final report => _DebtsList(report: report),
      },
    );
  }
}

class _DebtsList extends StatelessWidget {
  const new({required this.report});

  final DebtsReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final active = [
      for (final line in report.lines)
        if (line.debt.archivedAt == null) line,
    ];
    final archived = [
      for (final line in report.lines)
        if (line.debt.archivedAt != null) line,
    ];
    List<Widget> section(String title, DebtDirection direction) {
      final lines = [
        for (final line in active)
          if (line.debt.direction == direction) line,
      ];
      if (lines.isEmpty) return const [];
      return [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xs,
          ),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        for (final line in lines) _DebtCard(line: line),
      ];
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        96,
      ),
      children: [
        _TotalsCard(totals: report.totals),
        ...section(l10n.dashIOwe, DebtDirection.iOwe),
        ...section(l10n.dashOwedToMe, DebtDirection.owedToMe),
        if (archived.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            shape: const Border(),
            title: Text('${l10n.debtArchived} (${archived.length})'),
            children: [for (final line in archived) _DebtCard(line: line)],
          ),
      ],
    );
  }
}

/// BR-114: jamlar (faqat asosiy valyutadagi, arxivlanmagan qarzlar).
class _TotalsCard extends StatelessWidget {
  const new({required this.totals});

  final DebtTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    Widget row(
      String label,
      Money amount, {
      MoneyTone? tone,
      bool bold = false,
    }) {
      final style = bold ? Theme.of(context).textTheme.titleMedium : null;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            MoneyText(
              amount.minor,
              currency: amount.currency.code,
              tone: tone ?? MoneyTone.neutral,
              style: style,
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          row(l10n.dashIOwe, totals.iOwe, tone: MoneyTone.expense),
          row(l10n.dashOwedToMe, totals.owedToMe, tone: MoneyTone.income),
          row(l10n.debtNet, totals.net, tone: MoneyTone.auto, bold: true),
          const Divider(),
          row(l10n.debtMonthly, totals.monthlyObligation),
          row(l10n.debtPaidThisMonth, totals.paidThisMonth),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const new({required this.line});

  final DebtLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (:debt, :progress) = line;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => context.push('/wallet/debts/${debt.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    debt.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                DebtStatusChip(status: progress.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: progress.progress,
              color: context.appColors.income,
            ),
            const SizedBox(height: AppSpacing.xs),
            DebtFacts(debt: debt, progress: progress),
          ],
        ),
      ),
    );
  }
}

/// Qolgan, tugash oyi va kutilmoqda summasi (ro'yxat va tafsilotda).
class DebtFacts extends ConsumerWidget {
  const new({required this.debt, required this.progress, super.key});

  final Debt debt;
  final DebtProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    final end = progress.endMonth;
    return Wrap(
      spacing: AppSpacing.md,
      children: [
        Text(
          l10n.debtRemaining(moneyLabel(context, ref, progress.remaining)),
          style: style,
        ),
        if (end != null)
          Text(
            l10n.debtEnds(
              formatMonthTitle(l10n, year: end.year, month: end.month),
            ),
            style: style,
          ),
        // BR-113: bog'langan, to'lanmagan rejalar qarzni kamaytirmaydi.
        if (progress.pendingAmount.isPositive)
          Text(
            l10n.debtPending(moneyLabel(context, ref, progress.pendingAmount)),
            style: style,
          ),
      ],
    );
  }
}

/// BR-116: qarz holati belgisi.
class DebtStatusChip extends StatelessWidget {
  const new({required this.status, super.key});

  final DebtStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      DebtStatus.paying => (l10n.debtStatusPaying, scheme.primary),
      DebtStatus.pending => (l10n.debtStatusPending, colors.warning),
      // Matn — kontrast ≥ 4.5 (outline rangi matnga yetmaydi).
      DebtStatus.unlinked => (l10n.debtStatusUnlinked, scheme.onSurfaceVariant),
      DebtStatus.closed => (l10n.debtStatusClosed, colors.income),
    };
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color),
    );
  }
}

/// BR-118: qarzga bog'langan to'lovlar.
final StreamProviderFamily<List<TransactionRow>, String> debtPaymentsProvider =
    StreamProvider.autoDispose.family((ref, debtId) {
      final householdId = ref.watch(currentHouseholdIdProvider);
      if (householdId == null) return Stream.value(const []);
      return ref
          .watch(appDatabaseProvider)
          .ledgerDao
          .watchDebtPayments(householdId, debtId);
    });

/// Qarz tafsiloti: holat, progress, bog'langan to'lovlar; tahrirlash va
/// arxivlash.
class DebtDetailScreen extends ConsumerWidget {
  const new({required this.debtId, super.key});

  final String debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final report = ref.watch(debtsReportProvider).value;
    final line = report?.lines.where((l) => l.debt.id == debtId).firstOrNull;
    if (line == null) {
      return Scaffold(
        appBar: AppBar(),
        body: report == null
            ? const Center(child: CircularProgressIndicator())
            : EmptyState(icon: Icons.search_off, title: l10n.debtsEmpty),
      );
    }
    final (:debt, :progress) = line;
    final payments = ref.watch(debtPaymentsProvider(debtId)).value;
    final archived = debt.archivedAt != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(debt.name),
        actions: [
          IconButton(
            tooltip: l10n.actionEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => DebtFormScreen(debt: debt),
              ),
            ),
          ),
          IconButton(
            tooltip: archived ? l10n.debtUnarchive : l10n.debtArchive,
            icon: Icon(
              archived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
            onPressed: () => unawaited(
              runWalletAction(
                context,
                () => ref
                    .read(walletActionsProvider)
                    .archiveDebt(debt.id, archived: !archived),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        debt.direction == DebtDirection.iOwe
                            ? l10n.dashIOwe
                            : l10n.dashOwedToMe,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    DebtStatusChip(status: progress.status),
                  ],
                ),
                MoneyText(
                  progress.remaining.minor,
                  currency: progress.remaining.currency.code,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progress.progress,
                  color: context.appColors.income,
                ),
                const SizedBox(height: AppSpacing.sm),
                DebtFacts(debt: debt, progress: progress),
                if (debt.note case final note?)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(note, style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.lg,
              bottom: AppSpacing.xs,
            ),
            child: Text(l10n.debtPayments, style: theme.textTheme.titleSmall),
          ),
          if (payments != null && payments.isEmpty)
            Text(l10n.debtNoPayments)
          else
            for (final payment in payments ?? const <TransactionRow>[])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(payment.payee ?? payment.note ?? debt.name),
                subtitle: Text(payment.occurredOn),
                // BR-194: bog'langan amallar qarz valyutasida.
                trailing: MoneyText(
                  payment.amount,
                  currency: debt.total.currency.code,
                ),
                onTap: () => context.push('/transaction/${payment.id}'),
              ),
        ],
      ),
    );
  }
}
