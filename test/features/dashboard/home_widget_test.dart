import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/security/privacy_mode.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';

import '../../support/test_database.dart';
import 'dashboard_harness.dart';

/// E33-T01, T03: bosh ekran vidjeti va tez amal havolalari.
void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('vidjetga oy qoldig‘i, kuniga va "＋" havolasi yoziladi', (
    tester,
  ) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    final writes = <Map<String, String>>[];
    await pumpDashboard(
      tester,
      db,
      overrides: [],
      homeWidgetWriter: (data) async => writes.add(data),
    );

    expect(writes, isNotEmpty);
    final data = writes.last;
    expect(data['title'], 'Oktabr 2026');
    // 10 000 000 − 2 000 000 = 8 000 000 so'm.
    expect(data['balance'], "8 000 000 so'm".replaceAll(' ', ' '));
    expect(data['per_day'], startsWith('Kuniga ≈'));
    expect(data['add_uri'], 'mywallet-dev://add?kind=expense');
  });

  testWidgets('BR-212: maxfiylik rejimida summalar yashiriladi', (
    tester,
  ) async {
    await seedMonth(db, income: 1000000000, expense: 200000000);
    final writes = <Map<String, String>>[];
    await pumpDashboard(
      tester,
      db,
      homeWidgetWriter: (data) async => writes.add(data),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(privacyModeProvider.notifier).toggle();
    await tester.pumpAndSettle();

    expect(writes.last['balance'], MoneyText.hiddenValue);
  });

  test('E33-T03: tez amal havolalari — faqat oq ro‘yxatdagilar', () {
    expect(
      parseShortcutRoute('mywallet://add?kind=expense'),
      '/add?kind=expense',
    );
    expect(
      parseShortcutRoute('mywallet-dev://add?kind=income'),
      '/add?kind=income',
    );
    expect(parseShortcutRoute('mywallet://payments'), '/payments');
    // Noma'lum tur va noma'lum host — marshrut emas.
    expect(parseShortcutRoute('mywallet://add?kind=hack'), '/add');
    expect(parseShortcutRoute('mywallet://settings'), isNull);
    expect(parseShortcutRoute('salom'), isNull);
  });

  test('havolalar sxemasi muhitga mos (Android manifesti bilan bir xil)', () {
    expect(addLink(AppEnv.dev), 'mywallet-dev://add?kind=expense');
    expect(addLink(AppEnv.staging), 'mywallet-stg://add?kind=expense');
    expect(addLink(AppEnv.prod), 'mywallet://add?kind=expense');
    expect(inviteLink('ABCD2345', AppEnv.prod), 'mywallet://invite/ABCD2345');
  });
}
