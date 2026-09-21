@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_database.dart';

/// E15-T08: "Qo'shish" varag'i — light/dark (Pixel o'lchami, 360×780).
/// Yangilash: `flutter test --update-goldens --tags golden`.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = testDatabase();
    await db.batch((b) {
      b
        ..insertAll(db.accounts, [
          for (final (id, name, type, order) in const [
            ('a1', 'Naqd', AccountType.cash, 1),
            ('a2', 'Karta', AccountType.card, 2),
            ('a3', 'Shaxsiy fond', AccountType.personalFund, 3),
          ])
            Account(
              id: id,
              householdId: 'h1',
              name: name,
              type: type,
              openingBalance: Money.zero,
              sortOrder: order,
              rowVersion: 1,
            ).toCompanion(),
        ])
        ..insertAll(db.categories, [
          for (final (i, name) in const [
            'Oziq-ovqat',
            'Transport',
            'Ijara',
            'Kommunal',
          ].indexed)
            Category(
              id: 'c$i',
              householdId: 'h1',
              kind: CategoryKind.expense,
              name: name,
              sortOrder: i,
            ).toCompanion(),
        ])
        ..insert(
          db.quickActions,
          const QuickAction(
            id: 'q1',
            householdId: 'h1',
            name: 'Taksi',
            amount: Money(2000000),
            categoryId: 'c1',
            accountId: 'a1',
          ).toCompanion(),
        );
    });
  });
  tearDown(() => db.close());

  for (final brightness in Brightness.values) {
    testWidgets("qo'shish varag'i — ${brightness.name}", (tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2340)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await pumpApp(
        tester,
        database: db,
        overrides: [
          clockProvider.overrideWithValue(
            TzClock(
              'Asia/Tashkent',
              utcNow: () => DateTime.utc(2026, 10, 5, 4),
            ),
          ),
        ],
      );
      await tester.tap(find.byTooltip("Amal qo'shish"));
      await tester.pumpAndSettle();
      for (final key in ['4', '5', '000']) {
        await tester.tap(
          find.ancestor(
            of: find.text(key),
            // Raqamlar — TextButton, amallar — FilledButton.tonal.
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          ),
        );
      }
      await tester.tap(find.widgetWithText(ChoiceChip, 'Oziq-ovqat'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/add_sheet_${brightness.name}.png'),
      );
    });
  }
}
