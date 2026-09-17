import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../di/providers.dart';

/// 🎯 Maqsad qo'shish / tahrirlash oynasi.
Future<void> showGoalForm(
  BuildContext context,
  WidgetRef ref, {
  Goal? existing,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final target = TextEditingController(
    text: existing == null ? '' : Fmt.money(existing.target),
  );
  final saved = TextEditingController(
    text: existing == null ? '' : Fmt.money(existing.saved),
  );
  final monthly = TextEditingController(
    text: existing?.monthly == null ? '' : Fmt.money(existing!.monthly!),
  );

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              existing == null ? 'Yangi maqsad' : Uz.edit,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Maqsad'),
            ),
            const SizedBox(height: 12),
            AmountField(controller: target, label: 'Kerakli summa'),
            const SizedBox(height: 12),
            AmountField(controller: saved, label: "Yig'ilgan"),
            const SizedBox(height: 12),
            AmountField(
              controller: monthly,
              label: "Oyiga ajratma (bo'sh — o'rtacha orttirish)",
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(Uz.save),
            ),
            if (existing != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(Uz.delete),
              ),
          ],
        ),
      ),
    ),
  );

  if (!context.mounted) return;
  if (result ?? false) {
    await runAction(
      context,
      successMessage: '✅ Saqlandi',
      action: () async {
        await ref.read(saveGoalProvider).call(
              name: name.text,
              target: Money.tryParse(target.text) ?? Money.zero,
              existing: existing,
              saved: Money.tryParse(saved.text) ?? Money.zero,
              monthly: Money.tryParse(monthly.text),
            );
      },
    );
  } else if (result == false && existing != null) {
    final ok = await confirm(
      context,
      title: Uz.delete,
      message: "${existing.name} — o'chirilsinmi?",
    );
    if (!ok || !context.mounted) return;
    await runAction(
      context,
      successMessage: "O'chirildi",
      action: () => ref.read(removeGoalProvider).call(existing),
    );
  }

  name.dispose();
  target.dispose();
  saved.dispose();
  monthly.dispose();
}
