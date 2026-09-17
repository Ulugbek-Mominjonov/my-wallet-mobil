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

/// 2-ekran: **＋ Daromad**.
///
/// Forma ostida JONLI maslahat turadi: "→ Avgust 2026 oyining daromadi".
/// Bu §2.1 dagi qoidani foydalanuvchiga ko'rsatadi — 1-sentabrda kiritilgan
/// oylik avgustga tushishi kutilmagan hol bo'lib qolmaydi.
class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  static const List<String> _defaultTypes = <String>[
    'Oylik',
    'Avans',
    'KPI',
    "Qo'shimcha",
  ];

  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String _type = 'Oylik';
  PaymentMethod _method = PaymentMethod.card;
  late DateTime _date = ref.read(clockProvider).now();
  String? _debtId;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  MonthKey get _targetMonth => MonthAttribution.forIncome(
        paidAt: _date,
        type: _type,
        rules: ref.read(incomeRulesProvider),
      );

  Future<void> _submit() async {
    final amount = Money.tryParse(_amount.text);
    setState(() => _saving = true);
    final month = _targetMonth;
    final saved = await runAction(
      context,
      successMessage: "✅ Daromad qo'shildi — ${Fmt.monthTitle(month)}",
      action: () async {
        await ref.read(addIncomeProvider).call(
              amount: amount ?? Money.zero,
              type: _type,
              method: _method,
              paidAt: _date,
              rules: ref.read(incomeRulesProvider),
              note: _note.text,
              debtId: _debtId,
            );
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) {
      _amount.clear();
      _note.clear();
      setState(() => _debtId = null);
      ref.read(selectedMonthProvider.notifier).select(month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = <String>{
      ..._defaultTypes,
      ...ref
              .watch(categoriesProvider)
              .value
              ?.where((item) => item.kind == CategoryKind.income)
              .map((item) => item.name) ??
          const <String>[],
    }.toList();
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    final receivables =
        debts.where((debt) => !debt.isMine && !debt.archived).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('＋ ${Uz.tabIncome}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: <Widget>[
          AmountField(
            controller: _amount,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('Tur', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          ChipPicker(
            options: types,
            value: _type,
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 16),
          MethodPicker(
            value: _method,
            onChanged: (value) => setState(() => _method = value),
          ),
          const SizedBox(height: 16),
          DateField(
            value: _date,
            label: 'Olingan sana',
            onChanged: (value) => setState(() => _date = value),
          ),
          const SizedBox(height: 12),
          _AttributionHint(month: _targetMonth),
          if (receivables.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              title: "Haqqa bog'lash (ixtiyoriy)",
              child: Column(
                children: <Widget>[
                  for (final debt in receivables)
                    SelectTile(
                      title: debt.name,
                      subtitle: 'Qolgan: ${Fmt.moneyLong(
                        (debt.total - debt.paidBefore - debt.paidFromIncomes)
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

/// "→ Avgust 2026 oyining daromadi" — qoidaning jonli ko'rinishi.
class _AttributionHint extends StatelessWidget {
  const _AttributionHint({required this.month});

  final MonthKey month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Fmt.attributionHint(month, isIncome: true),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
