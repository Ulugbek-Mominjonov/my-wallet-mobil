import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/format_context.dart';
import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/core/widgets/money_field.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/payments/application/payments_controller.dart';
import 'package:my_wallet/features/payments/presentation/plan_action_runner.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/presentation/transaction_fields.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Swipe / tez to'lash: summa va hisob ma'lum bo'lsa — darhol qolgan summa
/// bilan (BR-073), aks holda to'lash varag'i.
Future<void> quickPay(BuildContext context, WidgetRef ref, PlannedItem plan) {
  if (plan.remaining == null || plan.accountId == null) {
    return showPayPlanSheet(context, plan);
  }
  return runPlanAction(
    context,
    ({required confirmClosedMonth}) => ref
        .read(planActionsProvider)
        .pay(plan.id, confirmClosedMonth: confirmClosedMonth),
    success: AppL10n.of(context).saved,
  );
}

/// E17-T02, T03: "To'landi"/"Keldi" varag'i.
Future<void> showPayPlanSheet(BuildContext context, PlannedItem plan) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PayPlanSheet(plan: plan),
    );

/// Summa (standart — qolgan; noma'lum bo'lsa majburiy), hisob (👤 fonddan
/// emas — BR-062, BR-063), sana. Qolgandan kam summa → "Qisman to'lov —
/// qolganini keyin to'laysizmi?" → qisman yoki "Yopish" (BR-073).
class PayPlanSheet extends ConsumerStatefulWidget {
  const new({required this.plan, super.key});

  final PlannedItem plan;

  @override
  ConsumerState<PayPlanSheet> createState() => _PayPlanSheetState();
}

class _PayPlanSheetState extends ConsumerState<PayPlanSheet> {
  late String? _accountId = widget.plan.accountId;
  Money? _amount;
  LocalDate? _date;

  PlannedItem get _plan => widget.plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final base = switch (ref.watch(startupProvider)) {
      StartupReady(:final currency) => currency,
      _ => Currency.uzs,
    };
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final currency =
        accounts.where((a) => a.id == _accountId).firstOrNull?.currency ?? base;
    // Boshqa valyutadagi hisobda summa har doim qo'lda (BR-073).
    final initial = currency == base ? _plan.remaining : null;
    final amount = _amount ?? initial;
    final payable = _accountId != null && (amount?.isPositive ?? false)
        ? amount
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_plan.name, style: Theme.of(context).textTheme.titleLarge),
              if (_plan.plannedAmount == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    l10n.payAmountRequired,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              MoneyField(
                // Valyuta o'zgarsa — maydon qaytadan (standart summa bilan).
                key: ValueKey(currency),
                label: l10n.fieldAmount,
                initial: initial,
                currency: currency,
                onChanged: (value) => setState(() => _amount = value),
              ),
              AccountChips(
                label: l10n.fieldAccount,
                selectedId: _accountId,
                excludeFund: true,
                onSelected: (id) => setState(() {
                  _accountId = id;
                  _amount = null;
                }),
              ),
              DateChips(
                today: ref.watch(clockProvider).today(),
                selected: _date,
                onSelected: (date) => setState(() => _date = date),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: payable == null
                    ? null
                    : () => unawaited(_submit(payable, currency == base)),
                child: Text(
                  _plan.kind == PlanKind.income
                      ? l10n.payMarkReceived
                      : l10n.dashMarkPaid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(Money amount, bool baseCurrency) async {
    final l10n = AppL10n.of(context);
    var settle = false;
    final remaining = _plan.remaining;
    if (baseCurrency && remaining != null && amount < remaining) {
      final choice = await _askPartial(remaining - amount);
      if (choice == null || !mounted) return;
      settle = choice;
    }
    final paid = await runPlanAction(
      context,
      ({required confirmClosedMonth}) => ref
          .read(planActionsProvider)
          .pay(
            _plan.id,
            amount: amount,
            accountId: _accountId,
            date: _date,
            settle: settle,
            confirmClosedMonth: confirmClosedMonth,
          ),
      success: l10n.saved,
    );
    if (paid != null && mounted) Navigator.pop(context);
  }

  /// `true` — yopish, `false` — qolganini keyin, `null` — bekor.
  Future<bool?> _askPartial(Money rest) {
    final l10n = AppL10n.of(context);
    final text = formatMoney(
      rest.minor,
      currency: rest.currency.code,
      locale: appLocaleOf(context),
    );
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.payPartialTitle),
        content: Text(l10n.payPartialBody(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.payPartialLater),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.payClose),
          ),
        ],
      ),
    );
  }
}
