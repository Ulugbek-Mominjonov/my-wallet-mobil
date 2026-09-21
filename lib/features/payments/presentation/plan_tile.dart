import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/money_field.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/payments/application/payments_controller.dart';
import 'package:my_wallet/features/payments/presentation/pay_plan_sheet.dart';
import 'package:my_wallet/features/payments/presentation/plan_action_runner.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// E17-T02: reja qatori — holat, nom, avto to'lov/qarz belgilari, sana va
/// kategoriya, summa (yoki `?`), qisman to'langan progress, "To'landi"/
/// "Keldi"; swipe → to'liq to'lash; menyu → o'tkazish, shu oy summasi,
/// yopish/qayta ochish.
class PlanTile extends ConsumerWidget {
  const new({required this.plan, super.key});

  final PlannedItem plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final status = PlannedStatus.of(plan, ref.watch(clockProvider).today());
    final income = plan.kind == PlanKind.income;
    final category = _categoryName(ref);
    final planned = plan.plannedAmount;
    final remaining = plan.remaining;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlanStatusIcon(status: status),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        plan.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (plan.autoPay)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: Icon(
                          Icons.autorenew,
                          size: 16,
                          semanticLabel: l10n.payAutoPay,
                        ),
                      ),
                    if (plan.debtId != null)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: Icon(
                          Icons.handshake_outlined,
                          size: 16,
                          semanticLabel: l10n.fieldDebt,
                        ),
                      ),
                  ],
                ),
                Text(
                  [_dayMonth(plan.dueDate), ?category].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
                if (status == PlannedStatus.partial ||
                    (status == PlannedStatus.overdue &&
                        plan.paidAmount.isPositive))
                  if (planned case final planned?)
                    _PartialProgress(paid: plan.paidAmount, planned: planned),
                Row(
                  children: [
                    Expanded(
                      child: switch (status.isOpen ? remaining : planned) {
                        final amount? => MoneyText(
                          amount.minor,
                          currency: amount.currency.code,
                          tone: income ? MoneyTone.income : MoneyTone.neutral,
                        ),
                        null => Text(
                          '? · ${l10n.payAmountVaries}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      },
                    ),
                    if (status.isOpen)
                      TextButton(
                        onPressed: () =>
                            unawaited(showPayPlanSheet(context, plan)),
                        child: Text(
                          income ? l10n.payMarkReceived : l10n.dashMarkPaid,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _PlanMenu(plan: plan, status: status),
        ],
      ),
    );

    if (!status.isOpen) return tile;
    // Swipe → to'liq to'lash; qator ro'yxat yangilanishi bilan o'zgaradi.
    return Dismissible(
      key: ValueKey('pay-${plan.id}'),
      direction: DismissDirection.startToEnd,
      background: ColoredBox(
        color: context.appColors.income.withValues(alpha: 0.15),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: AppSpacing.lg),
            child: Icon(Icons.check),
          ),
        ),
      ),
      confirmDismiss: (_) async {
        await quickPay(context, ref, plan);
        return false;
      },
      child: tile,
    );
  }

  String? _categoryName(WidgetRef ref) {
    final categoryId = plan.categoryId;
    if (categoryId == null) return null;
    final kind = plan.kind == PlanKind.income
        ? CategoryKind.income
        : CategoryKind.expense;
    final categories =
        ref.watch(categoriesProvider(kind)).value ?? const <Category>[];
    return categories.where((c) => c.id == categoryId).firstOrNull?.name;
  }
}

String _dayMonth(LocalDate date) =>
    '${date.day}.${date.month.toString().padLeft(2, '0')}';

/// BR-071 holati belgisi (ro'yxat va kalendar uchun bir xil rang).
class PlanStatusIcon extends StatelessWidget {
  const new({required this.status, super.key});

  final PlannedStatus status;

  @override
  Widget build(BuildContext context) {
    final color = planStatusColor(context, status);
    return Icon(switch (status) {
      PlannedStatus.overdue => Icons.warning_amber,
      PlannedStatus.partial => Icons.timelapse,
      PlannedStatus.paid => Icons.check_circle,
      PlannedStatus.skipped => Icons.skip_next,
      PlannedStatus.pending => Icons.event,
    }, color: color);
  }
}

Color planStatusColor(BuildContext context, PlannedStatus status) {
  final colors = context.appColors;
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    PlannedStatus.overdue => colors.expense,
    PlannedStatus.partial => colors.warning,
    PlannedStatus.paid => colors.income,
    PlannedStatus.skipped => scheme.outline,
    PlannedStatus.pending => scheme.primary,
  };
}

class _PartialProgress extends StatelessWidget {
  const new({required this.paid, required this.planned});

  final Money paid;
  final Money planned;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (paid.minor / planned.minor).clamp(0.0, 1.0),
          color: context.appColors.warning,
        ),
        DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodySmall,
          // Tor ekran/katta shriftda keyingi qatorga o'tadi.
          child: Wrap(
            children: [
              MoneyText(paid.minor, currency: paid.currency.code),
              const Text(' / '),
              MoneyText(planned.minor, currency: planned.currency.code),
            ],
          ),
        ),
      ],
    ),
  );
}

