import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../features/wallet/wallet_harness.dart';
import '../support/real_fonts.dart';
import '../support/test_database.dart';

/// E20-T03: 200% matn (tizim sozlamasi) — tor telefonda (360 dp) asosiy
/// ekranlar toshib ketmaydi. Haqiqiy shrift bilan (Ahem'da belgilar
/// ancha keng — natija realistik bo'lmaydi).
void main() {
  setUpAll(loadRealFonts);

  late AppDatabase db;
  setUp(() async {
    db = testDatabase();
    await seedWallet(db);
    await db.batch((b) {
      b.insertAll(db.plannedItems, [
        for (final (id, due, amount) in [
          ('Ijara', '2026-10-05', 300000000),
          ('Kommunal xizmatlar', '2026-10-15', null),
          ('Internet va telefon', '2026-10-20', 12000000),
        ])
          PlannedItem(
            id: id,
            householdId: 'h1',
            kind: PlanKind.expense,
            name: id,
            dueDate: LocalDate.parse(due),
            budgetMonth: MonthKey(2026, 10),
            categoryId: 'food',
            accountId: 'card',
            plannedAmount: amount == null ? null : Money(amount),
            paidAmount: id == 'Internet va telefon'
                ? const Money(5000000)
                : Money.zero,
            rowVersion: 1,
          ).toCompanion(),
      ]);
    });
  });
  tearDown(() => db.close());

  for (final path in [
    '/',
    '/transactions',
    '/payments',
    '/wallet',
    '/wallet/fund',
    '/wallet/savings',
    '/wallet/debts',
    '/wallet/goals',
    '/wallet/limits',
    '/add',
    '/settings',
    '/reports/year',
  ]) {
    testWidgets('200% matn: $path', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpWallet(tester, db, path: path, size: const Size(1080, 9000));
      // Maqsadlar: tabrik dialogi ham 200% da chiqadi — yopamiz.
      if (find.text('Rahmat').evaluate().isNotEmpty) {
        await tester.tap(find.text('Rahmat'));
        await tester.pumpAndSettle();
      }
    });
  }
}
