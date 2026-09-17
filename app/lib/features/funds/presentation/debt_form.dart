import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../di/providers.dart';

/// 💳 Qarz qo'shish / tahrirlash oynasi.
///
/// Hisoblagichlar (`paidFromExpenses` ...) bu yerda TEGILMAYDI — ular
/// bog'langan yozuvlar orqali `increment` bilan yuritiladi.
Future<void> showDebtForm(
  BuildContext context,
  WidgetRef ref, {
  Debt? existing,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final total = TextEditingController(
    text: existing == null ? '' : Fmt.money(existing.total),
  );
  final paidBefore = TextEditingController(
    text: existing == null ? '' : Fmt.money(existing.paidBefore),
  );
  final monthly = TextEditingController(
    text: existing == null ? '' : Fmt.money(existing.monthly),
  );
  var direction = existing?.direction ?? DebtDirection.iOwe;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Padding(
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
                existing == null ? 'Yangi qarz' : Uz.edit,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nomi'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<DebtDirection>(
                segments: const <ButtonSegment<DebtDirection>>[
                  ButtonSegment<DebtDirection>(
                    value: DebtDirection.iOwe,
                    label: Text(Uz.iOwe),
                  ),
                  ButtonSegment<DebtDirection>(
                    value: DebtDirection.owedToMe,
                    label: Text(Uz.owedToMe),
                  ),
                ],
                selected: <DebtDirection>{direction},
                onSelectionChanged: (value) =>
                    setState(() => direction = value.first),
              ),
              const SizedBox(height: 12),
              AmountField(controller: total, label: 'Umumiy summa'),
              const SizedBox(height: 12),
              AmountField(
                controller: paidBefore,
                label: "Oldin to'langan",
              ),
              const SizedBox(height: 12),
              AmountField(controller: monthly, label: "Oylik to'lov"),
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
    ),
  );

  if (!context.mounted) return;
  if (saved ?? false) {
    await runAction(
      context,
      successMessage: '✅ Saqlandi',
      action: () async {
        await ref.read(saveDebtProvider).call(
              name: name.text,
              direction: direction,
              total: Money.tryParse(total.text) ?? Money.zero,
              existing: existing,
              paidBefore: Money.tryParse(paidBefore.text) ?? Money.zero,
              monthly: Money.tryParse(monthly.text) ?? Money.zero,
            );
      },
    );
  } else if (saved == false && existing != null) {
    final ok = await confirm(
      context,
      title: Uz.delete,
      message: "${existing.name} — o'chirilsinmi?",
    );
    if (!ok || !context.mounted) return;
    await runAction(
      context,
      successMessage: "O'chirildi",
      action: () => ref.read(removeDebtProvider).call(existing),
    );
  }

  name.dispose();
  total.dispose();
  paidBefore.dispose();
  monthly.dispose();
}
