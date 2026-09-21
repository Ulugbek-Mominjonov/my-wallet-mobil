import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/application/add_transaction_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-045: tegishli oy jonli ko'rsatiladi; xarajatda (va daromadda —
/// BR-042) oyni tanlash chiplari. O'tkazmada — sana oyi (BR-046), ko'rinmaydi.
class MonthAttributionField extends ConsumerWidget {
  const new({required this.state, super.key});

  final AddTransactionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isTransfer) return const SizedBox.shrink();
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(addTransactionProvider.notifier);
    final today = ref.watch(clockProvider).today();
    final date = state.occurredOn ?? today;
    final income = state.kind == TransactionKind.income;

    final categories =
        ref.watch(categoriesProvider(CategoryKind.income)).value ??
        const <Category>[];
    final shift = income
        ? categories
                  .where((c) => c.id == state.categoryId)
                  .firstOrNull
                  ?.monthShift ??
              0
        : 0;
    final month = attributeBudgetMonth(
      kind: state.kind,
      occurredOn: date,
      manualMonth: state.manualMonth,
      incomeShift: shift,
    );
    final title = formatMonthTitle(l10n, year: month.year, month: month.month);
    final relation = state.manualMonth != null
        ? l10n.monthRelationManual
        : switch (month.compareTo(date.monthKey)) {
            < 0 => l10n.monthRelationPrevious,
            > 0 => l10n.monthRelationNext,
            _ => l10n.monthRelationSame,
          };
    final previous = date.monthKey.shift(-1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            income
                ? l10n.monthHintIncome(title, relation)
                : l10n.monthHintExpense(title, relation),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.monthQuestion, style: theme.textTheme.labelMedium),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: Text(l10n.monthByDate),
                selected: state.manualMonth == null,
                onSelected: (_) => controller.selectMonth(null),
              ),
              ChoiceChip(
                label: Text(l10n.monthPrevious),
                selected: state.manualMonth == previous,
                onSelected: (_) => controller.selectMonth(previous),
              ),
              ChoiceChip(
                avatar: const Icon(Icons.calendar_month, size: 16),
                label: Text(
                  state.manualMonth == null || state.manualMonth == previous
                      ? l10n.monthChoose
                      : title,
                ),
                selected:
                    state.manualMonth != null && state.manualMonth != previous,
                onSelected: (_) =>
                    unawaited(_choose(context, controller, date)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Oxirgi 12 oy va keyingi oy — ro'yxatdan tanlash.
  Future<void> _choose(
    BuildContext context,
    AddTransactionController controller,
    LocalDate date,
  ) async {
    final l10n = AppL10n.of(context);
    final months = [for (var i = 1; i >= -12; i--) date.monthKey.shift(i)];
    final picked = await showModalBottomSheet<MonthKey>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final month in months)
              ListTile(
                title: Text(
                  formatMonthTitle(l10n, year: month.year, month: month.month),
                ),
                onTap: () => Navigator.pop(context, month),
              ),
          ],
        ),
      ),
    );
    if (picked != null) controller.selectMonth(picked);
  }
}
