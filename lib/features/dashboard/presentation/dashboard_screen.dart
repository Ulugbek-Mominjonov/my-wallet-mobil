import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/core/widgets/month_switcher.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/features/dashboard/application/dashboard_controller.dart';
import 'package:my_wallet/features/dashboard/application/month_report.dart';
import 'package:my_wallet/features/dashboard/presentation/share_report_screen.dart';
import 'package:my_wallet/features/payments/application/payments_controller.dart';
import 'package:my_wallet/features/payments/presentation/open_month_card.dart';
import 'package:my_wallet/features/payments/presentation/plan_action_runner.dart';
import 'package:my_wallet/features/transactions/application/transaction_list_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "Xulosa" (E16): oy hisobi lokal bazadan (tarmoqsiz) — qoldiq, prognoz,
/// statistika, rejalar, kategoriyalar, fond va jamg'arma (alohida, BR-005),
/// qarz va maqsadlar. Oy — ‹ › yoki surish bilan.
class DashboardScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final report = ref.watch(monthReportProvider).value;
    final month = ref.watch(dashboardMonthProvider);
    final controller = ref.read(dashboardMonthProvider.notifier);

    return GestureDetector(
      // Oy almashtirish — gorizontal surish.
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 300) return;
        controller.shift(velocity > 0 ? -1 : 1);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 96),
        children: [
          _MonthHeader(month: month, report: report),
          if (report == null)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (!report.state.opened &&
                !report.month.isBefore(report.today.monthKey))
              OpenMonthCard(month: report.month),
            if (report.isEmpty)
              EmptyState(
                icon: Icons.insights_outlined,
                title: l10n.dashEmpty,
                message: l10n.dashEmptyHint,
              )
            else ...[
              _HeroCard(report: report),
              const SizedBox(height: AppSpacing.md),
              _StatsGrid(report: report),
              const SizedBox(height: AppSpacing.md),
              if (report.facts.planned.isPositive ||
                  report.facts.unknownCount > 0)
                _PlanCard(report: report),
              if (report.upcomingPayments.isNotEmpty)
                _UpcomingCard(report: report),
              if (report.isCurrent) _ForecastCard(report: report),
              if (report.categories.isNotEmpty) _CategoriesCard(report: report),
              if (report.incomeTypes.isNotEmpty)
                _IncomeTypesCard(report: report),
            ],
            // Fond, jamg'arma, qarz va maqsadlar — oyga bog'liq emas.
            _FundSavingsRow(report: report),
            if (report.debts.iOwe.isPositive ||
                report.debts.owedToMe.isPositive)
              _DebtsCard(report: report),
            if (report.goals.isNotEmpty) _GoalsCard(report: report),
            if (!report.isEmpty) _ShareButton(report: report),
          ],
        ],
      ),
    );
  }
}

/// E16-T06: oy hisobini rasm sifatida ulashish (oldindan ko'rish bilan).
class _ShareButton extends StatelessWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md),
    child: Center(
      child: TextButton.icon(
        icon: const Icon(Icons.share_outlined),
        label: Text(AppL10n.of(context).shareReport),
        onPressed: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ShareReportScreen(report: report),
          ),
        ),
      ),
    ),
  );
}

class _MonthHeader extends ConsumerWidget {
  const new({required this.month, required this.report});

  final MonthKey month;
  final MonthReport? report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return MonthSwitcher(
      month: month,
      onShift: ref.read(dashboardMonthProvider.notifier).shift,
      badge: (report?.state.closed ?? false)
          ? Chip(
              avatar: const Icon(Icons.lock, size: 16),
              label: Text(l10n.dashClosed),
              visualDensity: VisualDensity.compact,
            )
          : null,
      actions: [
        IconButton(
          tooltip: l10n.yearView,
          icon: const Icon(Icons.calendar_view_month_outlined),
          onPressed: () => context.push('/reports/year'),
        ),
      ],
    );
  }
}

