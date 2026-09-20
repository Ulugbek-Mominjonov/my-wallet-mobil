import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/features/transactions/application/add_transaction_controller.dart';
import 'package:my_wallet/features/transactions/presentation/amount_keypad.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "Qo'shish" varag'i (E15-T01): tur, summa klaviaturasi. Maydonlar,
/// tegishli oy izohi va saqlash — E15-T02..T05.
class AddTransactionScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(addTransactionProvider);
    final controller = ref.read(addTransactionProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
            const Spacer(),
            AmountKeypad(
              entry: state.entry,
              currency: state.currency,
              onKey: controller.press,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.canSave ? () {} : null,
                  child: Text(l10n.actionSave),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
