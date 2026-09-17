import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/actions.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/money_text.dart';
import '../../../di/providers.dart';
import '../../../di/state_providers.dart';

/// 4-ekran: **To'lovlar** — to'lanmaganlar ro'yxati.
///
/// So'rov `status` indeksidan ketadi (§4.4), shuning uchun butun jadval
/// skanlanmaydi: faqat `pending` va `overdue` qatorlar o'qiladi.
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buckets = ref.watch(reminderBucketsProvider);
    final async = ref.watch(unpaidExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Uz.tabPayments)),
      body: switch (async) {
        AsyncError<List<Expense>>(:final error) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(unpaidExpensesProvider),
          ),
        AsyncData<List<Expense>>() when buckets.isEmpty => const EmptyState(
            icon: Icons.check_circle_outline,
            message: "🎉 To'lanmagan to'lov yo'q",
          ),
        AsyncData<List<Expense>>() => ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: <Widget>[
              _Bucket(
                title: "⚠️ Muddati o'tgan",
                color: AppTheme.negative,
                items: buckets.overdue,
              ),
              _Bucket(
                title: "📌 Bugun to'lanadi",
                color: AppTheme.warning,
                items: buckets.dueToday,
              ),
              _Bucket(
                title: '🗓 Yaqin kunlarda',
                color: AppTheme.savings,
                items: buckets.upcoming,
              ),
              const SizedBox(height: 16),
              _Summary(buckets: buckets),
            ],
          ),
        _ => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                SkeletonBox(height: 72),
                SizedBox(height: 12),
                SkeletonBox(height: 72),
              ],
            ),
          ),
      },
    );
  }
}

class _Bucket extends StatelessWidget {
  const _Bucket({
    required this.title,
    required this.color,
    required this.items,
  });

  final String title;
  final Color color;
  final List<Expense> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        title: '$title (${items.length})',
        child: Column(
          children: <Widget>[
            for (final expense in items)
              _PaymentRow(expense: expense, color: color),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends ConsumerWidget {
  const _PaymentRow({required this.expense, required this.color});

  final Expense expense;
  final Color color;

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    var amount = expense.planned;
    if (expense.isUnknownAmount) {
      amount = await _askAmount(context);
      if (amount == null) return;
    }
    if (!context.mounted) return;
    await runAction(
      context,
      successMessage: '✅ ${Uz.markPaid}: ${expense.name}',
      action: () => ref
          .read(markPaidProvider)
          .call(expense, amount: amount)
          .then((_) {}),
    );
  }

  Future<Money?> _askAmount(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<Money>(
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
            Text(
              expense.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            AmountField(controller: controller, autofocus: true),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                Money.tryParse(controller.text),
              ),
              child: const Text(Uz.markPaid),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: <Widget>[
          Expanded(child: Text(expense.name)),
          if (expense.autoPay)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.bolt,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${expense.category} · ${Fmt.day(expense.dueDate)}'
        '${expense.isUnknownAmount ? ' · ${Uz.unknownAmount}' : ''}',
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!expense.isUnknownAmount)
            MoneyText(
              expense.plannedOrZero,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: Uz.markPaid,
            onPressed: () => _pay(context, ref),
            icon: const Icon(Icons.check, size: 18),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.buckets});

  final ReminderBuckets buckets;

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Jami to'lanmagan (${buckets.count} ta)",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            MoneyText(
              buckets.total,
              withSuffix: true,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
}