/// BR-091, BR-093, BR-094: qoldiq, prognoz, kuniga, orttirgan %.
class _HeroCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final summary = report.summary;
    final perDay = report.forecast.perDayAvailable;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashBalance, style: theme.textTheme.labelLarge),
                MoneyText(
                  summary.balance.minor,
                  currency: summary.balance.currency.code,
                  tone: summary.balance.isNegative
                      ? MoneyTone.expense
                      : MoneyTone.neutral,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${l10n.dashForecast}: '
                  '${moneyLabel(context, ref, summary.forecast)}',
                  style: theme.textTheme.bodySmall,
                ),
                if (report.isCurrent)
                  Text(
                    l10n.dashMonthEnd(
                      moneyLabel(context, ref, report.forecast.monthEndBalance),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                if (perDay != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      l10n.dashPerDay(moneyLabel(context, ref, perDay)),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: perDay.isNegative
                            ? colors.expense
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _SavedRing(ratio: summary.savedRatio, label: l10n.dashSaved),
        ],
      ),
    );
  }
}

class _SavedRing extends StatelessWidget {
  const new({required this.ratio, required this.label});

  final double ratio;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = ratio.clamp(0.0, 1.0);
    return SizedBox.square(
      dimension: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 80,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: 8,
              color: ratio.isNegative
                  ? context.appColors.expense
                  : context.appColors.income,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(ratio * 100).round()}%',
                style: theme.textTheme.titleMedium,
              ),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// 4 stat: daromad, xarajat, karta, naqd — bosilsa filtrlangan amallar.
class _StatsGrid extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final facts = report.facts;
    void open({TransactionKind? kind}) {
      ref
          .read(transactionListProvider.notifier)
          .setFilter(TransactionFilter(month: report.month, kind: kind));
      context.go('/transactions');
    }

    Widget stat(
      String label,
      Money value,
      MoneyTone tone,
      VoidCallback onTap,
    ) => Expanded(
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            MoneyText(value.minor, currency: value.currency.code, tone: tone),
          ],
        ),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            stat(
              l10n.kindIncome,
              facts.income,
              MoneyTone.income,
              () => open(kind: TransactionKind.income),
            ),
            const SizedBox(width: AppSpacing.sm),
            stat(
              l10n.kindExpense,
              facts.expense,
              MoneyTone.expense,
              () => open(kind: TransactionKind.expense),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            stat(l10n.dashCard, report.summary.card, MoneyTone.auto, open),
            const SizedBox(width: AppSpacing.sm),
            stat(l10n.dashCash, report.summary.cash, MoneyTone.auto, open),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    ),
  );
}

/// BR-090: reja bajarilishi — `X so'm + N ta ?` (noma'lum summali rejalar).
class _PlanCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final facts = report.facts;
    final ratio = report.summary.planRatio ?? 0;
    return _Section(
      title: l10n.dashPlan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: ratio.clamp(0.0, 1.0)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [
              moneyLabel(context, ref, facts.expense),
              '/',
              moneyLabel(context, ref, facts.planned),
              if (facts.unknownCount > 0) l10n.dashUnknown(facts.unknownCount),
              '(${(ratio * 100).round()}%)',
            ].join(' '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Yaqin 3 to'lov — bir bosishda "To'landi" (BR-073).
class _UpcomingCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return _Section(
      title: l10n.dashUpcoming,
      child: Column(
        children: [
          for (final (:plan, :status) in report.upcomingPayments.take(3))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(switch (status) {
                PlannedStatus.overdue => Icons.warning_amber,
                PlannedStatus.partial => Icons.timelapse,
                _ => Icons.event,
              }),
              title: Text(plan.name),
              subtitle: Text(
                [
                  _dayMonth(plan.dueDate),
                  if (plan.plannedAmount case final planned?)
                    moneyLabel(context, ref, planned - plan.paidAmount),
                ].join(' · '),
              ),
              trailing: plan.plannedAmount == null
                  ? null
                  : TextButton(
                      onPressed: () => unawaited(_pay(context, ref, plan.id)),
                      child: Text(l10n.dashMarkPaid),
                    ),
            ),
        ],
      ),
    );
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, String planId) =>
      runPlanAction(
        context,
        ({required confirmClosedMonth}) => ref
            .read(planActionsProvider)
            .pay(planId, confirmClosedMonth: confirmClosedMonth),
        success: AppL10n.of(context).saved,
      );
}

