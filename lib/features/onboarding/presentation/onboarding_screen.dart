import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/money_field.dart';
import 'package:my_wallet/features/onboarding/application/onboarding_controller.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/startup/presentation/splash_screen.dart'
    show startupErrorText;
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Sozlash ustasi (E14-T03): hisoblar → maosh jadvali → doimiy to'lovlar →
/// 👤 fond → tayyor. Har qadamni o'tkazib yuborish mumkin; natija — bitta
/// `onboarding_apply` va joriy oyning ochilishi.
class OnboardingScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);
    const steps = OnboardingStep.values;
    final last = state.step == OnboardingStep.done;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(l10n, state.step)),
        leading: state.step == OnboardingStep.accounts
            ? null
            : BackButton(onPressed: controller.back),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (state.step.index + 1) / steps.length,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    l10n.onboardingStep(state.step.index + 1, steps.length),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _subtitle(l10n, state.step),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!state.loaded)
                    _Waiting(label: l10n.onboardingWaiting)
                  else
                    ..._stepContent(state, controller, ref),
                  if (state.failure != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      startupErrorText(l10n, state.failure!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _Actions(state: state, last: last),
          ],
        ),
      ),
    );
  }

  List<Widget> _stepContent(
    OnboardingState state,
    OnboardingController controller,
    WidgetRef ref,
  ) {
    final currency = switch (ref.watch(startupProvider)) {
      StartupReady(:final currency) => currency,
      _ => Currency.uzs,
    };
    final accounts = [for (final account in state.accounts) account.name];
    return switch (state.step) {
      OnboardingStep.accounts => [
        for (final account in state.accounts)
          AppCard(
            key: ValueKey('account-${account.name}'),
            child: MoneyField(
              label: account.name,
              currency: currency,
              initial: account.balance,
              onChanged: (value) =>
                  controller.setAccountBalance(account.name, value),
            ),
          ),
      ],
      OnboardingStep.income => [
        for (final income in state.incomes)
          _IncomeCard(
            key: ValueKey('income-${income.name}'),
            income: income,
            accounts: accounts,
            currency: currency,
          ),
      ],
      OnboardingStep.recurring => [
        for (final item in state.recurring)
          _RecurringCard(
            key: ValueKey('recurring-${item.name}'),
            item: item,
            accounts: accounts,
            currency: currency,
          ),
      ],
      OnboardingStep.fund => [
        _FundCard(fund: state.fund, accounts: accounts, currency: currency),
      ],
      OnboardingStep.done => [_Summary(state: state)],
    };
  }

  String _title(AppL10n l10n, OnboardingStep step) => switch (step) {
    OnboardingStep.accounts => l10n.onboardingAccountsTitle,
    OnboardingStep.income => l10n.onboardingIncomeTitle,
    OnboardingStep.recurring => l10n.onboardingRecurringTitle,
    OnboardingStep.fund => l10n.onboardingFundTitle,
    OnboardingStep.done => l10n.onboardingDoneTitle,
  };

  String _subtitle(AppL10n l10n, OnboardingStep step) => switch (step) {
    OnboardingStep.accounts => l10n.onboardingAccountsSubtitle,
    OnboardingStep.income => l10n.onboardingIncomeSubtitle,
    OnboardingStep.recurring => l10n.onboardingRecurringSubtitle,
    OnboardingStep.fund => l10n.onboardingFundSubtitle,
    OnboardingStep.done => l10n.onboardingDoneSubtitle,
  };
}

class _Waiting extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: AppSpacing.xl),
      const CircularProgressIndicator(),
      const SizedBox(height: AppSpacing.lg),
      Text(label),
    ],
  );
}

class _Actions extends ConsumerWidget {
  const new({required this.state, required this.last});

  final OnboardingState state;
  final bool last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          if (!last)
            TextButton(
              onPressed: state.busy ? null : controller.next,
              child: Text(l10n.onboardingSkip),
            ),
          const Spacer(),
          FilledButton(
            onPressed: state.busy
                ? null
                : () =>
                      last ? unawaited(controller.apply()) : controller.next(),
            child: state.busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(last ? l10n.onboardingFinish : l10n.actionNext),
          ),
        ],
      ),
    );
  }
}

class _IncomeCard extends ConsumerWidget {
  const new({
    required this.income,
    required this.accounts,
    required this.currency,
    super.key,
  });

  final IncomeDraft income;
  final List<String> accounts;
  final Currency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    void update(IncomeDraft Function(IncomeDraft) change) =>
        controller.updateIncome(income.name, change);

