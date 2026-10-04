import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/format_context.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/share/file_sharer.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/features/reports/application/receipt_controller.dart';
import 'package:my_wallet/features/reports/domain/receipt.dart';
import 'package:my_wallet/features/reports/infrastructure/receipt_pdf.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Oylik chek (BR-164 ruhida): daromad va xarajatlar ro'yxatini matn yoki
/// PDF qilib ulashish — Telegram, pochta yoki saqlash tizim oynasidan.
/// Ma'lumot lokal bazadan, ya'ni oflaynda ham ishlaydi.
class ReceiptSheet extends ConsumerStatefulWidget {
  const new(this.month, {super.key});

  final MonthKey month;

  static Future<void> open(BuildContext context, MonthKey month) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => ReceiptSheet(month),
      );

  @override
  ConsumerState<ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends ConsumerState<ReceiptSheet> {
  bool _withFund = true;
  bool _busy = false;

  ReceiptLabels _labels(AppL10n l10n) => (
    title: l10n.monthReceipt,
    income: l10n.receiptIncome,
    expense: l10n.receiptExpense,
    balances: l10n.receiptBalances,
    totalIncome: l10n.receiptTotalIncome,
    totalExpense: l10n.receiptTotalExpense,
    result: l10n.receiptResult,
    fund: l10n.receiptFund,
    allocation: l10n.receiptAllocation,
    allocated: l10n.receiptAllocated,
    empty: l10n.receiptEmptySection,
  );

  /// Ikkala tugma ham tizim "Ulashish" oynasini ochadi — Telegram shu yerda.
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(receiptProvider(widget.month));
    final title = formatMonthTitle(
      l10n,
      year: widget.month.year,
      month: widget.month.month,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.monthReceipt} · $title',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.monthReceiptHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _withFund,
              onChanged: (value) => setState(() => _withFund = value),
              title: Text(l10n.receiptWithFund),
            ),
            // Xato yuz bersa ko'rsatiladi: avval `.value` ishlatilgani uchun
            // xato yashirinib, spinner aylanaverardi.
            if (state case AsyncError(:final error))
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.receiptFailed,
                  message: '$error',
                ),
              )
            else if (state.value case final receipt?) ...[
              _Preview(receipt: receipt, withFund: _withFund),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        await ref.read(textSharerProvider)(
                          receiptText(
                            receipt,
                            labels: _labels(l10n),
                            withFund: _withFund,
                            locale: appLocaleOf(context),
                          ),
                        );
                      }),
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.receiptShareText),
              ),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        final bytes = await buildReceiptPdf(
                          receipt,
                          labels: _labels(l10n),
                          withFund: _withFund,
                          locale: appLocaleOf(context),
                        );
                        await ref.read(fileSharerProvider)(
                          XFile.fromData(bytes, mimeType: 'application/pdf'),
                          fileName:
                              '${l10n.receiptFileName}-${widget.month}.pdf',
                          text: '${l10n.monthReceipt} · $title',
                        );
                      }),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l10n.receiptSharePdf),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
          ],
        ),
      ),
    );
  }
}

/// Qisqa ko'rinish: nechta yozuv va jamlar (to'liq ro'yxat chekda).
class _Preview extends StatelessWidget {
  const new({required this.receipt, required this.withFund});

  final Receipt receipt;
  final bool withFund;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final expenses = receipt.expenses(withFund: withFund);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Line(
          label: '${l10n.receiptIncome} (${receipt.incomes.length})',
          amount: receipt.totalIncome(),
        ),
        _Line(
          label: '${l10n.receiptExpense} (${expenses.length})',
          amount: receipt.totalExpense(withFund: withFund),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const new({required this.label, required this.amount});

  final String label;
  final Money amount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(amount.toString())],
    ),
  );
}
