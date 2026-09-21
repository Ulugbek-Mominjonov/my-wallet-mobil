import 'package:flutter/material.dart';
import 'package:my_wallet/features/transactions/presentation/add_transaction_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Reja amali: yopilgan oy — foydalanuvchi tasdig'i bilan qayta (BR-055);
/// xato — tushunarli xabar. Muvaffaqiyatda qiymat, aks holda null.
Future<T?> runPlanAction<T>(
  BuildContext context,
  Future<Result<T>> Function({required bool confirmClosedMonth}) action, {
  String? success,
}) async {
  final l10n = AppL10n.of(context);
  final messenger = ScaffoldMessenger.of(context);
  var result = await action(confirmClosedMonth: false);
  if (result case Err(failure: MonthClosedWarning(blocking: false))) {
    if (!context.mounted || !await confirmClosedMonthDialog(context)) {
      return null;
    }
    result = await action(confirmClosedMonth: true);
  }
  switch (result) {
    case Ok(:final value):
      if (success != null) {
        messenger.showSnackBar(SnackBar(content: Text(success)));
      }
      return value;
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(planErrorText(l10n, failure))),
      );
      return null;
  }
}

/// Reja xatosi → foydalanuvchi matni (serverdagi kodlar bilan bir xil).
String planErrorText(AppL10n l10n, Failure failure) => switch (failure) {
  ValidationFailure(code: 'planned_already_paid') => l10n.errorPlanPaid,
  ValidationFailure(code: 'planned_skipped') => l10n.errorPlanSkipped,
  ValidationFailure(code: 'planned_not_found') => l10n.errorPlanNotFound,
  ValidationFailure(code: 'amount_required') => l10n.payAmountRequired,
  _ => transactionErrorText(l10n, failure),
};
