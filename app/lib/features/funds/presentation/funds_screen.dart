import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/money_text.dart';
import '../../../di/providers.dart';
import '../../../di/state_providers.dart';
import 'debt_form.dart';
import 'goal_form.dart';
import 'savings_chart.dart';

/// 5-ekran: **Fondlar** — 👤 shaxsiy fond, 🏦 jamg'arma, 💳 qarzlar,
/// 🎯 maqsadlar.
///
/// ⚠️ 👤 va 🏦 HECH QACHON qo'shilmaydi va bitta "jami" ko'rsatilmaydi
/// (§2.4) — ular butunlay boshqa pullar.
class FundsScreen extends ConsumerWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(Uz.tabFunds),
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: <Widget>[
                Tab(text: '👤 ${Uz.personalFund}'),
                Tab(text: '🏦 ${Uz.savings}'),
                Tab(text: '💳 ${Uz.debts}'),
                Tab(text: '🎯 ${Uz.goals}'),
              ],
            ),
          ),
          body: const TabBarView(
            children: <Widget>[
              _PersonalFundTab(),
              _SavingsTab(),
              _DebtsTab(),
              _GoalsTab(),
            ],
          ),
        ),
      );
}

// ───────────────────────── 👤 Shaxsiy fond ─────────────────────────

class _PersonalFundTab extends ConsumerWidget {
  const _PersonalFundTab();

