import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/money_field.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:my_wallet/features/wallet/presentation/wallet_action_runner.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// 🎯 Maqsadlar (E18-T05, BR-120..123): progress, oyiga (maqsadniki yoki
/// o'rtacha orttirish), "N oy (oy)", ulguradimi; yig'ilganda — bir marta
/// tabrik.
class GoalsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  /// Shu seansda tabrik ko'rsatilgan maqsadlar (ikki marta ochilmasin).
  final Set<String> _celebrated = {};

  @override
  void initState() {
    super.initState();
    // Ochilganda allaqachon yuklangan hisobot ham tekshiriladi.
    ref.listenManual(goalsReportProvider, (_, next) {
      final report = next.value;
      if (report == null) return;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_celebrate(report)),
      );
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final report = ref.watch(goalsReportProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletGoals)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.goalAdd),
        onPressed: () => _openForm(context),
      ),
      body: switch (report) {
        null => const Center(child: CircularProgressIndicator()),
        GoalsReport(:final lines) when lines.isEmpty => EmptyState(
          icon: Icons.flag_outlined,
          title: l10n.goalsEmpty,
        ),
        final report => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            96,
          ),
          children: [
            for (final line in report.lines)
              _GoalCard(line: line, onTap: () => _openForm(context, line.goal)),
          ],
        ),
      },
    );
  }

  Future<void> _openForm(BuildContext context, [Goal? goal]) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => GoalFormScreen(goal: goal),
        ),
      );

  /// BR-123: yangi yig'ilgan maqsad — tabrik; `achieved_at` belgilanadi.
  Future<void> _celebrate(GoalsReport report) async {
    if (!mounted) return;
    final reached = report.lines
        .where(
          (l) =>
              l.progress.isReached &&
              l.goal.achievedAt == null &&
              !_celebrated.contains(l.goal.id),
        )
        .firstOrNull;
    if (reached == null) return;
    _celebrated.add(reached.goal.id);
    await showDialog<void>(
      context: context,
      builder: (_) => _CongratsDialog(name: reached.goal.name),
    );
    if (!mounted) return;
    await runWalletAction(
      context,
      () => ref.read(walletActionsProvider).markAchieved(reached.goal.id),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const new({required this.line, required this.onTap});

  final GoalLine line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final (:goal, :progress) = line;
    final monthly = progress.monthly;
    final end = progress.endMonth;
    final monthsLeft = progress.monthsLeft;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (progress.isReached)
                  Text(l10n.goalReached)
                else if (progress.onTrack case final onTrack?)
                  Text(onTrack ? l10n.goalOnTrack : l10n.goalOffTrack),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: progress.progress,
              color: context.appColors.income,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MoneyText(
                  progress.saved.minor,
                  currency: progress.saved.currency.code,
                ),
                const Text('/'),
                MoneyText(
                  goal.target.minor,
                  currency: goal.target.currency.code,
                ),
              ],
            ),
            if (!progress.isReached)
              Text(
                [
                  if (monthly != null &&
                      progress.monthlySource == GoalMonthlySource.average)
                    l10n.goalPerMonthAvg(moneyLabel(context, ref, monthly))
                  else if (monthly != null)
                    l10n.goalPerMonth(moneyLabel(context, ref, monthly)),
                  if (monthsLeft != null && end != null)
                    l10n.goalEta(
                      monthsLeft,
                      formatMonthTitle(l10n, year: end.year, month: end.month),
                    )
                  else
                    l10n.goalNoForecast,
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

/// BR-123: maqsad yig'ildi — tabrik (kattalashuvchi 🎉 bilan).
class _CongratsDialog extends StatelessWidget {
  const new({required this.name});

  final String name;

  static const Duration _pop = Duration(milliseconds: 600);
  static const double _emojiSize = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      icon: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.3, end: 1),
        duration: _pop,
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: const Text('🎉', style: TextStyle(fontSize: _emojiSize)),
      ),
      content: Text(l10n.goalCongrats(name), textAlign: TextAlign.center),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.goalThanks),
        ),
      ],
    );
  }
}

