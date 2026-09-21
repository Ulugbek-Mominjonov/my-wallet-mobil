import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:my_wallet/features/dashboard/application/month_report.dart';
import 'package:my_wallet/features/dashboard/application/report_sharer.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// E16-T06: oy hisobini rasm (PNG) sifatida ulashish. Rasm oldindan
/// ko'rsatiladi; maxfiylik rejimida summalar `•••` (BR-212).
class ShareReportScreen extends ConsumerStatefulWidget {
  const new({required this.report, super.key});

  final MonthReport report;

  @override
  ConsumerState<ShareReportScreen> createState() => _ShareReportState();
}

class _ShareReportState extends ConsumerState<ShareReportScreen> {
  /// Rasm sifati: 360 px karta → 1080 px PNG.
  static const double _pixelRatio = 3;

  final GlobalKey _boundary = GlobalKey();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareReport),
        actions: [
          IconButton(
            tooltip: l10n.shareAction,
            icon: const Icon(Icons.share_outlined),
            onPressed: _busy ? null : () => unawaited(_share()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        // Tor ekranda faqat ko'rinish kichrayadi; rasm — doim 360 px kenglikda.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: RepaintBoundary(
            key: _boundary,
            child: ReportShareCard(report: widget.report),
          ),
        ),
      ),
    );
  }

  Future<void> _share() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final month = widget.report.month;
    setState(() => _busy = true);
    try {
      await ref.read(reportSharerProvider)(
        await _capture(),
        fileName: 'my-wallet-$month.png',
        text: formatMonthTitle(l10n, year: month.year, month: month.month),
      );
    } on Object catch (error, stackTrace) {
      AppLog.error('report share failed', error, stackTrace);
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _capture() async {
    final boundary = _boundary.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      throw StateError('share card is not rendered');
    }
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('PNG encoding failed');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}

/// Ulashiladigan oy kartasi: qoldiq, orttirgan %, daromad/xarajat,
/// karta/naqd va eng katta xarajatlar. Kenglik qat'iy — rasm har qurilmada
/// bir xil.
class ReportShareCard extends StatelessWidget {
  const new({required this.report, super.key});

  final MonthReport report;

  static const double width = 360;
  static const int _topCount = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final summary = report.summary;
    final month = report.month;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.appName,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                formatMonthTitle(l10n, year: month.year, month: month.month),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.dashBalance, style: theme.textTheme.labelLarge),
              MoneyText(
                summary.balance.minor,
                currency: summary.balance.currency.code,
                tone: summary.balance.isNegative
                    ? MoneyTone.expense
                    : MoneyTone.neutral,
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                '${l10n.dashSaved}: ${(summary.savedRatio * 100).round()}%',
                style: theme.textTheme.bodyMedium,
              ),
              const Divider(height: AppSpacing.xl),
              _Line(l10n.kindIncome, report.facts.income, MoneyTone.income),
              _Line(l10n.kindExpense, report.facts.expense, MoneyTone.expense),
              _Line(l10n.dashCard, summary.card, MoneyTone.auto),
              _Line(l10n.dashCash, summary.cash, MoneyTone.auto),
              if (_topExpenses case final top when top.isNotEmpty) ...[
                const Divider(height: AppSpacing.xl),
                Text(l10n.shareTopExpenses, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                for (final line in top)
                  _Line(line.name, line.actualTotal, MoneyTone.neutral),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Yuqori darajadagi kategoriyalar (subkategoriyalari bilan), kamayish
  /// tartibida.
  List<CategoryLine> get _topExpenses {
    final lines = [
      for (final category in report.categories)
        if (category.line case final line
            when line.parentId == null && line.actualTotal.isPositive)
          line,
    ]..sort((a, b) => b.actualTotal.minor.compareTo(a.actualTotal.minor));
    return lines.take(_topCount).toList();
  }
}

class _Line extends StatelessWidget {
  const new(this.label, this.amount, this.tone);

  final String label;
  final Money amount;
  final MoneyTone tone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
    child: Row(
      children: [
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: AppSpacing.sm),
        MoneyText(amount.minor, currency: amount.currency.code, tone: tone),
      ],
    ),
  );
}
