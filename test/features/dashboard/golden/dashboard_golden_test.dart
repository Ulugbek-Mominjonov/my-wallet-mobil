@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/features/dashboard/presentation/share_report_screen.dart';

import '../../../support/test_database.dart';
import '../dashboard_harness.dart';

/// E16-T07: Xulosa — hero (musbat/manfiy/maxfiy), bo'sh oy va ulashish
/// kartasi (Pixel o'lchami, 360×780).
/// Yangilash: `flutter test --update-goldens --tags golden`.
void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  const phone = Size(1080, 2340);

  Future<void> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpDashboard(tester, db, size: phone);
  }

  Future<void> expectGolden(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/dashboard_$name.png'),
  );

  testWidgets('hero — musbat qoldiq', (tester) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    await pump(tester);
    await expectGolden('positive');
  });

  testWidgets('hero — manfiy qoldiq (dark)', (tester) async {
    await seedMonth(db, income: 100000000, expense: 300000000);
    await pump(tester, brightness: Brightness.dark);
    await expectGolden('negative_dark');
  });

  testWidgets('hero — maxfiylik rejimi', (tester) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    await pump(tester);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
    await expectGolden('private');
  });

  testWidgets("bo'sh oy", (tester) async {
    await pump(tester);
    await expectGolden('empty');
  });

  testWidgets('ulashish kartasi', (tester) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    await pumpDashboard(tester, db);
    await tester.tap(find.text('Hisobotni ulashish'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ReportShareCard),
      matchesGoldenFile('goldens/dashboard_share_card.png'),
    );
  });
}
