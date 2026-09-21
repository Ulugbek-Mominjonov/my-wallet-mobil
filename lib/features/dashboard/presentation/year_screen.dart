import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/core/widgets/month_bars.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/dashboard/application/dashboard_controller.dart';
import 'package:my_wallet/features/dashboard/application/year_report.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Tanlangan yil (standart — joriy yil).
final NotifierProvider<SelectedYear, int> selectedYearProvider =
    NotifierProvider(SelectedYear.new);

final class SelectedYear extends Notifier<int> {
  @override
  int build() => ref.watch(clockProvider).today().year;

  void shift(int years) => state += years;
}

final FutureProvider<YearReport?> yearReportProvider = FutureProvider((
  ref,
) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  if (householdId == null || startup is! StartupReady) return null;
  // Dashboard hisobi yangilansa (yozuv/sinxron) — yil ham qayta hisoblanadi.
  ref.watch(monthReportProvider);
  return await YearReportLoader(
    ref.watch(appDatabaseProvider),
    householdId,
    base: startup.currency,
  ).load(ref.watch(selectedYearProvider));
});

/// Yillik ko'rinish (E16-T05, BR-092): oylar (daromad, xarajat, qoldiq,
/// orttirgan %, 🔒), ustun grafik va JAMI. Oy bosilsa — o'sha oy Xulosasi.
class YearScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final year = ref.watch(selectedYearProvider);
    final report = ref.watch(yearReportProvider).value;
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yearView),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedYearProvider.notifier).shift(-1),
          ),
          Center(child: Text(l10n.yearTitle('$year'))),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedYearProvider.notifier).shift(1),
          ),
        ],
      ),
      body: report == null
          ? const Center(child: CircularProgressIndicator())
          : report.active.isEmpty
          ? EmptyState(
              icon: Icons.calendar_month_outlined,
              title: l10n.yearEmpty,
              message: '',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppCard(
                  child: MonthBars(
                    labels: [
                      for (final m in report.months)
                        l10n.monthShort('${m.facts.month.month}'),
                    ],
                    series: [
                      [for (final m in report.months) m.facts.income.minor],
                      [for (final m in report.months) m.facts.expense.minor],
                    ],
                    colors: [colors.income, colors.expense],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final month in report.active) _MonthRow(month: month),
                const Divider(),
                _TotalRow(report: report),
              ],
            ),
    );
  }
}

class _MonthRow extends ConsumerWidget {
  const new({required this.month});

  final YearMonth month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final key = month.facts.month;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: month.closed ? const Icon(Icons.lock, size: 18) : null,
      title: Text(formatMonthTitle(l10n, year: key.year, month: key.month)),
      subtitle: Wrap(
        children: [
          MoneyText(month.facts.income.minor, tone: MoneyTone.income),
          const Text(' / '),
          MoneyText(month.facts.expense.minor, tone: MoneyTone.expense),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(month.summary.balance.minor, tone: MoneyTone.auto),
          Text('${(month.summary.savedRatio * 100).round()}%'),
        ],
      ),
      onTap: () {
        ref.read(dashboardMonthProvider.notifier).select(key);
        context.go('/');
      },
    );
  }
}

class _TotalRow extends StatelessWidget {
  const new({required this.report});

  final YearReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final totals = report.totals;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        l10n.yearTotal,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Wrap(
        children: [
          MoneyText(totals.income.minor, tone: MoneyTone.income),
          const Text(' / '),
          MoneyText(totals.expense.minor, tone: MoneyTone.expense),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(totals.summary.balance.minor, tone: MoneyTone.auto),
          Text('${(totals.summary.savedRatio * 100).round()}%'),
        ],
      ),
    );
  }
}
