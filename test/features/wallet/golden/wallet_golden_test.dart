@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';

import '../../../support/test_database.dart';
import '../wallet_harness.dart';

/// E18: Hamyon — umumiy ko'rinish, qarzlar, maqsadlar (dark) va limitlar;
/// Pixel o'lchami (360×780). Yangilash:
/// `flutter test --update-goldens --tags golden`.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = testDatabase();
    await seedWallet(db);
  });
  tearDown(() => db.close());

  const phone = Size(1080, 2340);

  for (final (name, path, brightness) in const [
    ('overview', '/wallet', Brightness.light),
    ('debts', '/wallet/debts', Brightness.light),
    ('goals_dark', '/wallet/goals', Brightness.dark),
    ('limits', '/wallet/limits', Brightness.light),
  ]) {
    testWidgets(name, (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpWallet(tester, db, path: path, size: phone);
      // Maqsadlarda tabrik dialogi — yopiladi.
      if (find.text('Rahmat').evaluate().isNotEmpty) {
        await tester.tap(find.text('Rahmat'));
        await tester.pumpAndSettle();
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet_$name.png'),
      );
    });
  }
}