enum _MenuAction { skip, unskip, edit, close, reopen }

class _PlanMenu extends ConsumerWidget {
  const new({required this.plan, required this.status});

  final PlannedItem plan;
  final PlannedStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final skipped = status == PlannedStatus.skipped;
    return PopupMenuButton<_MenuAction>(
      onSelected: (action) => unawaited(_run(context, ref, action)),
      itemBuilder: (context) => [
        if (!skipped)
          PopupMenuItem(
            value: _MenuAction.edit,
            child: Text(l10n.payEditAmount),
          ),
        if (status.isOpen && plan.paidAmount.isPositive)
          PopupMenuItem(value: _MenuAction.close, child: Text(l10n.payClose)),
        if (plan.closedAt != null)
          PopupMenuItem(value: _MenuAction.reopen, child: Text(l10n.payReopen)),
        if (status.isOpen)
          PopupMenuItem(value: _MenuAction.skip, child: Text(l10n.paySkip)),
        if (skipped)
          PopupMenuItem(value: _MenuAction.unskip, child: Text(l10n.payUnskip)),
      ],
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    _MenuAction action,
  ) async {
    final l10n = AppL10n.of(context);
    final actions = ref.read(planActionsProvider);
    switch (action) {
      case _MenuAction.skip:
        final done = await runPlanAction(
          context,
          ({required confirmClosedMonth}) =>
              actions.skip(plan.id, confirmClosedMonth: confirmClosedMonth),
        );
        if (done == null || !context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paySkipped),
            action: SnackBarAction(
              label: l10n.actionUndo,
              onPressed: () => unawaited(
                actions.skip(plan.id, skipped: false, confirmClosedMonth: true),
              ),
            ),
          ),
        );
      case _MenuAction.unskip:
        await runPlanAction(
          context,
          ({required confirmClosedMonth}) => actions.skip(
            plan.id,
            skipped: false,
            confirmClosedMonth: confirmClosedMonth,
          ),
        );
      case _MenuAction.close || _MenuAction.reopen:
        await runPlanAction(
          context,
          ({required confirmClosedMonth}) => actions.close(
            plan.id,
            closed: action == _MenuAction.close,
            confirmClosedMonth: confirmClosedMonth,
          ),
          success: l10n.saved,
        );
      case _MenuAction.edit:
        final edited = await showDialog<_PlanEdit>(
          context: context,
          builder: (_) => _EditPlanDialog(plan: plan),
        );
        if (edited == null || !context.mounted) return;
        await runPlanAction(
          context,
          ({required confirmClosedMonth}) => actions.edit(
            plan.id,
            plannedAmount: edited.amount,
            dueDate: edited.dueDate,
            confirmClosedMonth: confirmClosedMonth,
          ),
          success: l10n.saved,
        );
    }
  }
}

typedef _PlanEdit = ({Money? amount, LocalDate dueDate});

/// BR-083: shu oy summasi (yoki "summa o'zgaruvchi") va to'lov kuni.
class _EditPlanDialog extends ConsumerStatefulWidget {
  const new({required this.plan});

  final PlannedItem plan;

  @override
  ConsumerState<_EditPlanDialog> createState() => _EditPlanDialogState();
}

class _EditPlanDialogState extends ConsumerState<_EditPlanDialog> {
  late Money? _amount = widget.plan.plannedAmount;
  late bool _varies = widget.plan.plannedAmount == null;
  late LocalDate _dueDate = widget.plan.dueDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final base = switch (ref.watch(startupProvider)) {
      StartupReady(:final currency) => currency,
      _ => Currency.uzs,
    };
    final amount = _varies ? null : _amount;
    final valid = _varies || (amount?.isPositive ?? false);
    return AlertDialog(
      title: Text(widget.plan.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoneyField(
              label: l10n.payEditAmount,
              initial: widget.plan.plannedAmount,
              currency: base,
              enabled: !_varies,
              onChanged: (value) => setState(() => _amount = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.payAmountVaries),
              value: _varies,
              // Avto to'lov summasiz bo'lmaydi (server CHECK).
              onChanged: widget.plan.autoPay
                  ? null
                  : (value) => setState(() => _varies = value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(l10n.fieldDate),
              trailing: Text(_dayMonth(_dueDate)),
              onTap: () => unawaited(_pickDate()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: valid ? _save : null,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }

  /// Qiymatlar bosilgan paytdagi holatdan olinadi.
  void _save() => Navigator.pop<_PlanEdit>(context, (
    amount: _varies ? null : _amount,
    dueDate: _dueDate,
  ));

  /// To'lov kuni — reja oyi atrofida (daromad oy siljishi bilan kelishi
  /// mumkin, BR-043).
  Future<void> _pickDate() async {
    final month = widget.plan.budgetMonth;
    final first = month.shift(-1).firstDay;
    final last = month.shift(1).lastDay;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_dueDate.year, _dueDate.month, _dueDate.day),
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: DateTime(last.year, last.month, last.day),
    );
    if (picked == null) return;
    setState(() => _dueDate = LocalDate(picked.year, picked.month, picked.day));
  }
}
