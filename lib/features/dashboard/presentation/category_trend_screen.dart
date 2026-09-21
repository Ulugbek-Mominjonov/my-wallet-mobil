import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/core/widgets/month_bars.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/dashboard/application/dashboard_controller.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/application/transaction_list_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Kategoriyaning oxirgi 12 oyi (tanlangan oy bilan tugaydi).
final FutureProviderFamily<List<(MonthKey, Money)>, String>
categoryTrendProvider = FutureProvider.autoDispose.family((
  ref,
  categoryId,
) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  if (householdId == null || startup is! StartupReady) return const [];
  ref.watch(monthReportProvider);
  final to = ref.watch(dashboardMonthProvider);
  final from = to.shift(-11);
  final values = await ref
      .watch(appDatabaseProvider)
      .reportDao
      .categoryTrend(householdId, categoryId, from, to, base: startup.currency);
  return [
    for (var m = from; !m.isAfter(to); m = m.shift(1))
      (m, values[m] ?? Money(0, startup.currency)),
  ];
});

/// Kategoriya tafsiloti (E16-T05, BR-095): oyma-oy trend va amallari.
class CategoryTrendScreen extends ConsumerWidget {
  const new({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final categories = [
      ...?ref.watch(categoriesProvider(CategoryKind.expense)).value,
      ...?ref.watch(categoriesProvider(CategoryKind.income)).value,
    ];
    final category = categories.where((c) => c.id == categoryId).firstOrNull;
    final trend = ref.watch(categoryTrendProvider(categoryId)).value;
    final color = category?.kind == CategoryKind.income
        ? context.appColors.income
        : context.appColors.expense;

    return Scaffold(
      appBar: AppBar(title: Text(category?.name ?? '')),
      body: trend == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  l10n.categoryTrend,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: MonthBars(
                    labels: [
                      for (final (month, _) in trend)
                        l10n.monthShort('${month.month}'),
                    ],
                    series: [
                      [for (final (_, value) in trend) value.minor],
                    ],
                    colors: [color],
                  ),
                ),
                for (final (month, value) in trend.reversed)
                  if (!value.isZero)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        formatMonthTitle(
                          l10n,
                          year: month.year,
                          month: month.month,
                        ),
                      ),
                      trailing: MoneyText(value.minor),
                    ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(l10n.categoryTransactions),
                  onPressed: () {
                    ref
                        .read(transactionListProvider.notifier)
                        .setFilter(
                          TransactionFilter(
                            month: ref.read(dashboardMonthProvider),
                            categoryId: categoryId,
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
