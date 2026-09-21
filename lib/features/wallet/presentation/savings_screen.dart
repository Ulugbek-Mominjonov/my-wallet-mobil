import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/line_chart.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/features/wallet/application/wallet_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// 🏦 Jamg'arma (E18-T03, BR-100..103): jami, to'planish chizig'i (oxirgi
/// 12 oy), oylar jadvali (⏳ — joriy oy). Jamg'arma — ko'rsatkich; pul
/// qayerdaligini hisoblar ko'rsatadi.
class SavingsScreen extends ConsumerWidget {
  const new({super.key});

  /// Grafikda ko'rsatiladigan oxirgi oylar.
  static const int chartMonths = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final report = ref.watch(savingsReportProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashSavings)),
      body: switch (report) {
        null => const Center(child: CircularProgressIndicator()),
        SavingsReport(:final rows) when rows.isEmpty => EmptyState(
          icon: Icons.savings_outlined,
          title: l10n.dashEmpty,
        ),
        final report => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _TotalCard(report: report),
            const SizedBox(height: AppSpacing.md),
            _ChartCard(report: report),
            const SizedBox(height: AppSpacing.md),
            _MonthsTable(report: report),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.savingsNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _TotalCard extends StatelessWidget {
  const new({required this.report});

  final SavingsReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final totals = report.totals;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.savingsTotal, style: theme.textTheme.labelLarge),
          MoneyText(
            totals.totalBalance.minor,
            currency: totals.totalBalance.currency.code,
            tone: MoneyTone.auto,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${l10n.savingsAvg}:'),
              MoneyText(
                totals.avgMonthlySaved.minor,
                currency: totals.avgMonthlySaved.currency.code,
              ),
              Text('· ${l10n.savingsMonthsCount(totals.monthsCount)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const new({required this.report});

  final SavingsReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final rows = report.rows.length > SavingsScreen.chartMonths
        ? report.rows.sublist(report.rows.length - SavingsScreen.chartMonths)
        : report.rows;
    return AppCard(
      child: LineChart(
        labels: [for (final row in rows) l10n.monthShort('${row.month.month}')],
        values: [for (final row in rows) row.accumulated.minor],
        color: context.appColors.income,
        semanticLabel: l10n.savingsAccumulated,
      ),
    );
  }
}

/// BR-100, BR-101: har oy — daromad, xarajat, shu oy qolgan, to'plangan.
class _MonthsTable extends StatelessWidget {
  const new({required this.report});

  final SavingsReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (final row in report.rows.reversed)
            ListTile(
              title: Text(
                [
                  formatMonthTitle(
                    l10n,
                    year: row.month.year,
                    month: row.month.month,
                  ),
                  if (row.isCurrent) '⏳',
                ].join(' '),
              ),
              // Katta shriftda ham sig'sin: hammasi o'raladigan qatorlarda.
              subtitle: Wrap(
                spacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  MoneyText(
                    row.income.minor,
                    currency: row.income.currency.code,
                    tone: MoneyTone.income,
                  ),
                  MoneyText(
                    -row.expense.minor,
                    currency: row.expense.currency.code,
                    tone: MoneyTone.expense,
                  ),
                  MoneyText(
                    row.balance.minor,
                    currency: row.balance.currency.code,
                    signed: true,
                  ),
                  Text(
                    '${l10n.savingsAccumulated}:',
                    style: theme.textTheme.labelSmall,
                  ),
                  MoneyText(
                    row.accumulated.minor,
                    currency: row.accumulated.currency.code,
                    tone: MoneyTone.auto,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
