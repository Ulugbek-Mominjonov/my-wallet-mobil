import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/money_field.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_controller.dart';
import 'package:my_wallet/features/wallet/presentation/wallet_action_runner.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-110: qarz qo'shish / tahrirlash (member ham). Yo'nalish faqat
/// yaratishda tanlanadi; summalar — byudjetning asosiy valyutasida.
class DebtFormScreen extends ConsumerStatefulWidget {
  const new({this.debt, super.key});

  /// Tahrirlanadigan qarz (null — yangi).
  final Debt? debt;

  @override
  ConsumerState<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends ConsumerState<DebtFormScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.debt?.name,
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.debt?.note,
  );
  late DebtDirection _direction = widget.debt?.direction ?? DebtDirection.iOwe;
  late Money? _total = widget.debt?.total;
  late Money? _paidBefore = widget.debt?.paidBefore;
  late Money? _monthly = widget.debt?.monthlyPayment;
  late LocalDate? _dueDate = widget.debt?.dueDate;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currency = switch (ref.watch(startupProvider)) {
      StartupReady(:final currency) => currency,
      _ => Currency.uzs,
    };
    final editing = widget.debt != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l10n.debtEdit : l10n.debtAdd),
        actions: [
          TextButton(
            onPressed: () => unawaited(_save(currency)),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SegmentedButton<DebtDirection>(
            segments: [
              ButtonSegment(
                value: DebtDirection.iOwe,
                label: Text(l10n.dashIOwe),
              ),
              ButtonSegment(
                value: DebtDirection.owedToMe,
                label: Text(l10n.dashOwedToMe),
              ),
            ],
            selected: {_direction},
            // Yo'nalish yaratilgandan keyin o'zgarmaydi (server qoidasi).
            onSelectionChanged: editing
                ? null
                : (selection) => setState(() => _direction = selection.first),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _name,
            maxLength: maxEntityNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.fieldName),
          ),
          MoneyField(
            label: l10n.debtTotal,
            initial: _total,
            currency: currency,
            onChanged: (value) => _total = value,
          ),
          const SizedBox(height: AppSpacing.sm),
          MoneyField(
            label: l10n.debtPaidBefore,
            initial: _paidBefore,
            currency: currency,
            onChanged: (value) => _paidBefore = value,
          ),
          const SizedBox(height: AppSpacing.sm),
          MoneyField(
            label: l10n.debtMonthlyPayment,
            initial: _monthly,
            currency: currency,
            onChanged: (value) => _monthly = value,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.debtDueDate),
            subtitle: switch (_dueDate) {
              final date? => Text(_formatDate(date)),
              null => null,
            },
            trailing: _dueDate == null
                ? null
                : IconButton(
                    tooltip: l10n.actionCancel,
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dueDate = null),
                  ),
            onTap: () => unawaited(_pickDueDate()),
          ),
          TextField(
            controller: _note,
            maxLength: maxNoteLength,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(labelText: l10n.fieldNote),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final today = ref.read(clockProvider).today();
    final initial = _dueDate ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(today.year - 10),
      lastDate: DateTime(today.year + 30),
    );
    if (picked == null) return;
    setState(() => _dueDate = LocalDate(picked.year, picked.month, picked.day));
  }

  Future<void> _save(Currency currency) async {
    final navigator = Navigator.of(context);
    final monthly = _monthly;
    final saved = await runWalletAction(
      context,
      () => ref
          .read(walletActionsProvider)
          .saveDebt(
            DebtInput(
              name: _name.text,
              direction: _direction,
              total: _total ?? Money(0, currency),
              paidBefore: _paidBefore,
              // Bo'sh maydon — oylik to'lov yo'q.
              monthlyPayment: monthly == null || monthly.isZero
                  ? null
                  : monthly,
              dueDate: _dueDate,
              note: _note.text,
            ),
            id: widget.debt?.id,
          ),
    );
    if (saved != null && mounted) navigator.pop(saved);
  }
}

String _formatDate(LocalDate date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.${date.year}';
