import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:my_wallet/features/reports/domain/receipt.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wallet_domain/wallet_domain.dart';

/// Chek kengligi — kassa chekiga o'xshash tor ustun (80 mm).
/// Chek sahifasi — kassa chekiga o'xshash tor o'lcham. Balandlik cheklangan:
/// `MultiPage` cheksiz sahifani qabul qilmaydi, uzun ro'yxat keyingi
/// sahifaga o'tadi.
const PdfPageFormat _receiptFormat = PdfPageFormat(
  80 * PdfPageFormat.mm,
  200 * PdfPageFormat.mm,
  marginAll: 8,
);

/// Bundagi shriftlar: standart PDF shriftlarida kirill yo'q (ru tili),
/// shuning uchun ilova bilan Roboto keladi (`assets/fonts`).
const _regularFont = 'assets/fonts/Roboto-Regular.ttf';
const _boldFont = 'assets/fonts/Roboto-Bold.ttf';

/// Shriftda yo'q belgilar (emoji, strelka) — PDF'da bo'sh katak bo'lib
/// qolmasligi uchun olib tashlanadi.
final _unsupported = RegExp(r'[←-⇿☀-➿️⬀-⯿]|[\uD800-\uDBFF][\uDC00-\uDFFF]');

String _clean(String text) => text.replaceAll(_unsupported, '').trim();

/// `2026-10-04` → `04.10`.
String _day(String isoDate) =>
    '${isoDate.substring(8)}.${isoDate.substring(5, 7)}';

/// Oylik chekni PDF qilib qaytaradi. Ro'yxat uzun bo'lsa — bir nechta sahifa
/// (`MultiPage` o'zi bo'ladi).
Future<Uint8List> buildReceiptPdf(
  Receipt receipt, {
  required ReceiptLabels labels,
  required bool withFund,
  AppLocale locale = AppLocale.uz,
}) async {
  final regular = pw.Font.ttf(await rootBundle.load(_regularFont));
  final bold = pw.Font.ttf(await rootBundle.load(_boldFont));
  final document = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  String money(Money value) =>
      formatMoney(value.minor, currency: value.currency.code, locale: locale);

  pw.Widget row(String left, String right, {bool strong = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(
            _clean(left),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: strong ? pw.FontWeight.bold : null,
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          right,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: strong ? pw.FontWeight.bold : null,
          ),
        ),
      ],
    ),
  );

  List<pw.Widget> section(
    String title,
    Iterable<ReceiptEntry> rows,
    String totalLabel,
    Money total,
  ) => [
    pw.SizedBox(height: 8),
    pw.Text(
      _clean(title).toUpperCase(),
      style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    ),
    pw.Divider(height: 6, thickness: 0.5),
    if (rows.isEmpty)
      pw.Text(_clean(labels.empty), style: const pw.TextStyle(fontSize: 9))
    else
      for (final entry in rows)
        row(
          '${_day(entry.occurredOn)}  '
          '${entry.name}'
          '${entry.line == ReceiptLine.fundSpent ? ' (${labels.fund})' : ''}',
          money(entry.amount),
        ),
    pw.Divider(height: 6, thickness: 0.5),
    row(totalLabel, money(total), strong: true),
  ];

  final result =
      receipt.totalIncome() - receipt.totalExpense(withFund: withFund);
  document.addPage(
    pw.MultiPage(
      pageFormat: _receiptFormat,
      build: (context) => [
        pw.Center(
          child: pw.Text(
            _clean(labels.title),
            style: const pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            _clean(receipt.household),
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        ...section(
          labels.income,
          receipt.incomes,
          labels.totalIncome,
          receipt.totalIncome(),
        ),
        ...section(
          labels.expense,
          receipt.expenses(withFund: false),
          labels.totalExpense,
          receipt.totalExpense(withFund: false),
        ),
        if (withFund && receipt.fundSpends.isNotEmpty)
          ...section(
            labels.allocation,
            receipt.fundSpends,
            labels.allocated,
            receipt.totalFundSpent(),
          ),
        if (receipt.balances.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            _clean(labels.balances).toUpperCase(),
            style: const pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(height: 6, thickness: 0.5),
          for (final entry in receipt.balances.entries)
            row(entry.key, money(entry.value)),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(height: 6, thickness: 1),
        row(labels.result, money(result), strong: true),
      ],
    ),
  );
  return await document.save();
}
