import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/application/add_transaction_controller.dart';
import 'package:my_wallet/features/transactions/presentation/amount_keypad.dart';
import 'package:my_wallet/features/transactions/presentation/month_attribution_field.dart';
import 'package:my_wallet/features/transactions/presentation/quick_actions_bar.dart';
import 'package:my_wallet/features/transactions/presentation/transaction_fields.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "Qo'shish" varag'i (E15): tur, summa, maydonlar va saqlash.
/// Oflaynda ham ishlaydi — yozuv lokal bazaga tushadi (BR-007).
class AddTransactionScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(addTransactionProvider);
    final controller = ref.read(addTransactionProvider.notifier);
    final today = ref.watch(clockProvider).today();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SegmentedButton<TransactionKind>(
                segments: [
                  ButtonSegment(
                    value: TransactionKind.expense,
                    label: Text(l10n.kindExpense),
                  ),
                  ButtonSegment(
                    value: TransactionKind.income,
                    label: Text(l10n.kindIncome),
                  ),
                  ButtonSegment(
                    value: TransactionKind.transfer,
                    label: Text(l10n.kindTransfer),
                  ),
                ],
                selected: {state.kind},
                onSelectionChanged: (selection) =>
                    controller.selectKind(selection.first),
              ),
            ),
            if (state.kind == TransactionKind.expense)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: QuickActionsBar(
                  onSaved: () => context.pop(),
                  onEdit: controller.prefill,
                ),
              ),
            AmountDisplay(entry: state.entry, currency: state.currency),
            // Qisqa forma — hammasi birdan quriladi (dangasa ro'yxat emas).
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AccountChips(
                      selectedId: state.accountId,
                      excludeFund: state.kind == TransactionKind.income,
                      onSelected: controller.selectAccount,
                    ),
                    if (state.isTransfer)
                      AccountChips(
                        label: l10n.fieldTo,
                        selectedId: state.toAccountId,
                        excludeId: state.accountId,
                        onSelected: controller.selectToAccount,
                      )
                    else
                      CategoryGrid(
                        kind: state.kind == TransactionKind.income
                            ? CategoryKind.income
                            : CategoryKind.expense,
                        selectedId: state.categoryId,
                        onSelected: controller.selectCategory,
                        onCreate: (name) async {
                          await controller.createCategory(name);
                        },
                      ),
                    DateChips(
                      today: today,
                      selected: state.occurredOn,
                      onSelected: controller.selectDate,
                    ),
                    FundHint(state: state),
                    MonthAttributionField(state: state),
                    if (!state.isTransfer) ...[
                      PayeeField(state: state),
                      DebtChips(selectedId: state.debtId),
                    ],
                    TagChips(selected: state.tagIds),
                    const NoteField(),
                  ],
                ),
              ),
            ),
            AmountKeypad(onKey: controller.press),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.canSave
                      ? () => unawaited(_save(context, ref))
                      : null,
                  child: state.saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.actionSave),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref, {
    bool confirmClosedMonth = false,
  }) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(addTransactionProvider.notifier)
        .save(confirmClosedMonth: confirmClosedMonth);
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        context.pop();
        messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
      // BR-055: qat'iy bo'lmagan qulf — foydalanuvchi tasdiqlasa yoziladi.
      case Err(failure: MonthClosedWarning(blocking: false)):
        if (await confirmClosedMonthDialog(context) && context.mounted) {
          await _save(context, ref, confirmClosedMonth: true);
        }
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(transactionErrorText(l10n, failure))),
        );
    }
  }
}

/// BR-055: yopilgan oyga yozishni tasdiqlash.
Future<bool> confirmClosedMonthDialog(BuildContext context) async {
  final l10n = AppL10n.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.monthClosedConfirmTitle),
      content: Text(l10n.monthClosedConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.actionRecord),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Amal saqlashdagi xato → foydalanuvchi matni.
String transactionErrorText(AppL10n l10n, Failure failure) => switch (failure) {
  ValidationFailure(code: 'category_required') => l10n.errorCategoryRequired,
  ValidationFailure(field: 'category') => l10n.errorCategoryInvalid,
  ValidationFailure(field: 'to_account') => l10n.errorTargetAccount,
  // Turli valyutali o'tkazma — E29 (ko'p valyuta).
  ValidationFailure(field: 'to_amount') => l10n.errorCurrencyMismatch,
  ValidationFailure(field: 'account') => l10n.errorAccountRequired,
  ValidationFailure(field: 'amount') => l10n.errorAmountRequired,
  MonthClosedWarning() => l10n.errorMonthClosed,
  OfflineFailure() => l10n.errorOffline,
  _ => l10n.errorUnexpected,
};
