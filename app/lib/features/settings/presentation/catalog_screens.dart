import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../di/providers.dart';
import '../../../di/state_providers.dart';

/// Doimiy (har oylik) xarajatlar shabloni.
///
/// Summasi bo'sh qoldirilgan shablon — "har oy o'zgaradi" degani: yangi oy
/// ochilganda reja bo'sh yoziladi (§2.11).
class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(recurringProvider).value ??
        const <RecurringExpense>[];
    return Scaffold(
      appBar: AppBar(title: const Text(Uz.recurring)),
      body: items.isEmpty
          ? const EmptyState(icon: Icons.repeat)
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.category} · ${item.day}-kun · '
                    '${item.method == PaymentMethod.card ? Uz.card : Uz.cash}'
                    '${item.autoPay ? ' · ⚡ ${Uz.autoPay}' : ''}'
                    '${item.active ? '' : " · o'chirilgan"}',
                  ),
                  trailing: Text(
                    item.amount == null
                        ? Uz.unknownAmount
                        : Fmt.money(item.amount!),
                  ),
                  onTap: () => _edit(context, ref, existing: item),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    RecurringExpense? existing,
  }) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final category = TextEditingController(
      text: existing?.category ?? 'Kommunal',
    );
    final amount = TextEditingController(
      text: existing?.amount == null ? '' : Fmt.money(existing!.amount!),
    );
    final day = TextEditingController(text: '${existing?.day ?? 1}');
    var method = existing?.method ?? PaymentMethod.card;
    var autoPay = existing?.autoPay ?? false;
    var active = existing?.active ?? true;

    final result = await showModalBottomSheet<bool>(
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
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nomi'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: category,
                  decoration: const InputDecoration(labelText: Uz.category),
                ),
                const SizedBox(height: 12),
                AmountField(
                  controller: amount,
                  label: "Summa (bo'sh — har oy o'zgaradi)",
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: day,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "To'lov kuni (1–31)",
                  ),
                ),
                const SizedBox(height: 12),
                MethodPicker(
                  value: method,
                  onChanged: (value) => setState(() => method = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(Uz.autoPay),
                  subtitle: const Text(
                    "Sana kelganda fakt o'zi to'ldiriladi",
                  ),
                  value: autoPay,
                  onChanged: (value) => setState(() => autoPay = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Faol'),
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                ),
                const SizedBox(height: 8),
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
    if (result ?? false) {
      await runAction(
        context,
        successMessage: '✅ Saqlandi',
        action: () async {
          await ref.read(saveRecurringProvider).call(
                name: name.text,
                category: category.text,
                method: method,
                day: int.tryParse(day.text) ?? 1,
                existing: existing,
                amount: Money.tryParse(amount.text),
                autoPay: autoPay,
                active: active,
                order: existing?.order ?? 0,
              );
        },
      );
    } else if (result == false && existing != null) {
      await runAction(
        context,
        successMessage: "O'chirildi",
        action: () =>
            ref.read(removeCatalogItemProvider).recurring(existing.id),
      );
    }

    name.dispose();
    category.dispose();
    amount.dispose();
    day.dispose();
  }
}

/// Kategoriya limitlari.
class LimitsScreen extends ConsumerWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(limitsProvider).value ?? const <CategoryLimit>[];
    final statuses = ref.watch(limitStatusesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Uz.limits)),
      body: items.isEmpty
          ? const EmptyState(icon: Icons.speed)
          : ListView(
              children: <Widget>[
                for (final item in items)
                  ListTile(
                    title: Text(item.category),
                    subtitle: Builder(
                      builder: (context) {
                        final status = statuses
                            .where(
                              (element) =>
                                  normalizeKey(element.category) ==
                                  item.categoryKey,
                            )
                            .firstOrNull;
                        if (status == null) return const SizedBox.shrink();
                        return ProgressBar(value: status.ratio);
                      },
                    ),
                    trailing: Text(Fmt.money(item.monthlyLimit)),
                    onTap: () => _edit(context, ref, existing: item),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    CategoryLimit? existing,
  }) async {
    final category = TextEditingController(text: existing?.category ?? '');
    final limit = TextEditingController(
      text: existing == null ? '' : Fmt.money(existing.monthlyLimit),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: Uz.category),
            ),
            const SizedBox(height: 12),
            AmountField(controller: limit, label: 'Oylik limit'),
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
    );

    if (!context.mounted) return;
    if (result ?? false) {
      await runAction(
        context,
        successMessage: '✅ Saqlandi',
        action: () async {
          await ref.read(saveLimitProvider).call(
                category: category.text,
                monthlyLimit: Money.tryParse(limit.text) ?? Money.zero,
                existing: existing,
              );
        },
      );
    } else if (result == false && existing != null) {
      await runAction(
        context,
        successMessage: "O'chirildi",
        action: () => ref.read(removeCatalogItemProvider).limit(existing.id),
      );
    }

    category.dispose();
    limit.dispose();
  }
}

/// Tez qo'shish tugmalari.
class QuickAddScreen extends ConsumerWidget {
  const QuickAddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(quickAddsProvider).value ?? const <QuickAdd>[];
    return Scaffold(
      appBar: AppBar(title: const Text(Uz.quickAdd)),
      body: items.isEmpty
          ? const EmptyState(icon: Icons.bolt)
          : ListView(
              children: <Widget>[
                for (final item in items)
                  ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.category),
                    trailing: Text(Fmt.money(item.amount)),
                    onTap: () => _edit(context, ref, existing: item),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    QuickAdd? existing,
  }) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final category = TextEditingController(
      text: existing?.category ?? 'Oziq-ovqat',
    );
    final amount = TextEditingController(
      text: existing == null ? '' : Fmt.money(existing.amount),
    );
    var method = existing?.method ?? PaymentMethod.cash;

    final result = await showModalBottomSheet<bool>(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nomi'),
              ),
              const SizedBox(height: 12),
              AmountField(controller: amount),
              const SizedBox(height: 12),
              TextField(
                controller: category,
                decoration: const InputDecoration(labelText: Uz.category),
              ),
              const SizedBox(height: 12),
              MethodPicker(
                value: method,
                onChanged: (value) => setState(() => method = value),
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
          await ref.read(saveQuickAddProvider).call(
                name: name.text,
                amount: Money.tryParse(amount.text) ?? Money.zero,
                category: category.text,
                method: method,
                existing: existing,
              );
        },
      );
    } else if (result == false && existing != null) {
      await runAction(
        context,
        successMessage: "O'chirildi",
        action: () =>
            ref.read(removeCatalogItemProvider).quickAdd(existing.id),
      );
    }

    name.dispose();
    category.dispose();
    amount.dispose();
  }
}
