import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/money_field.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:my_wallet/features/wallet/presentation/wallet_action_runner.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// 📊 Limitlar (E18-T06, BR-130..132): xarajat kategoriyalari — joriy oy
/// fakti va limit progressi (80% — sariq, 100% dan oshsa — qizil). Limitni
/// faqat owner/admin o'zgartiradi (server RLS bilan bir xil).
class LimitsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final lines = ref.watch(limitsProvider).value;
    final canManage = ref.watch(canManageLimitsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletLimits)),
      body: lines == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                if (!canManage)
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(l10n.limitsReadOnly),
                  ),
                for (final line in lines)
                  _LimitTile(
                    line: line,
                    onTap: canManage
                        ? () => unawaited(_edit(context, ref, line))
                        : null,
                  ),
              ],
            ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    LimitLine line,
  ) async {
    final edit = await showDialog<_LimitEdit>(
      context: context,
      builder: (_) => _LimitDialog(line: line),
    );
    if (edit == null || !context.mounted) return;
    await runWalletAction(
      context,
      () => ref
          .read(walletActionsProvider)
          .setLimit(
            line.category.id,
            amount: edit.amount,
            rollover: edit.rollover,
            rolloverNegative: edit.rolloverNegative,
          ),
    );
  }
}

class _LimitTile extends ConsumerWidget {
  const new({required this.line, required this.onTap});

  final LimitLine line;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.appColors;
    final (:category, :depth, :actual, :limit, :carry, :status, :ratio) = (
      category: line.category,
      depth: line.depth,
      actual: line.actual,
      limit: line.limit,
      carry: line.carry,
      status: line.status,
      ratio: line.ratio,
    );
    return ListTile(
      contentPadding: EdgeInsetsDirectional.only(
        start: AppSpacing.lg + depth * AppSpacing.xl,
        end: AppSpacing.lg,
      ),
      onTap: onTap,
      title: Text(category.name),
      trailing: ratio == null ? null : Text('${(ratio * 100).round()}%'),
      // Summalar pastda — tor ekranda nom bilan to'qnashmaydi.
      subtitle: limit == null
          ? Text(l10n.limitNone)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: LinearProgressIndicator(
                    value: (ratio ?? 0).clamp(0.0, 1.0),
                    color: switch (status) {
                      LimitStatus.over => colors.expense,
                      LimitStatus.near => colors.warning,
                      _ => colors.income,
                    },
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MoneyText(actual.minor, currency: actual.currency.code),
                    const Text('/'),
                    MoneyText(limit.minor, currency: limit.currency.code),
                    // BR-134: amaldagi limitga o'tgan oydan qo'shilgani.
                    if (!carry.isZero)
                      Text(
                        // BR-212: summa maxfiylik rejimini hurmat qiladi.
                        l10n.limitCarry(moneyLabel(context, ref, carry)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// `amount` null — limit olib tashlanadi.
typedef _LimitEdit = ({Money? amount, bool rollover, bool rolloverNegative});

class _LimitDialog extends ConsumerStatefulWidget {
  const new({required this.line});

  final LimitLine line;

  @override
  ConsumerState<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends ConsumerState<_LimitDialog> {
  late Money? _amount = widget.line.limit;
  late bool _rollover = widget.line.rollover;
  late bool _rolloverNegative = widget.line.rolloverNegative;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currency = switch (ref.watch(startupProvider)) {
      StartupReady(:final currency) => currency,
      _ => Currency.uzs,
    };
    return AlertDialog(
      title: Text(widget.line.category.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyField(
            label: l10n.limitMonthly,
            initial: widget.line.limit,
            currency: currency,
            onChanged: (value) => setState(() => _amount = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.limitRollover),
            value: _rollover,
            onChanged: (value) => setState(() => _rollover = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.limitRolloverNegative),
            value: _rolloverNegative,
            // BR-134: manfiy qoldiq faqat rollover yoqilganda.
            onChanged: _rollover
                ? (value) => setState(() => _rolloverNegative = value)
                : null,
          ),
        ],
      ),
      actions: [
        if (widget.line.limit != null)
          TextButton(
            onPressed: () => Navigator.pop<_LimitEdit>(context, (
              amount: null,
              rollover: false,
              rolloverNegative: false,
            )),
            child: Text(l10n.limitRemove),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: (_amount?.isPositive ?? false) ? _save : null,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }

  /// Qiymat bosilgan paytdagi holatdan olinadi.
  void _save() => Navigator.pop<_LimitEdit>(context, (
    amount: _amount,
    rollover: _rollover,
    rolloverNegative: _rolloverNegative,
  ));
}
