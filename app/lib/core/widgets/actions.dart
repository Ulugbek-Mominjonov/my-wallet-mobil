import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../error/failure_message.dart';
import '../logging/app_log.dart';

/// Formadagi amalni bajaradi: haptik javob, xato xabari, muvaffaqiyat toasti.
///
/// Xato HECH QACHON jimgina yutilmaydi: foydalanuvchiga tushunarli xabar,
/// logga to'liq stack.
Future<bool> runAction(
  BuildContext context, {
  required Future<void> Function() action,
  String? successMessage,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final errorColor = Theme.of(context).colorScheme.errorContainer;
  try {
    await action();
    await HapticFeedback.lightImpact();
    if (successMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return true;
  } on Object catch (error, stackTrace) {
    AppLog.error('Amal bajarilmadi', error, stackTrace);
    await HapticFeedback.heavyImpact();
    messenger.showSnackBar(
      SnackBar(
        content: Text(failureMessage(error)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: errorColor,
      ),
    );
    return false;
  }
}

/// Tasdiqlash oynasi — o'chirish va oy yopish kabi amallar uchun.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ha',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Yo'q"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
