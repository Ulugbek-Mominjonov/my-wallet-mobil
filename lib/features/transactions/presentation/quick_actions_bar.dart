import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/format_context.dart';
import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/transactions/application/quick_add.dart';
import 'package:my_wallet/features/transactions/presentation/add_transaction_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-140, BR-141: tez tugmalar qatori. Bosish — darhol yoziladi va
/// 5 soniya "Bekor qilish"; uzoq bosish — [onEdit] (to'ldirilgan forma).
class QuickActionsBar extends ConsumerWidget {
  const new({this.onSaved, this.onEdit, super.key});

  /// Yozilgach (masalan varaqni yopish).
  final VoidCallback? onSaved;
  final ValueChanged<QuickAction>? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions =
        ref.watch(quickActionsProvider).value ?? const <QuickAction>[];
    if (actions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final action = actions[index];
          return Tooltip(
            message: AppL10n.of(context).quickHint,
            child: GestureDetector(
              onLongPress: onEdit == null ? null : () => onEdit!(action),
              child: ActionChip(
                avatar: const Icon(Icons.bolt, size: 18),
                label: Text(
                  '${action.name} · ${_amount(context, action.amount)}',
                ),
                onPressed: () => unawaited(_add(context, ref, action)),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _amount(BuildContext context, Money amount) => formatMoney(
    amount.minor,
    currency: amount.currency.code,
    locale: appLocaleOf(context),
  );

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    QuickAction action, {
    bool confirmClosedMonth = false,
  }) async {
    final l10n = AppL10n.of(context);
    // Varaq yopilsa ham xabar va bekor qilish ishlasin.
    final messenger = ScaffoldMessenger.of(context);
    final quick = ref.read(quickAddProvider);
    final result = await quick.add(
      action.id,
      confirmClosedMonth: confirmClosedMonth,
    );
    if (!context.mounted) return;
    switch (result) {
      case Ok(:final value):
        unawaited(HapticFeedback.mediumImpact());
        onSaved?.call();
        messenger.showSnackBar(
          SnackBar(
            duration: QuickAddActions.undoWindow,
            content: Text(
              l10n.quickSaved(action.name, _amount(context, action.amount)),
            ),
            action: SnackBarAction(
              label: l10n.actionUndo,
              onPressed: () => unawaited(quick.undo(value.id)),
            ),
          ),
        );
      case Err(failure: MonthClosedWarning(blocking: false)):
        if (await confirmClosedMonthDialog(context) && context.mounted) {
          await _add(context, ref, action, confirmClosedMonth: true);
        }
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(transactionErrorText(l10n, failure))),
        );
    }
  }
}