  Future<void> _addSpend(BuildContext context, WidgetRef ref) async {
    final amount = TextEditingController();
    final purpose = TextEditingController();
    var method = PaymentMethod.cash;
    var date = ref.read(clockProvider).now();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Shaxsiy fonddan sarf',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              AmountField(controller: amount, autofocus: true),
              const SizedBox(height: 12),
              TextField(
                controller: purpose,
                decoration: const InputDecoration(labelText: 'Nima uchun'),
              ),
              const SizedBox(height: 12),
              MethodPicker(
                value: method,
                onChanged: (value) => setState(() => method = value),
              ),
              const SizedBox(height: 12),
              DateField(
                value: date,
                onChanged: (value) => setState(() => date = value),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(Uz.save),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved != true || !context.mounted) return;
    await runAction(
      context,
      successMessage: '✅ Sarf yozildi',
      action: () async {
        await ref.read(addPersonalSpendProvider).call(
              amount: Money.tryParse(amount.text) ?? Money.zero,
              purpose: purpose.text,
              method: method,
              spentAt: date,
            );
      },
    );
    amount.dispose();
    purpose.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fund = ref.watch(personalFundProvider);
    final spends =
        ref.watch(monthPersonalSpendsProvider).value ?? const <PersonalSpend>[];
    final plan = ref.watch(personalPlanProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: <Widget>[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(Uz.remaining, style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                MoneyText(
                  fund.balance,
                  withSuffix: true,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.personal,
                  ),
                ),
                const SizedBox(height: 12),
                ProgressBar(value: fund.usedRatio, color: AppTheme.personal),
                const SizedBox(height: 8),
                Text(
                  '${Uz.allocated}: ${Fmt.moneyLong(fund.allocated)} · '
                  '${Uz.spent}: ${Fmt.moneyLong(fund.spent)}',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  "Bu pul 🏦 jamg'armaga QO'SHILMAYDI — alohida hisob.",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Shu oyning ajratmasi',
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Reja (sozlamaga ko'ra)",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                MoneyText(plan, withSuffix: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Sarflar tarixi',
            child: spends.isEmpty
                ? const EmptyState()
                : Column(
                    children: <Widget>[
                      for (final spend in spends)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(spend.purpose),
                          subtitle: Text(Fmt.day(spend.spentAt)),
                          trailing: MoneyText(spend.amount),
                          onLongPress: () async {
                            final ok = await confirm(
                              context,
                              title: Uz.delete,
                              message: "${spend.purpose} — o'chirilsinmi?",
                            );
                            if (!ok || !context.mounted) return;
                            await runAction(
                              context,
                              successMessage: "O'chirildi",
                              action: () => ref
                                  .read(removePersonalSpendProvider)
                                  .call(spend),
                            );
                          },
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSpend(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Sarf'),
      ),
    );
  }
}

// ───────────────────────── 🏦 Jamg'arma ─────────────────────────

class _SavingsTab extends ConsumerWidget {
  const _SavingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final series = ref.watch(savingsSeriesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(Uz.collected, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              MoneyText(
                series.total,
                withSuffix: true,
                colorBySign: true,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${series.monthCount} oy · o'rtacha orttirish "
                '${Fmt.moneyLong(series.averageSaved)}',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (series.points.length > 1)
          SectionCard(
            title: "To'planish",
            child: SizedBox(
              height: 200,
              child: SavingsChart(points: series.points),
            ),
          ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Oylar',
          child: series.points.isEmpty
              ? const EmptyState()
              : Column(
                  children: <Widget>[
                    for (final point in series.points.reversed)
                      ListTile(
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
                            MoneyText(point.balance, colorBySign: true),
                            Text(
                              'Σ ${Fmt.moneyCompact(point.cumulative)}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ───────────────────────── 💳 Qarzlar ─────────────────────────

class _DebtsTab extends ConsumerWidget {
  const _DebtsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final views = ref.watch(debtViewsProvider);
    final totals = ref.watch(debtTotalsProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  label: Uz.iOwe,
                  value: totals.iOwe,
                  color: AppTheme.negative,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: Uz.owedToMe,
                  value: totals.owedToMe,
                  color: AppTheme.positive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (views.isEmpty)
            const SectionCard(child: EmptyState(icon: Icons.credit_card_off))
          else
            for (final view in views)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DebtCard(view: view),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDebtForm(context, ref),
        icon: const Icon(Icons.add),
        label: Text(theme.platform == TargetPlatform.iOS ? 'Qarz' : 'Qarz'),
      ),
    );
  }
}

class _DebtCard extends ConsumerWidget {
  const _DebtCard({required this.view});

  final DebtView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debt = view.debt;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  debt.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  debt.isMine ? Uz.iOwe : Uz.owedToMe,
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => showDebtForm(context, ref, existing: debt),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(
            value: view.progress,
            color: view.isClosed ? AppTheme.positive : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${Uz.remaining}: ${Fmt.moneyLong(view.remaining)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (view.isClosed)
                Text(
                  '✅ Yopildi',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.positive,
                  ),
                )
              else if (view.monthsLeft > 0)
                Text(
                  '${view.monthsLeft} oy · '
                  '${Fmt.monthTitle(view.finishMonth!)}',
                  style: theme.textTheme.labelSmall,
                ),
            ],
          ),
          if (view.pending.isPositive)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Bog'langan, lekin hali to'lanmagan: "
                '${Fmt.moneyLong(view.pending)}',
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

// ───────────────────────── 🎯 Maqsadlar ─────────────────────────

class _GoalsTab extends ConsumerWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final views = ref.watch(goalViewsProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: <Widget>[
          if (views.isEmpty)
            const SectionCard(child: EmptyState(icon: Icons.flag_outlined))
          else
            for (final view in views)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              view.goal.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(Fmt.percent(view.progress)),
                          IconButton(
                            onPressed: () => showGoalForm(
                              context,
                              ref,
                              existing: view.goal,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ProgressBar(value: view.progress),
                      const SizedBox(height: 8),
                      Text(
                        '${Fmt.money(view.goal.saved)} / '
                        '${Fmt.moneyLong(view.goal.target)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        view.isDone
                            ? "✅ Yig'ildi"
                            : view.monthsLeft > 0
                                ? '${view.monthsLeft} oy · oyiga '
                                    '${Fmt.moneyCompact(view.perMonth)}'
                                : "— oyiga ajratma yo'q",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: view.isDone
                              ? AppTheme.positive
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showGoalForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Maqsad'),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final Money value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          MoneyText(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
