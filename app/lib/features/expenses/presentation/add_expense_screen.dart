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

/// 3-ekran: **－ Xarajat**.
///
/// Muhim detal: "Qaysi oyning byudjetiga?" chiplari (§2.2). 5-oktabrdagi
/// mashina to'lovini sentabrga biriktirish shu yerda bir bosishda bo'ladi.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  static const List<String> _defaultCategories = <String>[
    'Oziq-ovqat',
    'Kommunal',
    'Transport',
    'Qarz',
    "O'zim uchun",
    'Boshqa',
  ];

  final TextEditingController _name = TextEditingController();
  final TextEditingController _planned = TextEditingController();
  final TextEditingController _actual = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String _category = 'Oziq-ovqat';
  PaymentMethod _method = PaymentMethod.cash;
  late DateTime _date = ref.read(clockProvider).now();
  MonthKey? _manualMonth;
  String? _debtId;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _planned.dispose();
    _actual.dispose();
    _note.dispose();
    super.dispose();
  }

  MonthKey get _targetMonth => MonthAttribution.forExpense(
        dueDate: _date,
        manualMonth: _manualMonth,
      );

  void _applyQuickAdd(QuickAdd quick) {
    setState(() {
      _name.text = quick.name;
      _actual.text = Fmt.money(quick.amount);
      _category = quick.category;
      _method = quick.method;
    });
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final month = _targetMonth;
    final saved = await runAction(
      context,
      successMessage: "✅ Xarajat qo'shildi — ${Fmt.monthTitle(month)}",
      action: () async {
        await ref.read(addExpenseProvider).call(
              name: _name.text,
              category: _category,
              method: _method,
              dueDate: _date,
              planned: Money.tryParse(_planned.text),
              actual: Money.tryParse(_actual.text),
              manualMonth: _manualMonth,
              debtId: _debtId,
              note: _note.text,
            );
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) {
      _name.clear();
      _planned.clear();
      _actual.clear();
      _note.clear();
      setState(() {
        _debtId = null;
        _manualMonth = null;
      });
      ref.read(selectedMonthProvider.notifier).select(month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quickAdds = ref.watch(quickAddsProvider).value ?? const <QuickAdd>[];
    final categories = <String>{
      ..._defaultCategories,
      ...ref
              .watch(categoriesProvider)
              .value
              ?.where((item) => item.kind == CategoryKind.expense)
              .map((item) => item.name) ??
          const <String>[],
    }.toList();
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    final payables = debts.where((debt) => debt.isMine && !debt.archived);
    final autoMonth = MonthKey.of(_date);

    return Scaffold(
      appBar: AppBar(title: const Text('－ ${Uz.tabExpense}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: <Widget>[
          if (quickAdds.isNotEmpty) ...<Widget>[
            Text(Uz.quickAdd, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final quick in quickAdds)
                  ActionChip(
                    avatar: const Icon(Icons.bolt, size: 16),
                    label: Text(
                      '${quick.name} · ${Fmt.moneyCompact(quick.amount)}',
                    ),
                    onPressed: () => _applyQuickAdd(quick),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Joy / nomi'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Text(Uz.category, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          ChipPicker(
            options: categories,
            value: _category,
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          MethodPicker(
            value: _method,
            onChanged: (value) => setState(() => _method = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: AmountField(controller: _planned, label: Uz.planned),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AmountField(controller: _actual, label: 'Fakt'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Faqat reja — hali to'lanmagan. Faqat fakt — to'lab bo'lingan.",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          DateField(
            value: _date,
            label: "To'lov sanasi",
            onChanged: (value) => setState(() => _date = value),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Qaysi oyning byudjetiga?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    ChoiceChip(
                      label: Text('${Fmt.monthShort(autoMonth)} (avto)'),
                      selected: _manualMonth == null,
                      onSelected: (_) => setState(() => _manualMonth = null),
                    ),
                    ChoiceChip(
                      label: Text(Fmt.monthShort(autoMonth.previous)),
                      selected: _manualMonth == autoMonth.previous,
                      onSelected: (_) =>
                          setState(() => _manualMonth = autoMonth.previous),
                    ),
                    ChoiceChip(
                      label: Text(Fmt.monthShort(autoMonth.next)),
                      selected: _manualMonth == autoMonth.next,
                      onSelected: (_) =>
                          setState(() => _manualMonth = autoMonth.next),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  Fmt.attributionHint(_targetMonth, isIncome: false),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (payables.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              title: "Qarzga bog'lash (ixtiyoriy)",
              child: Column(
                children: <Widget>[
                  for (final debt in payables)
                    SelectTile(
                      title: debt.name,
                      subtitle: 'Qolgan: ${Fmt.moneyLong(
                        (debt.total - debt.paidBefore - debt.paidFromExpenses)
                            .clampedToZero,
                      )}',
                      selected: _debtId == debt.id,
                      onTap: () => setState(() => _debtId = debt.id),
                    ),
                  if (_debtId != null)
                    TextButton(
                      onPressed: () => setState(() => _debtId = null),
                      child: const Text("Bog'lanishni olib tashlash"),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: Uz.note),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: const Icon(Icons.check),
            label: Text(_saving ? Uz.loading : Uz.save),
          ),
        ],
      ),
    );
  }
}
