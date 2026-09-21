import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';

import '../features/wallet/wallet_harness.dart';
import '../support/real_fonts.dart';
import '../support/test_database.dart';

/// E20-T03: Android qulaylik qo'llanmalari — bosiladigan joy ≥ 48 dp,
/// har biri nomli (TalkBack o'qiydi), matn kontrasti.
void main() {
  setUpAll(loadRealFonts);

  late AppDatabase db;
  setUp(() async {
    db = testDatabase();
    await seedWallet(db);
  });
  tearDown(() => db.close());

  for (final path in [
    '/',
    '/transactions',
    '/payments',
    '/wallet',
    '/wallet/debts',
    '/wallet/limits',
    '/add',
    '/settings',
  ]) {
    testWidgets("qo'llanmalar: $path", (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpWallet(tester, db, path: path, size: const Size(1080, 2340));
      if (find.text('Rahmat').evaluate().isNotEmpty) {
        await tester.tap(find.text('Rahmat'));
        await tester.pumpAndSettle();
      }
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }
}
