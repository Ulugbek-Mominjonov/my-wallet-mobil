import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/presentation/transactions_screen.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';
import '../../support/test_database.dart';
import 'wallet_harness.dart';

/// Pul matni — `formatMoney` guruhlarni bo'linmas bo'shliq bilan ajratadi.
String money(String text) => text.replaceAll(' ', ' ');

void main() {
  late AppDatabase db;

  setUp(() async {
    db = testDatabase();
    await seedWallet(db);
  });
  tearDown(() => db.close());

  group('Hisoblar va BR-005', () {
    testWidgets("fondsiz jami; fond va jamg'arma alohida, qo'shilmaydi", (
      tester,
    ) async {
      await pumpWallet(tester, db);
      expect(find.text(money("17 000 000 so'm")), findsOneWidget);
      expect(find.text(money("−300 000 so'm")), findsOneWidget);
      // Jami — fondsiz (karta + naqd).
      expect(find.text('Jami (fondsiz)'), findsOneWidget);
      expect(find.text(money("16 700 000 so'm")), findsOneWidget);
      // 👤 fond va 🏦 jamg'arma — alohida qatorlarda.
      expect(find.text(money("800 000 so'm")), findsWidgets);
      expect(find.text(money("11 700 000 so'm")), findsOneWidget);
      // BR-005: fond + jamg'arma (12 500 000) yoki hamma hisoblar
      // (17 500 000) bitta "jami" sifatida hech qayerda yo'q.
      expect(find.text(money("12 500 000 so'm")), findsNothing);
      expect(find.text(money("17 500 000 so'm")), findsNothing);
    });

    testWidgets('BR-025: manfiy naqd — ogohlantirish', (tester) async {
      await pumpWallet(tester, db);
      expect(
        find.text('Naqd qoldiq manfiy — yozuvlarni tekshiring'),
        findsOneWidget,
      );
    });

    testWidgets('hisob bosilsa — shu hisob harakatlari', (tester) async {
      await pumpWallet(tester, db);
      await tester.tap(find.text('Naqd').last);
      await tester.pumpAndSettle();
      expect(find.byType(TransactionsScreen), findsOneWidget);
      expect(find.text('Oziq-ovqat'), findsOneWidget);
      expect(find.text('Oylik'), findsNothing);
    });

    testWidgets("\"O'tkazma\" — o'tkazma turi tanlangan qo'shish varag'i", (
      tester,
    ) async {
      await pumpWallet(tester, db);
      await tester.tap(find.widgetWithText(TextButton, "O'tkazma"));
      await tester.pumpAndSettle();
      final segmented = tester.widget<SegmentedButton<TransactionKind>>(
        find.byType(SegmentedButton<TransactionKind>),
      );
      expect(segmented.selected, {TransactionKind.transfer});
    });
  });

  group('👤 fond', () {
    testWidgets("qoldiq, shu oy va butun davr; ajratma rejasi yo'q", (
      tester,
    ) async {
      await pumpWallet(tester, db, path: '/wallet/fund');
      expect(find.text(money("800 000 so'm")), findsOneWidget);
      expect(find.text(money("1 000 000 so'm")), findsWidgets);
      expect(find.text(money("200 000 so'm")), findsWidgets);
      expect(find.text("Bu oy uchun ajratma rejasi yo'q"), findsOneWidget);
      // BR-060: foiz rejimi — 10 000 000 × 10%.
      expect(
        find.text('Hozirgi daromaddan: ${money("1 000 000 so'm")} (10%)'),
        findsOneWidget,
      );
    });

    testWidgets("\"Sarf qo'shish\" — fond hisobi va xarajat tanlangan", (
      tester,
    ) async {
      await pumpWallet(tester, db, path: '/wallet/fund');
      await tester.tap(find.text("Sarf qo'shish"));
      await tester.pumpAndSettle();
      final account = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Shaxsiy fond'),
      );
      expect(account.selected, isTrue);
    });
  });

  testWidgets("🏦 jamg'arma: jadval, ⏳ joriy oy, izoh", (tester) async {
    await pumpWallet(tester, db, path: '/wallet/savings');
    expect(find.text(money("11 700 000 so'm")), findsWidgets);
    expect(find.text('Oktabr 2026 ⏳'), findsOneWidget);
    expect(find.text('Sentabr 2026'), findsOneWidget);
    expect(find.textContaining('Hisoblar'), findsOneWidget);
  });

  group('💳 qarzlar', () {
    testWidgets('holatlar va jamlar (BR-114, BR-116)', (tester) async {
      await pumpWallet(tester, db, path: '/wallet/debts');
      expect(find.text("To'lanyapti"), findsOneWidget);
      expect(find.text("Bog'lanmagan"), findsNWidgets(2));
      // Men qarzdorman: 7 000 000 + 500 000; sof: 300 000 − 7 500 000.
      expect(find.text(money("7 500 000 so'm")), findsOneWidget);
      expect(find.text(money("−7 200 000 so'm")), findsOneWidget);
      expect(find.text('Tugaydi: May 2027'), findsOneWidget);
    });

    testWidgets("qo'shish — lokal yozuv + outbox", (tester) async {
      await pumpWallet(tester, db, path: '/wallet/debts');
      await tester.tap(find.text("Qarz qo'shish"));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Nomi'), 'Kurs');
      await tester.enterText(
        find.widgetWithText(TextField, 'Umumiy summa'),
        '2000000',
      );
      await tester.tap(find.text('Saqlash'));
      await tester.pumpAndSettle();
      final debt = await (db.select(
        db.debts,
      )..where((d) => d.name.equals('Kurs'))).getSingle();
      expect(debt.total, som(2000000));
      final outbox = await db.select(db.outbox).get();
      expect(outbox.single.targetTable, 'debts');
      expect(find.text('Kurs'), findsOneWidget);
    });

    testWidgets('takror nom — xabar, yozilmaydi', (tester) async {
      await pumpWallet(tester, db, path: '/wallet/debts');
      await tester.tap(find.text("Qarz qo'shish"));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Nomi'), 'mashina');
      await tester.enterText(
        find.widgetWithText(TextField, 'Umumiy summa'),
        '100',
      );
      await tester.tap(find.text('Saqlash'));
      await tester.pumpAndSettle();
      expect(find.text('Bu nom allaqachon bor'), findsOneWidget);
      expect(await db.select(db.outbox).get(), isEmpty);
    });

    testWidgets("tafsilot: bog'langan to'lovlar; arxivlash", (tester) async {
      await pumpWallet(tester, db, path: '/wallet/debts/car');
      expect(find.text("Bog'langan to'lovlar"), findsOneWidget);
      expect(find.text('2026-10-10'), findsOneWidget);
      await tester.tap(find.byTooltip('Arxivlash'));
      await tester.pumpAndSettle();
      final car = await (db.select(
        db.debts,
      )..where((d) => d.id.equals('car'))).getSingle();
      expect(car.archivedAt, isNotNull);
    });
  });

  group('🎯 maqsadlar', () {
    testWidgets("ulguradi / ulgurmaydi; yig'ilgan — bir marta tabrik", (
      tester,
    ) async {
      await pumpWallet(tester, db, path: '/wallet/goals');
      // BR-123: hisobga bog'langan "Zaxira" yig'ilgan — tabrik.
      expect(
        find.text("Tabriklaymiz! «Zaxira» maqsadi yig'ildi"),
        findsOneWidget,
      );
      await tester.tap(find.text('Rahmat'));
      await tester.pumpAndSettle();
      final cushion = await (db.select(
        db.goals,
      )..where((g) => g.id.equals('cushion'))).getSingle();
      expect(cushion.achievedAt, isNotNull);
      expect(find.textContaining('Tabriklaymiz'), findsNothing);

      expect(find.text('✅ Ulguradi'), findsOneWidget);
      expect(find.text('⚠️ Ulgurmaydi'), findsOneWidget);
      expect(find.text("🎉 Yig'ildi"), findsOneWidget);
      // O'rtacha orttirish: (4 000 000 + 8 500 000) / 2 = 6 250 000.
      expect(
        find.textContaining("oyiga ${money("6 250 000 so'm")} (o'rtacha)"),
        findsOneWidget,
      );
    });

    testWidgets("qo'shish va o'chirish", (tester) async {
      await pumpWallet(tester, db, path: '/wallet/goals');
      await tester.tap(find.text('Rahmat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Maqsad qo'shish"));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Nomi'), 'Noutbuk');
      await tester.enterText(
        find.widgetWithText(TextField, 'Kerakli summa'),
        '15000000',
      );
      await tester.tap(find.text('Saqlash'));
      await tester.pumpAndSettle();
      expect(find.text('Noutbuk'), findsOneWidget);

      await tester.tap(find.text('Noutbuk'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip("O'chirish"));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, "O'chirish"));
      await tester.pumpAndSettle();
      expect(find.text('Noutbuk'), findsNothing);
    });
  });

  group('📊 limitlar', () {
    testWidgets("oshgan limit — 150%; owner o'zgartiradi", (tester) async {
      await pumpWallet(tester, db, path: '/wallet/limits');
      expect(find.text('150%'), findsOneWidget);
      expect(find.text("Limit yo'q"), findsWidgets);

      await tester.tap(find.text('Kredit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '2000000');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
      await tester.pumpAndSettle();
      // Kredit: 1 000 000 / 2 000 000.
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets("member — faqat ko'rish", (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 6000)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final router = await pumpApp(
        tester,
        database: db,
        startup: switch (AppBootstrap.fromJson(
          bootstrapJson(
            households: [householdJson(id: 'h1', role: 'member')],
          ),
        )) {
          final boot => StartupReady(boot.households.first, boot),
        },
      );
      router.go('/wallet/limits');
      await tester.pumpAndSettle();
      expect(
        find.text("Limitlarni faqat ega yoki admin o'zgartiradi"),
        findsOneWidget,
      );
      await tester.tap(find.text('Kredit'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