/// BR-120, BR-122: maqsad qo'shish / tahrirlash — hisobga bog'lash (shu
/// valyutadagi hisoblar) yoki qo'lda yig'ilgan summa; o'chirish.
class GoalFormScreen extends ConsumerStatefulWidget {
  const new({this.goal, super.key});

  final Goal? goal;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.goal?.name,
  );
  late Money? _target = widget.goal?.target;
  late Money? _saved = widget.goal?.savedManual;
  late Money? _monthly = widget.goal?.monthlyContribution;
  late MonthKey? _deadline = widget.goal?.deadline;
  late String? _accountId = widget.goal?.accountId;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currency = switch (ref.watch(startupProvider)) {
      StartupReady(:final currency) => currency,
      _ => Currency.uzs,
    };
    final accounts = [
      for (final account in ref.watch(accountsProvider).value ?? <Account>[])
        if (account.currency == currency && account.isActive) account,
    ];
    final deadline = _deadline;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? l10n.goalAdd : l10n.goalEdit),
        actions: [
          if (widget.goal != null)
            IconButton(
              tooltip: l10n.actionDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => unawaited(_delete()),
            ),
          TextButton(
            onPressed: () => unawaited(_save(currency)),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _name,
            maxLength: maxEntityNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.fieldName),
          ),
          MoneyField(
            label: l10n.goalTarget,
            initial: _target,
            currency: currency,
            onChanged: (value) => _target = value,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String?>(
            initialValue: _accountId,
            // Uzun nom tor ekranda qisqaradi (toshib ketmaydi).
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.goalAccount),
            items: [
              DropdownMenuItem(child: Text(l10n.goalAccountNone)),
              for (final account in accounts)
                DropdownMenuItem(value: account.id, child: Text(account.name)),
            ],
            onChanged: (value) => setState(() => _accountId = value),
          ),
          const SizedBox(height: AppSpacing.sm),
          // BR-122: bog'langan maqsadda yig'ilgan = hisob qoldig'i.
          if (_accountId == null)
            MoneyField(
              label: l10n.goalSaved,
              initial: _saved,
              currency: currency,
              onChanged: (value) => _saved = value,
            ),
          const SizedBox(height: AppSpacing.sm),
          MoneyField(
            label: l10n.goalMonthly,
            initial: _monthly,
            currency: currency,
            onChanged: (value) => _monthly = value,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.goalDeadline),
            subtitle: deadline == null
                ? null
                : Text(
                    formatMonthTitle(
                      l10n,
                      year: deadline.year,
                      month: deadline.month,
                    ),
                  ),
            trailing: deadline == null
                ? null
                : IconButton(
                    tooltip: l10n.actionCancel,
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _deadline = null),
                  ),
            onTap: () => unawaited(_pickDeadline()),
          ),
        ],
      ),
    );
  }

  /// Muddat — oy (sananing oyi olinadi).
  Future<void> _pickDeadline() async {
    final today = ref.read(clockProvider).today();
    final initial = _deadline?.firstDay ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(today.year, today.month),
      lastDate: DateTime(today.year + 50),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null) return;
    setState(() => _deadline = MonthKey(picked.year, picked.month));
  }

  Future<void> _save(Currency currency) async {
    final navigator = Navigator.of(context);
    final monthly = _monthly;
    final saved = await runWalletAction(
      context,
      () => ref
          .read(walletActionsProvider)
          .saveGoal(
            GoalInput(
              name: _name.text,
              target: _target ?? Money(0, currency),
              savedManual: _accountId == null ? _saved : null,
              // Bo'sh maydon — oylik ajratma yo'q (o'rtacha orttirish).
              monthlyContribution: monthly == null || monthly.isZero
                  ? null
                  : monthly,
              deadline: _deadline,
              accountId: _accountId,
            ),
            id: widget.goal?.id,
          ),
    );
    if (saved != null && mounted) navigator.pop();
  }

  Future<void> _delete() async {
    final goal = widget.goal;
    if (goal == null) return;
    final l10n = AppL10n.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.goalDeleteConfirm(goal.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await runWalletAction(
      context,
      () => ref.read(walletActionsProvider).deleteGoal(goal.id),
    );
    if (deleted != null && mounted) navigator.pop();
  }
}