/// BR-093: prognoz — o'tgan kunlar, kunlik sarf, oy oxiri, kutilayotgan
/// daromad (hozircha kelgani).
class _ForecastCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final f = report.forecast;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
    return _Section(
      title:
          '${l10n.dashForecastTitle} · '
          '${l10n.dashDays(f.daysElapsed, f.daysInMonth)}',
      child: Column(
        children: [
          row(l10n.dashDailySpend, moneyLabel(context, ref, f.dailySpend)),
          row(
            l10n.dashMonthEndSpend,
            moneyLabel(context, ref, f.monthEndSpend),
          ),
          row(
            l10n.dashExpectedIncome,
            moneyLabel(context, ref, f.incomeExpected),
          ),
          if (report.forecast.incomePending)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.dashReceivedSoFar(
                  moneyLabel(context, ref, f.incomeReceived),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// Kategoriyalar — limit rangi va `2 000 000 (100%)` (BR-130, BR-131).
class _CategoriesCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.appColors;
    return _Section(
      title: l10n.dashCategories,
      child: Column(
        children: [
          for (final (:line, :status, :ratio) in report.categories)
            InkWell(
              onTap: () => context.push('/reports/category/${line.categoryId}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(line.name)),
                        const SizedBox(width: AppSpacing.sm),
                        // Tor ekran/katta shriftda summa ikki qatorga o'tadi.
                        Flexible(
                          child: Text(
                            moneyLabel(context, ref, line.actual) +
                                (ratio == null
                                    ? ''
                                    : ' (${(ratio * 100).round()}%)'),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    if (ratio != null)
                      LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        color: switch (status) {
                          LimitStatus.over => colors.expense,
                          LimitStatus.near => colors.warning,
                          _ => colors.income,
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IncomeTypesCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return _Section(
      title: l10n.dashIncomeTypes,
      child: Column(
        children: [
          // Tor ekranda ham sig'sin: nom ustida, karta/naqd ostida.
          for (final line in report.incomeTypes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(line.name),
                  Text(
                    '${l10n.dashCard} ${moneyLabel(context, ref, line.card)} · '
                    '${l10n.dashCash} ${moneyLabel(context, ref, line.cash)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// BR-005: 👤 fond va 🏦 jamg'arma — alohida plitalar, hech qachon
/// qo'shilmaydi.
class _FundSavingsRow extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    Widget tile(String title, Money total, List<(String, Money)> rows) =>
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                MoneyText(
                  total.minor,
                  currency: total.currency.code,
                  style: theme.textTheme.titleLarge,
                ),
                for (final (label, value) in rows)
                  Text(
                    '$label: ${moneyLabel(context, ref, value)}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tile(l10n.dashFund, report.fundBalance, [
              (l10n.dashAllocated, report.facts.allocated),
              (l10n.dashSpent, report.facts.fundSpent),
            ]),
            const SizedBox(width: AppSpacing.sm),
            tile(l10n.dashSavings, report.savings.total, [
              (l10n.dashThisMonth, report.savings.thisMonth),
            ]),
          ],
        ),
      ),
    );
  }
}

class _DebtsCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final debts = report.debts;
    return _Section(
      title: l10n.dashDebts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${l10n.dashIOwe}: ${moneyLabel(context, ref, debts.iOwe)}'),
          Text(
            '${l10n.dashOwedToMe}: ${moneyLabel(context, ref, debts.owedToMe)}',
          ),
          if (debts.monthlyObligation.isPositive)
            Text(
              '${l10n.dashMonthly}: '
              '${moneyLabel(context, ref, debts.monthlyObligation)}',
            ),
        ],
      ),
    );
  }
}

class _GoalsCard extends ConsumerWidget {
  const new({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return _Section(
      title: l10n.dashGoals,
      child: Column(
        children: [
          for (final (:goal, :progress) in report.goals)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(goal.name)),
                      Text('${(progress.progress * 100).round()}%'),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: progress.progress.clamp(0.0, 1.0),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// `05.10` ko'rinishidagi kun va oy.
String _dayMonth(LocalDate date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}';
