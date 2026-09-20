import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../data/sync/fake_remote.dart';
import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';

void main() {
  late AppDatabase db;
  late FakeRemote remote;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemote();
    await db.batch((batch) {
      batch
        ..insertAll(db.accounts, [
          const Account(
            id: 'a1',
            householdId: 'h1',
            name: 'Naqd',
            type: AccountType.cash,
            openingBalance: Money.zero,
            sortOrder: 1,
            rowVersion: 1,
          ).toCompanion(),
        ])
        ..insertAll(db.categories, [
          const Category(
            id: 'c1',
            householdId: 'h1',
            kind: CategoryKind.income,
            name: 'Oylik',
            monthShift: -1,
          ).toCompanion(),
          const Category(
            id: 'c2',
            householdId: 'h1',
            kind: CategoryKind.expense,
            name: 'Ijara',
          ).toCompanion(),
        ]);
    });
  });
  tearDown(() => db.close());

  Future<void> openWizard(WidgetTester tester) async {
    await pumpApp(
      tester,
      startup: readyState(onboarded: false),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        remoteApiProvider.overrideWithValue(remote),
        syncSchedulerProvider.overrideWith((ref) async => null),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sozlash tugamagan — usta ochiladi va qadamlar aylanadi', (
    tester,
  ) async {
    await openWizard(tester);
    expect(find.text('Hisoblar va qoldiq'), findsOneWidget);
    expect(find.text('1/5-qadam'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Naqd'), '1500000');
    await tester.pumpAndSettle();
    // Minglar NBSP bilan (formatMoney — admin bilan bir xil).
    expect(find.text("1\u00a0500\u00a0000\u00a0so'm"), findsOneWidget);

    await tester.tap(find.text('Davom etish'));
    await tester.pumpAndSettle();
    expect(find.text('Maosh jadvali'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(find.text('Shu oy'), findsOneWidget);
    expect(find.text('Oldingi oy'), findsOneWidget);

    await tester.tap(find.text("O'tkazib yuborish"));
    await tester.pumpAndSettle();
    expect(find.text("Doimiy to'lovlar"), findsOneWidget);
    expect(find.text('Ijara'), findsOneWidget);

    await tester.tap(find.text("O'tkazib yuborish"));
    await tester.pumpAndSettle();
    expect(find.text('👤 Shaxsiy fond'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '10'), findsOneWidget);

    await tester.tap(find.text('Davom etish'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 ta hisob'), findsOneWidget);

    await tester.tap(find.text('Boshlash'));
    await tester.pumpAndSettle();
    expect((remote.appliedPayload!['accounts']! as List).single, {
      'name': 'Naqd',
      'type': 'cash',
      'opening_balance': 150000000,
    });
    expect(remote.openedMonths, hasLength(1));
  });

  testWidgets('orqaga qaytish va server xatosi', (tester) async {
    remote.applyResult = const Err(RejectedFailure('forbidden'));
    await openWizard(tester);

    await tester.tap(find.text('Davom etish'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Hisoblar va qoldiq'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Davom etish'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Boshlash'));
    await tester.pumpAndSettle();
    expect(find.text("Kutilmagan xato. Qayta urinib ko'ring."), findsOneWidget);
  });
}
