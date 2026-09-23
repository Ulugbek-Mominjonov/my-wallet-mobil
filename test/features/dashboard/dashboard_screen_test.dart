import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/share/file_sharer.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/test_database.dart';
import 'dashboard_harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('hero: qoldiq, kuniga, orttirgan %; oy ochilmagan — CTA', (
    tester,
  ) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    await pumpDashboard(tester, db);
    expect(find.text('Oktabr 2026'), findsOneWidget);
    expect(find.text("8 000 000 so'm"), findsWidgets);
    expect(find.textContaining('Kuniga ≈'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Oyni ochish'), findsOneWidget);
    expect(find.text('Oziq-ovqat'), findsOneWidget);
  });

  testWidgets('manfiy qoldiq — qizil; maxfiylik rejimida •••', (tester) async {
    await seedMonth(db, income: 100000000, expense: 300000000);
    await pumpDashboard(tester, db);
    expect(find.text("−2 000 000 so'm"), findsWidgets);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
    expect(find.text("−2 000 000 so'm"), findsNothing);
    expect(find.text('•••'), findsWidgets);
  });

  testWidgets('stat bosilsa — filtrlangan amallar', (tester) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    await pumpDashboard(tester, db);
    await tester.tap(find.text('Daromad').first);
    await tester.pumpAndSettle();
    expect(find.text('Oylik'), findsOneWidget);
    expect(find.text('Oziq-ovqat'), findsNothing);
  });

  testWidgets("yillik ko'rinish va kategoriya trendi", (tester) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    final router = await pumpDashboard(tester, db);
    await tester.tap(find.byTooltip("Yillik ko'rinish"));
    await tester.pumpAndSettle();
    expect(find.text('2026-yil'), findsOneWidget);
    expect(find.text('JAMI'), findsOneWidget);
    // E32-T04: yil xulosasi — o'rtacha xarajat va eng yaxshi oy.
    expect(find.text('Yil xulosasi'), findsOneWidget);
    expect(find.text("Oyiga o'rtacha xarajat"), findsOneWidget);
    expect(find.text("Eng ko'p orttirilgan oy"), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oziq-ovqat'));
    await tester.pumpAndSettle();
    expect(find.text('Oyma-oy'), findsOneWidget);
    expect(find.text("Amallarni ko'rish"), findsOneWidget);
  });

  testWidgets('E32-T03: "Diqqat" — sakrash va obuna', (tester) async {
    await seedMonth(db, income: 1000000000, expense: 20000000);
    // Oldingi uch oy: 200 000 dan (o'rtacha 200 000), oktabrda — 600 000.
    await db.batch((b) {
      b.insertAll(db.transactions, [
        for (final (index, month) in [7, 8, 9].indexed)
          Transaction(
            id: 'p$index',
            householdId: 'h1',
            kind: TransactionKind.expense,
            accountId: 'card',
            amount: const Money(20000000),
            amountBase: const Money(20000000),
            categoryId: 'food',
            occurredOn: LocalDate(2026, month, 5),
            budgetMonth: MonthKey(2026, month),
            rowVersion: 1,
          ).toCompanion(),
        Transaction(
          id: 'spike',
          householdId: 'h1',
          kind: TransactionKind.expense,
          accountId: 'card',
          amount: const Money(40000000),
          amountBase: const Money(40000000),
          categoryId: 'food',
          occurredOn: LocalDate(2026, 10, 6),
          budgetMonth: MonthKey(2026, 10),
          rowVersion: 1,
        ).toCompanion(),
        // Obuna: bir xil nom va summa uch oyda.
        for (final (index, month) in [8, 9, 10].indexed)
          Transaction(
            id: 'sub$index',
            householdId: 'h1',
            kind: TransactionKind.expense,
            accountId: 'card',
            amount: const Money(5000000),
            amountBase: const Money(5000000),
            categoryId: 'food',
            payee: 'Netflix',
            occurredOn: LocalDate(2026, month, 3),
            budgetMonth: MonthKey(2026, month),
            rowVersion: 1,
          ).toCompanion(),
      ]);
    });
    await pumpDashboard(tester, db);

    expect(find.text('Diqqat'), findsOneWidget);
    expect(find.textContaining('Oziq-ovqat'), findsWidgets);
    expect(find.textContaining('Netflix'), findsOneWidget);
  });

  group('ulashish (E16-T06)', () {
    Future<void> openShare(WidgetTester tester, FileSharer sharer) async {
      await seedMonth(db, income: 1000000000, expense: 200000000);
      await pumpDashboard(
        tester,
        db,
        overrides: [fileSharerProvider.overrideWithValue(sharer)],
      );
      await tester.tap(find.text('Hisobotni ulashish'));
      await tester.pumpAndSettle();
    }

    /// PNG kodlash — haqiqiy asinxron (dvigatel) ish.
    Future<void> waitFor(WidgetTester tester, bool Function() done) async {
      for (var i = 0; i < 100 && !done(); i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
    }

    testWidgets("karta ko'rinadi; PNG oy nomi bilan ulashiladi", (
      tester,
    ) async {
      ({Uint8List png, String fileName, String text})? shared;
      await openShare(tester, (file, {required fileName, required text}) async {
        shared = (
          png: await file.readAsBytes(),
          fileName: fileName,
          text: text,
        );
      });
      expect(find.text('Eng katta xarajatlar'), findsOneWidget);
      expect(find.text('Oziq-ovqat'), findsOneWidget);

      await tester.tap(find.byTooltip('Ulashish'));
      await waitFor(tester, () => shared != null);
      expect(shared?.fileName, 'my-wallet-2026-10.png');
      expect(shared?.text, 'Oktabr 2026');
      // PNG imzosi.
      expect(shared?.png.take(4), [0x89, 0x50, 0x4E, 0x47]);
    });

    testWidgets("xato bo'lsa — xabar", (tester) async {
      var calls = 0;
      await openShare(tester, (file, {required fileName, required text}) async {
        calls++;
        throw StateError('no share target');
      });
      await tester.tap(find.byTooltip('Ulashish'));
      await waitFor(tester, () => calls > 0);
      await tester.pumpAndSettle();
      expect(find.text("Ulashib bo'lmadi"), findsOneWidget);
    });
  });

  testWidgets("oy almashtirish; bo'sh oy", (tester) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    await pumpDashboard(tester, db);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Sentabr 2026'), findsOneWidget);
    expect(find.text("Bu oyda hali yozuv yo'q"), findsOneWidget);
    expect(find.text('Hisobotni ulashish'), findsNothing);
    // O'tgan oy uchun "Oyni ochish" taklif qilinmaydi.
    expect(find.text('Oyni ochish'), findsNothing);
  });
}
