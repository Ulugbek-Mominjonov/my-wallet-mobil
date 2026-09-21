import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../data/sync/fake_remote.dart';
import '../../support/pump_app.dart';
import '../../support/test_database.dart';
import 'payments_harness.dart';

void main() {
  late AppDatabase db;
  late FakeRemote remote;

  setUp(() {
    db = testDatabase();
    remote = FakeRemote();
  });
  tearDown(() => db.close());

  Future<void> open(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1080, 6000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = await pumpApp(
      tester,
      database: db,
      overrides: [
        clockProvider.overrideWithValue(
          TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 10, 4)),
        ),
        remoteApiProvider.overrideWithValue(remote),
        syncSchedulerProvider.overrideWith((ref) async => null),
      ],
    );
    router.go('/payments');
    await tester.pumpAndSettle();
  }

  Future<PlannedItemRow> row(String id) =>
      (db.select(db.plannedItems)..where((p) => p.id.equals(id))).getSingle();

  Finder tileButton(String planId, String label) => find.descendant(
    of: find.byKey(ValueKey(planId)),
    matching: find.widgetWithText(TextButton, label),
  );

  Future<void> menu(WidgetTester tester, String planId, String item) async {
    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey(planId)),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  testWidgets("bo'limlar va sarlavha jami (BR-071, BR-076)", (tester) async {
    await seedPayments(db);
    await open(tester);
    expect(find.text('⚠️ Kechikkan (1)'), findsOneWidget);
    expect(find.text('📌 Bugun (1)'), findsOneWidget);
    expect(find.text('🗓 Yaqin 3 kunda (1)'), findsOneWidget);
    expect(find.text('Keyinroq (1)'), findsOneWidget);
    expect(find.text("✅ To'langan (1)"), findsOneWidget);
    expect(find.text("⏭ O'tkazilgan (1)"), findsOneWidget);
    // 3 000 000 + 100 000 + 500 000; "Elektr" — summasi noma'lum.
    expect(find.text("3 600 000 so'm"), findsOneWidget);
    expect(find.text('+ 1 ta ?'), findsOneWidget);
    expect(find.text("? · Summa o'zgaruvchi"), findsOneWidget);
    expect(find.byIcon(Icons.autorenew), findsOneWidget);
    // Daromad rejasi — alohida tabda.
    expect(find.text('Oylik'), findsNothing);
  });

  testWidgets("qisman to'lov — qolganini keyin (BR-073)", (tester) async {
    await seedPayments(db);
    await open(tester);
    await tester.tap(tileButton('Kurs', "To'landi"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '200000');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, "To'landi"));
    await tester.pumpAndSettle();
    expect(
      find.text("Qolgan 300 000 so'm ni keyin to'laysizmi?"),
      findsOneWidget,
    );
    await tester.tap(find.text("Keyin to'layman"));
    await tester.pumpAndSettle();

    final kurs = await row('Kurs');
    expect(kurs.paidAmount, 20000000);
    expect(kurs.settledAt, isNull);
    final tx = await db.select(db.transactions).getSingle();
    expect(tx.plannedItemId, 'Kurs');
    expect(tx.amount, 20000000);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets("qisman to'lov — yopish; qayta ochish", (tester) async {
    await seedPayments(db);
    await open(tester);
    await tester.tap(tileButton('Kurs', "To'landi"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '200000');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, "To'landi"));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Yopish'));
    await tester.pumpAndSettle();
    final kurs = await row('Kurs');
    expect(kurs.closedAt, isNotNull);
    expect(kurs.settledAt, isNotNull);
    expect(find.text("✅ To'langan (2)"), findsOneWidget);

    await tester.tap(find.text("✅ To'langan (2)"));
    await tester.pumpAndSettle();
    await menu(tester, 'Kurs', 'Qayta ochish');
    final reopened = await row('Kurs');
    expect(reopened.closedAt, isNull);
    expect(reopened.settledAt, isNull);
    expect(find.text("✅ To'langan (1)"), findsOneWidget);
  });

  testWidgets("summasi noma'lum — summa majburiy", (tester) async {
    await seedPayments(db);
    await open(tester);
    await tester.tap(tileButton('Elektr', "To'landi"));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Bu to'lovning summasi belgilanmagan — qancha to'laganingizni "
        'kiriting',
      ),
      findsOneWidget,
    );
    final pay = find.widgetWithText(FilledButton, "To'landi");
    expect(tester.widget<FilledButton>(pay).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '350000');
    await tester.pumpAndSettle();
    await tester.tap(pay);
    await tester.pumpAndSettle();
    final elektr = await row('Elektr');
    expect(elektr.paidAmount, 35000000);
    expect(elektr.settledAt, isNotNull);
  });

  testWidgets("swipe — qolgan summa bilan to'liq to'lash", (tester) async {
    await seedPayments(db);
    await open(tester);
    await tester.drag(find.text('Ijara'), const Offset(500, 0));
    await tester.pumpAndSettle();
    final ijara = await row('Ijara');
    expect(ijara.paidAmount, 300000000);
    expect(ijara.settledAt, isNotNull);
    expect(find.text('Saqlandi'), findsOneWidget);
  });

  testWidgets("o'tkazib yuborish va bekor qilish", (tester) async {
    await seedPayments(db);
    await open(tester);
    await menu(tester, 'Kurs', "O'tkazib yuborish");
    expect((await row('Kurs')).skippedAt, isNotNull);
    expect(find.text("⏭ O'tkazilgan (2)"), findsOneWidget);

    await tester.tap(find.text('Bekor qilish'));
    await tester.pumpAndSettle();
    expect((await row('Kurs')).skippedAt, isNull);
  });

  testWidgets("shu oy summasini o'zgartirish (BR-083)", (tester) async {
    await seedPayments(db);
    await open(tester);
    await menu(tester, 'Kurs', 'Shu oy summasi');
    await tester.enterText(find.byType(TextField), '650000');
    await tester.tap(find.text('Saqlash'));
    await tester.pumpAndSettle();
    expect((await row('Kurs')).plannedAmount, 65000000);
    // Sarlavha: 3 000 000 + 100 000 + 650 000.
    expect(find.text("3 750 000 so'm"), findsOneWidget);
  });

  testWidgets('kutilayotgan daromad — "Keldi"', (tester) async {
    await seedPayments(db);
    await open(tester);
    await tester.tap(find.text('Kutilayotgan daromadlar'));
    await tester.pumpAndSettle();
    expect(find.text("10 000 000 so'm"), findsWidgets);
    await tester.tap(find.widgetWithText(TextButton, 'Keldi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Keldi'));
    await tester.pumpAndSettle();
    final tx = await db.select(db.transactions).getSingle();
    expect(tx.kind, TransactionKind.income.wire);
    expect(tx.budgetMonth, '2026-10-01');
    expect(find.text('✅ Kelgan (1)'), findsOneWidget);
  });

  testWidgets('kalendar: kunda nuqtalar, kun bosilsa — shu kun rejalari', (
    tester,
  ) async {
    await seedPayments(db);
    await open(tester);
    await tester.tap(find.byTooltip('Kalendar'));
    await tester.pumpAndSettle();
    // Standart — bugun (10-oktabr): "Internet".
    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Kurs'), findsNothing);
    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    expect(find.text('Kurs'), findsOneWidget);
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    expect(find.text("Bu kunda to'lov yo'q"), findsOneWidget);
  });

  testWidgets('oyni ochish: preview → tasdiq → server (BR-081)', (
    tester,
  ) async {
    await seedPayments(db, opened: false);
    remote.preview = Ok(
      OpenMonthPreview.fromJson(const {
        'month': '2026-10-01',
        'closed': false,
        'items': [
          {
            'kind': 'expense',
            'name': 'Suv',
            'planned_amount': 5000000,
            'due_date': '2026-10-15',
            'exists': false,
          },
          {
            'kind': 'expense',
            'name': 'Ijara',
            'planned_amount': 300000000,
            'due_date': '2026-10-05',
            'exists': true,
          },
        ],
      }),
    );
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Oyni ochish'));
    await tester.pumpAndSettle();
    expect(find.text('Yaratiladi: 1 ta'), findsOneWidget);
    expect(find.text('Allaqachon bor: 1 ta'), findsOneWidget);
    expect(find.text('Suv'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Oyni ochish').last);
    await tester.pumpAndSettle();
    expect(remote.openedMonths, [MonthKey(2026, 10)]);
  });

  testWidgets('oyni ochish oflayn — tushunarli xabar', (tester) async {
    await seedPayments(db, opened: false);
    remote.preview = const Err(OfflineFailure());
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Oyni ochish'));
    await tester.pumpAndSettle();
    expect(find.text("Internet yo'q — ulanishni tekshiring"), findsOneWidget);
    expect(remote.openedMonths, isEmpty);
  });
}
