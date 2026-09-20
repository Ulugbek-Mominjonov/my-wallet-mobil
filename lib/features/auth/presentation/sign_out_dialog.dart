import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/features/auth/application/sign_out.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Chiqish tasdig'i: qurilmadagi ma'lumot o'chadi; serverga yetmagan
/// o'zgarishlar bo'lsa — alohida ogohlantirish.
Future<void> confirmSignOut(BuildContext context, WidgetRef ref) async {
  final signOut = ref.read(signOutProvider);
  final unsent = await signOut.unsentChanges();
  if (!context.mounted) return;
  final l10n = AppL10n.of(context);
  final scheme = Theme.of(context).colorScheme;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.signOut),
      content: Text(
        unsent > 0 ? l10n.signOutUnsent(unsent) : l10n.signOutConfirm,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.signOut),
        ),
      ],
    ),
  );
  if (confirmed == true) await signOut();
}
