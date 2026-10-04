import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:wallet_domain/testing.dart';

import '../../support/fixtures.dart';

/// Chek ro'yxati SQL'i haqiqiy bazada ishlashi (vidjet testlari qo'lda
/// yasalgan qatorlar bilan ishlaydi — so'rovning o'zi shu yerda sinaladi).
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final cases = fixtureCases();
  test('fixture fayllari topildi', () => expect(cases, isNotEmpty));

  for (final testCase in cases) {
    test('monthEntries: ${testCase['file']} — ${testCase['name']}', () async {
      final ledger = FixtureLedger.load(testCase);
      await storeFixture(db, ledger);
      final month = ledger.currentMonth;

      final entries = await db.reportDao.monthEntries('h', month);
      for (final entry in entries) {
        expect(
          entry.name,
          isNotEmpty,
          reason: '${testCase['file']}: nom bo‘sh',
        );
        expect(
          entry.account,
          isNotEmpty,
          reason: '${testCase['file']}: hisob bo‘sh',
        );
      }
      // Daromad va xarajat jamlari oylik faktlar bilan mos (BR-090).
      final facts = (await db.ledgerDao.monthFacts('h', month, month)).single;
      int sumOf(Set<ReceiptLine> lines) => entries
          .where((e) => lines.contains(e.line))
          .fold(0, (sum, e) => sum + e.amount.minor);
      expect(
        sumOf({ReceiptLine.income}),
        facts.income.minor,
        reason: '${testCase['file']}: daromad jami',
      );
      // BR-061: fondga ajratma oy xarajatiga kiradi (`month_facts.expense`).
      expect(
        sumOf({ReceiptLine.expense, ReceiptLine.allocation}),
        facts.expense.minor,
        reason: '${testCase['file']}: xarajat jami (ajratma bilan)',
      );
      expect(
        sumOf({ReceiptLine.allocation}),
        facts.allocated.minor,
        reason: '${testCase['file']}: fondga ajratma jami',
      );
      expect(
        sumOf({ReceiptLine.fundSpent}),
        facts.fundSpent.minor,
        reason: '${testCase['file']}: fonddan sarf jami (BR-063)',
      );
    });
  }

  test('accountBalances: `asOf` keyingi oy amalini hisobga olmaydi', () async {
    final ledger = FixtureLedger.load(fixtureCases().first);
    await storeFixture(db, ledger);
    final month = ledger.currentMonth;

    final atMonthEnd = await db.ledgerDao.accountBalances(
      'h',
      asOf: month.lastDay.toString(),
    );
    final now = await db.ledgerDao.accountBalances('h');
    expect(atMonthEnd.keys, now.keys);
  });
}