    return AppCard(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(income.name),
            value: income.enabled,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) => update((i) => i.copyWith(enabled: value)),
          ),
          if (income.enabled) ...[
            MoneyField(
              label: l10n.fieldAmount,
              currency: currency,
              initial: income.amount,
              onChanged: (value) => update((i) => i.copyWith(amount: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DayField(
                    value: income.day,
                    onChanged: (day) => update((i) => i.copyWith(day: day)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _AccountField(
                    value: income.account,
                    accounts: accounts,
                    onChanged: (name) =>
                        update((i) => i.copyWith(account: name)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // BR-031/BR-040: daromad qaysi oyning byudjetiga tushadi.
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(l10n.monthThis)),
                ButtonSegment(value: -1, label: Text(l10n.monthPrevious)),
              ],
              selected: {income.monthShift},
              onSelectionChanged: (selection) =>
                  update((i) => i.copyWith(monthShift: selection.first)),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecurringCard extends ConsumerWidget {
  const new({
    required this.item,
    required this.accounts,
    required this.currency,
    super.key,
  });

  final RecurringDraft item;
  final List<String> accounts;
  final Currency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    void update(RecurringDraft Function(RecurringDraft) change) =>
        controller.updateRecurring(item.name, change);

    return AppCard(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(item.name),
            value: item.enabled,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) => update((r) => r.copyWith(enabled: value)),
          ),
          if (item.enabled) ...[
            MoneyField(
              label: l10n.fieldAmount,
              currency: currency,
              initial: item.amount,
              onChanged: (value) => update((r) => r.copyWith(amount: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DayField(
                    value: item.day,
                    onChanged: (day) => update((r) => r.copyWith(day: day)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _AccountField(
                    value: item.account,
                    accounts: accounts,
                    onChanged: (name) =>
                        update((r) => r.copyWith(account: name)),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: Text(l10n.autoPay),
              value: item.autoPay,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) => update((r) => r.copyWith(autoPay: value)),
            ),
          ],
        ],
      ),
    );
  }
}

class _FundCard extends ConsumerWidget {
  const new({
    required this.fund,
    required this.accounts,
    required this.currency,
  });

  final FundDraft fund;
  final List<String> accounts;
  final Currency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(onboardingProvider.notifier);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(l10n.fundPercentMode)),
              ButtonSegment(value: false, label: Text(l10n.fundFixedMode)),
            ],
            selected: {fund.percentMode},
            onSelectionChanged: (selection) => controller.updateFund(
              (f) => f.copyWith(percentMode: selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (fund.percentMode)
            TextFormField(
              initialValue: '${fund.percent}',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.fundPercent,
                suffixText: '%',
              ),
              onChanged: (value) {
                final percent = int.tryParse(value);
                if (percent != null && percent >= 0 && percent <= 100) {
                  controller.updateFund((f) => f.copyWith(percent: percent));
                }
              },
            )
          else
            MoneyField(
              label: l10n.fieldAmount,
              currency: currency,
              initial: fund.fixedAmount,
              onChanged: (value) =>
                  controller.updateFund((f) => f.copyWith(fixedAmount: value)),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DayField(
                  value: fund.day,
                  onChanged: (day) =>
                      controller.updateFund((f) => f.copyWith(day: day)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _AccountField(
                  label: l10n.fundSource,
                  value: fund.account,
                  accounts: accounts,
                  onChanged: (name) =>
                      controller.updateFund((f) => f.copyWith(account: name)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const new({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l10n.onboardingSummary(
                state.accounts.where((a) => a.balance.minor != 0).length,
                state.incomes.where((i) => i.enabled).length,
                state.recurring
                    .where((r) => r.enabled && r.amount != null)
                    .length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayField extends StatelessWidget {
  const new({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: value,
    decoration: InputDecoration(labelText: AppL10n.of(context).fieldDay),
    items: [
      for (var day = 1; day <= 31; day++)
        DropdownMenuItem(value: day, child: Text('$day')),
    ],
    onChanged: (day) {
      if (day != null) onChanged(day);
    },
  );
}

class _AccountField extends StatelessWidget {
  const new({
    required this.value,
    required this.accounts,
    required this.onChanged,
    this.label,
  });

  final String? value;
  final List<String> accounts;
  final ValueChanged<String> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: accounts.contains(value) ? value : null,
    decoration: InputDecoration(
      labelText: label ?? AppL10n.of(context).fieldAccount,
    ),
    items: [
      for (final account in accounts)
        DropdownMenuItem(value: account, child: Text(account)),
    ],
    onChanged: (name) {
      if (name != null) onChanged(name);
    },
  );
}
