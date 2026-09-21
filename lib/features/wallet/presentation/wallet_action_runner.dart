import 'package:flutter/material.dart';
import 'package:my_wallet/features/transactions/presentation/add_transaction_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Hamyon yozuvi: muvaffaqiyatda qiymat, xatoda — tushunarli xabar va null.
Future<T?> runWalletAction<T>(
  BuildContext context,
  Future<Result<T>> Function() action,
) async {
  final l10n = AppL10n.of(context);
  final messenger = ScaffoldMessenger.of(context);
  switch (await action()) {
    case Ok(:final value):
      return value;
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(walletErrorText(l10n, failure))),
      );
      return null;
  }
}

/// Qarz/maqsad/limit xatosi → matn (serverdagi kodlar bilan bir xil).
String walletErrorText(AppL10n l10n, Failure failure) => switch (failure) {
  ValidationFailure(code: 'invalid_name') => l10n.errorInvalidName,
  ValidationFailure(code: 'duplicate_name') => l10n.errorDuplicateName,
  ValidationFailure(field: 'paid_before') => l10n.errorPaidBefore,
  ValidationFailure(code: 'invalid_amount') => l10n.errorInvalidAmount,
  ValidationFailure(code: 'currency_mismatch') => l10n.errorCurrencyMismatch,
  _ => transactionErrorText(l10n, failure),
};
