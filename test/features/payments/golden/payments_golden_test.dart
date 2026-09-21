@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_database.dart';
import '../payments_harness.dart';

/// E17: "To'lovlar" — ro'yxat (light) va kalendar (dark), Pixel o'lchami
/// (360×780). Yangilash: `flutter test --update-goldens --tags golden`.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = testDatabase();
    await seedPayments(db);
  });
  tearDown(() => db.close());

  Future<void> open(WidgetTester tester, Brightness brightness) async {
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final router = await pumpApp(
      tester,
      database: db,
      overrides: [
        clockProvider.overrideWithValue(
          TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 10, 4)),
        ),
      ],
    );
    router.go('/payments');
    await tester.pumpAndSettle();
  }

  testWidgets("ro'yxat", (tester) async {
    await open(tester, Brightness.light);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/payments_list.png'),
    );
  });

  testWidgets('kalendar (dark)', (tester) async {
    await open(tester, Brightness.dark);
    await tester.tap(find.byTooltip('Kalendar'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/payments_calendar_dark.png'),
    );
  });
}
