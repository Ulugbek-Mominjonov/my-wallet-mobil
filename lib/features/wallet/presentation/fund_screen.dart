import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/features/payments/presentation/plan_tile.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/application/transaction_list_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// 👤 Shaxsiy fond (E18-T02, BR-060..065): qoldiq, shu oy va butun davr
/// ajratilgan/sarflangan, joriy oy ajratmasi (foiz rejimida — jonli summa),
/// oylar kesimi, sarf qo'shish va sarflar tarixi.
class FundScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final report = ref.watch(fundReportProvider).value;
    final accounts = ref.watch(accountsReportProvider).value;
    final fundAccount = accounts?.fund?.account;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashFund)),
      floatingActionButton: fundAccount == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: Text(l10n.fundAddSpend),
              onPressed: () =>
                  context.push('/add?kind=expense&account=${fundAccount.id}'),
            ),
      body: report == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                96,
              ),
              children: [
                _BalanceCard(report: report),
                const SizedBox(height: AppSpacing.md),
                const _AllocationCard(),
                const SizedBox(height: AppSpacing.md),
                _MonthsCard(report: report),
                if (fundAccount != null)
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(l10n.fundSpends),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref
                          .read(transactionListProvider.notifier)
                          .setFilter(
                            TransactionFilter(
                              accountId: fundAccount.id,
                              kind: TransactionKind.expense,
                            ),
                          );
                      context.go('/transactions');
                    },
                  ),
              ],
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const new({required this.report});

  final FundReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final current = report.months.lastOrNull;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dashBalance, style: theme.textTheme.labelLarge),
          MoneyText(
            report.balance.minor,
            currency: report.balance.currency.code,
            tone: report.balance.isNegative
                ? MoneyTone.expense
                : MoneyTone.neutral,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (current != null)
            _Pair(
              title: l10n.dashThisMonth,
              allocated: current.allocated,
              spent: current.spent,
            ),
          _Pair(
            title: l10n.fundAllTime,
            allocated: report.totalAllocated,
            spent: report.totalSpent,
          ),
        ],
      ),
    );
  }
}

/// "Ajratilgan / sarflangan" juftligi.
class _Pair extends StatelessWidget {
  const new({
    required this.title,
    required this.allocated,
    required this.spent,
  });

  final String title;
  final Money allocated;
  final Money spent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$title:', style: Theme.of(context).textTheme.labelLarge),
          Text('${l10n.dashAllocated} '),
          MoneyText(
            allocated.minor,
            currency: allocated.currency.code,
            tone: MoneyTone.income,
          ),
          Text('· ${l10n.dashSpent} '),
          MoneyText(
            spent.minor,
            currency: spent.currency.code,
            tone: MoneyTone.expense,
          ),
        ],
      ),
    );
  }
}

/// BR-060: joriy oy ajratmasi — reja holati; foiz rejimida shu oy
/// daromadidan jonli summa.
class _AllocationCard extends ConsumerWidget {
  const new();

  static const int _basisPointsPerPercent = 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final allocation = ref.watch(fundAllocationProvider).value;
    if (allocation == null) return const SizedBox.shrink();
    final (:plan, :live, :rule) = allocation;
    final percent = rule.percentBasisPoints / _basisPointsPerPercent;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fundAllocation, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          if (plan == null)
            Text(l10n.fundAllocationNone)
          else
            Row(
              children: [
                PlanStatusIcon(
                  status: PlannedStatus.of(
                    plan,
                    ref.watch(clockProvider).today(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(plan.name)),
                if (plan.plannedAmount case final amount?)
                  MoneyText(amount.minor, currency: amount.currency.code),
              ],
            ),
          if (live != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                l10n.fundAllocationLive(
                  moneyLabel(context, ref, live),
                  percent.toStringAsFixed(percent % 1 == 0 ? 0 : 1),
                ),
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthsCard extends StatelessWidget {
  const new({required this.report});

  final FundReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.fundMonths,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          for (final (:month, :allocated, :spent) in report.months.reversed)
            ListTile(
              dense: true,
              title: Text(
                formatMonthTitle(l10n, year: month.year, month: month.month),
              ),
              subtitle: Wrap(
                spacing: AppSpacing.sm,
                children: [
                  MoneyText(
                    allocated.minor,
                    currency: allocated.currency.code,
                    tone: MoneyTone.income,
                  ),
                  MoneyText(
                    -spent.minor,
                    currency: spent.currency.code,
                    tone: MoneyTone.expense,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
