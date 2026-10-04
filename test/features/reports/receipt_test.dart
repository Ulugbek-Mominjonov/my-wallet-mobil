import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:my_wallet/features/reports/domain/receipt.dart';
import 'package:wallet_domain/wallet_domain.dart';

const ReceiptLabels _labels = (
  title: 'Oylik chek',
  income: 'Daromad',
  expense: 'Xarajat',
  balances: 'Oy oxiridagi qoldiq',
  totalIncome: 'Jami daromad',
  totalExpense: 'Jami xarajat',
  result: 'Qoldiq',
  fund: 'fonddan',
  allocation: 'Fondga ajratma',
  allocated: 'Jami ajratma',
  empty: 'Yozuv yo‘q',
);

ReceiptEntry _entry({
  required String id,
  required ReceiptLine line,
  required String date,
  required int amount,
  required String name,
}) => (
  id: id,
  line: line,
  occurredOn: date,
  amount: Money(amount),
  name: name,
  category: 'Kategoriya',
  account: line == ReceiptLine.fundSpent ? 'Shaxsiy fond' : 'Karta',
);

Receipt _receipt() => Receipt(
  household: 'Oila byudjeti',
  month: MonthKey.parse('2026-10'),
  entries: [
    _entry(
      id: 'i1',
      line: ReceiptLine.income,
      date: '2026-10-01',
      amount: 500000000,
      name: 'Oylik',
    ),
    _entry(
      id: 'e1',
      line: ReceiptLine.expense,
      date: '2026-10-03',
      amount: 12000000,
      name: 'Bozor',
    ),
    _entry(
      id: 'e2',
      line: ReceiptLine.fundSpent,
      date: '2026-10-04',
      amount: 3000000,
      name: 'Taksi',
    ),
  ],
  balances: {'Karta': const Money(488000000), 'Naqd': Money.zero},
  base: Currency.uzs,
);

void main() {
  group('chek matni', () {
    test('sarlavha, ikkala ro‘yxat, jamlar va qoldiqlar', () {
      final text = receiptText(_receipt(), labels: _labels, withFund: true);

      expect(text, contains('Oylik chek'));
      expect(text, contains('Oila byudjeti'));
      expect(text, contains('01.10  Oylik'));
      expect(text, contains('03.10  Bozor'));
      // Fonddan sarflangan qator belgilanadi (BR-063).
      expect(text, contains('04.10  Taksi (fonddan)'));
      expect(text, contains('Jami daromad'));
      expect(text, contains('OY OXIRIDAGI QOLDIQ'));
      expect(text, contains('Karta'));
    });

    test('fondsiz: sarf ro‘yxatdan ham, jamdan ham chiqadi', () {
      final receipt = _receipt();
      final text = receiptText(receipt, labels: _labels, withFund: false);

      expect(text, isNot(contains('Taksi')));
      // BR-063: fonddan sarf xarajat jamiga kirmaydi (pul fondga
      // ajratilganda allaqachon sanalgan) — tugmacha faqat ko'rinishga ta'sir.
      expect(receipt.totalExpense(withFund: false), const Money(12000000));
      expect(receipt.totalExpense(withFund: true), const Money(12000000));
      expect(receipt.totalFundSpent(), const Money(3000000));
    });

    test('bo‘sh oy — bo‘lim o‘rniga izoh', () {
      final receipt = Receipt(
        household: 'Shaxsiy',
        month: MonthKey.parse('2026-11'),
        entries: const [],
        balances: const {},
        base: Currency.uzs,
      );
      final text = receiptText(receipt, labels: _labels, withFund: true);

      expect('Yozuv yo‘q'.allMatches(text).length, 2);
      expect(receipt.totalIncome(), Money.zero);
    });
  });
}
