import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Chek sarlavhalari — tilga bog'liq matnlar tashqaridan beriladi, shuning
/// uchun quruvchi sof funksiya bo'lib qoladi (test uchun qulay).
typedef ReceiptLabels = ({
  String title,
  String income,
  String expense,
  String balances,
  String totalIncome,
  String totalExpense,
  String result,
  String fund,
  String empty,
});

/// Oylik chek: amallar ro'yxati va oy oxiridagi qoldiqlar.
final class Receipt {
  const new({
    required this.household,
    required this.month,
    required this.entries,
    required this.balances,
    required this.base,
  });

  final String household;
  final MonthKey month;
  final List<ReceiptEntry> entries;

  /// Hisob nomi → oy oxiridagi qoldiq.
  final Map<String, Money> balances;
  final Currency base;

  Iterable<ReceiptEntry> get incomes =>
      entries.where((e) => e.kind == TransactionKind.income);

  /// [withFund] `false` bo'lsa shaxsiy fond sarflari chiqarib tashlanadi.
  Iterable<ReceiptEntry> expenses({required bool withFund}) => entries.where(
    (e) => e.kind == TransactionKind.expense && (withFund || !e.fromFund),
  );

  Money totalIncome() => _sum(incomes);

  Money totalExpense({required bool withFund}) =>
      _sum(expenses(withFund: withFund));

  Money _sum(Iterable<ReceiptEntry> rows) =>
      rows.fold(Money(0, base), (sum, row) => sum + row.amount);
}

/// Chek matni (Telegram yoki boshqa ilovaga ulashish uchun). Ustunlar
/// tekislanmaydi: Telegram oddiy matnni proporsional shrift bilan
/// ko'rsatadi, shuning uchun har qator "nomi — summa" ko'rinishida.
String receiptText(
  Receipt receipt, {
  required ReceiptLabels labels,
  required bool withFund,
  AppLocale locale = AppLocale.uz,
}) {
  String money(Money value) =>
      formatMoney(value.minor, currency: value.currency.code, locale: locale);
  // `2026-10-04` → `04.10` (chekda qisqa sana).
  String day(String isoDate) =>
      '${isoDate.substring(8)}.${isoDate.substring(5, 7)}';

  final lines = <String>[labels.title, receipt.household, ''];

  void section(String title, Iterable<ReceiptEntry> rows, String totalLabel) {
    lines.add(title.toUpperCase());
    if (rows.isEmpty) {
      lines.add(labels.empty);
    } else {
      for (final row in rows) {
        final fund = row.fromFund ? ' (${labels.fund})' : '';
        lines.add(
          '${day(row.occurredOn)}  ${row.name}$fund — ${money(row.amount)}',
        );
      }
    }
    lines
      ..add('$totalLabel: ${money(_total(rows, receipt.base))}')
      ..add('');
  }

  section(labels.income, receipt.incomes, labels.totalIncome);
  section(
    labels.expense,
    receipt.expenses(withFund: withFund),
    labels.totalExpense,
  );

  if (receipt.balances.isNotEmpty) {
    lines.add(labels.balances.toUpperCase());
    for (final entry in receipt.balances.entries) {
      lines.add('${entry.key} — ${money(entry.value)}');
    }
    lines.add('');
  }

  final result =
      receipt.totalIncome() - receipt.totalExpense(withFund: withFund);
  lines.add('${labels.result}: ${money(result)}');
  return lines.join('\n');
}

Money _total(Iterable<ReceiptEntry> rows, Currency base) =>
    rows.fold(Money(0, base), (sum, row) => sum + row.amount);
