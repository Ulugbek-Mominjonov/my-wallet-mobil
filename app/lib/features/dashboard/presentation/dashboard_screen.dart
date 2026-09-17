import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/money_text.dart';
import '../../../core/widgets/month_switcher.dart';
import '../../../di/state_providers.dart';
import 'widgets/dashboard_widgets.dart';

/// 1-ekran: **Xulosa**.
///
/// ★ Bu ekran FAQAT IKKI hujjatni o'qiydi: `months/{oy}` va `meta/totals`
/// (§5.3). Kategoriya kesimi, karta/naqd, prognoz — hammasi o'sha ikki
/// hujjatdan klientda hisoblanadi.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Uz.appName),
        actions: <Widget>[
          IconButton(
            tooltip: Uz.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(monthSummaryProvider)
            ..invalidate(totalsProvider)
            ..invalidate(monthsProvider);
        },
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -200) {
              ref.read(selectedMonthProvider.notifier).next();
            } else if (velocity > 200) {
              ref.read(selectedMonthProvider.notifier).previous();
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: <Widget>[
              MonthSwitcher(
                month: month,
                isClosed: summaryAsync.value?.closed ?? false,
                onPrevious: () =>
                    ref.read(selectedMonthProvider.notifier).previous(),
                onNext: () => ref.read(selectedMonthProvider.notifier).next(),
                onTap: () => ref.read(selectedMonthProvider.notifier).today(),
              ),
              switch (summaryAsync) {
                AsyncData<MonthSummary>(:final value) =>
                  _Content(summary: value),
                AsyncError<MonthSummary>(:final error) => ErrorState(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(monthSummaryProvider),
                  ),
                _ => const _LoadingSkeleton(),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fund = ref.watch(personalFundProvider);
    final savings = ref.watch(savingsSeriesProvider);
    final limits = ref.watch(limitStatusesProvider);
    final forecast = ref.watch(forecastProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BalanceHero(summary: summary),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                label: Uz.income,
                value: summary.income,
                icon: Icons.arrow_downward,
                color: AppTheme.positive,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: Uz.expense,
                value: summary.expense,
                icon: Icons.arrow_upward,
                color: AppTheme.negative,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                label: Uz.card,
                value: summary.card,
                icon: Icons.credit_card,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: Uz.cash,
                value: summary.cash,
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (summary.planned.isPositive) _BudgetProgress(summary: summary),
        const SizedBox(height: 12),
        ForecastCard(forecast: forecast),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: FundTile(
                emoji: '👤',
                title: Uz.personalFund,
                amount: fund.balance,
                color: AppTheme.personal,
                subtitle: '${Uz.allocated}: '
                    '${Fmt.moneyCompact(fund.allocated)}',
                onTap: () => context.go('/funds'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FundTile(
                emoji: '🏦',
                title: Uz.savings,
                amount: savings.total,
                color: AppTheme.savings,
                subtitle: '${savings.monthCount} oy',
                onTap: () => context.go('/funds'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (summary.byType.isNotEmpty) ...<Widget>[
          SectionCard(
            title: Uz.byType,
            child: Column(
              children: <Widget>[
                for (final entry in summary.typesByAmount)
                  BreakdownRow(
                    label: entry.key,
                    value: entry.value.total,
                    ratio: entry.value.total.ratioTo(summary.income),
                    subtitle: 'Karta ${Fmt.moneyCompact(entry.value.card)} · '
                        'Naqd ${Fmt.moneyCompact(entry.value.cash)}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (summary.byCategory.isNotEmpty)
          SectionCard(
            title: Uz.byCategory,
            child: Column(
              children: <Widget>[
                for (final entry in summary.categoriesByAmount)
                  _CategoryRow(
                    name: entry.key,
                    split: entry.value,
                    total: summary.expense,
                    limit: limits
                        .where(
                          (item) =>
                              normalizeKey(item.category) ==
                              normalizeKey(entry.key),
                        )
                        .firstOrNull,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SectionCard(
          title: Uz.allMonths,
          child: savings.points.isEmpty
              ? const EmptyState()
              : Column(
                  children: <Widget>[
                    for (final point in savings.points.reversed.take(12))
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(Fmt.monthTitle(point.monthKey)),
                        subtitle: Text(
                          '${Uz.income} ${Fmt.moneyCompact(point.income)} · '
                          '${Uz.expense} ${Fmt.moneyCompact(point.expense)}',
                          style: theme.textTheme.labelSmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            MoneyText(
                              point.balance,
                              colorBySign: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Σ ${Fmt.moneyCompact(point.cumulative)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => ref
                            .read(selectedMonthProvider.notifier)
                            .select(point.monthKey),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usage = summary.plannedUsage;
    return SectionCard(
      title: 'Byudjet',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${Fmt.money(summary.expense)} / '
                  '${Fmt.moneyLong(summary.planned)}',
                  style: const TextStyle(fontFeatures: tabularFigures),
                ),
              ),
              Text(
                Fmt.percent(usage),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: usage > 1 ? AppTheme.negative : AppTheme.positive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(
            value: usage,
            color: usage > 1 ? AppTheme.negative : null,
          ),
          if (summary.unpaidTotal.isPositive)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${Uz.unpaid}: ${Fmt.moneyLong(summary.unpaidTotal)}'
                '${_unknownSuffix(summary.unknownCount)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `· 2 ta summasi noma'lum` — bo'lsa qo'shiladi.
String _unknownSuffix(int count) =>
    count > 0 ? " · $count ta summasi noma'lum" : '';

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.split,
    required this.total,
    this.limit,
  });

  final String name;
  final CategorySplit split;
  final Money total;
  final LimitStatus? limit;

  @override
  Widget build(BuildContext context) {
    final status = limit;
    final color = status == null
        ? null
        : status.isExceeded
            ? AppTheme.negative
            : status.isNearLimit
                ? AppTheme.warning
                : AppTheme.positive;
    return BreakdownRow(
      label: name,
      value: split.actual,
      ratio: status != null
          ? status.ratio
          : split.actual.ratioTo(total),
      color: color,
      subtitle: status == null
          ? (split.planned.isPositive
              ? '${Uz.planned} ${Fmt.moneyCompact(split.planned)}'
              : null)
          : 'Limit ${Fmt.moneyCompact(status.limit)} · '
              '${Fmt.percent(status.ratio)}',
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SkeletonBox(height: 120),
          SizedBox(height: 12),
          SkeletonBox(height: 72),
          SizedBox(height: 12),
          SkeletonBox(height: 72),
          SizedBox(height: 12),
          SkeletonBox(height: 160),
        ],
      );
}
