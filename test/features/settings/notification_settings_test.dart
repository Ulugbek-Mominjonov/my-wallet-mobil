import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/data/remote/settings_api.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_settings_api.dart';
import '../../support/pump_app.dart';

void main() {
  late FakeSettingsApi api;
  setUp(() => api = FakeSettingsApi());

  Future<void> open(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1080, 4000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = await pumpApp(
      tester,
      overrides: [settingsApiProvider.overrideWithValue(api)],
    );
    router.go(notificationSettingsPath);
    await tester.pumpAndSettle();
  }

  testWidgets("E19-T03: o'zgarish darhol saqlanadi; soat — lokal kesh", (
    tester,
  ) async {
    await open(tester);
    expect(find.text('09:00'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(SwitchListTile, 'Push-bildirishnomalar'),
    );
    await tester.pumpAndSettle();
    expect(api.saved.single.push, isFalse);

    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('07:00').last);
    await tester.pumpAndSettle();
    expect(api.saved.last.reminderHour, 7);
    expect(find.text('07:00'), findsOneWidget);
  });

  testWidgets('server rad etsa — oldingi qiymat qaytadi va xabar', (
    tester,
  ) async {
    api.saveResult = const Err(OfflineFailure());
    await open(tester);
    final push = find.widgetWithText(SwitchListTile, 'Push-bildirishnomalar');
    await tester.tap(push);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(push).value, isTrue);
    expect(find.text("Internet yo'q — ulanishni tekshiring"), findsOneWidget);
  });

  testWidgets('oflayn — qayta urinish', (tester) async {
    api.prefs = const Err(OfflineFailure());
    await open(tester);
    expect(find.text('Sozlamalar uchun internet kerak'), findsOneWidget);
    api.prefs = const Ok(NotificationPrefs(reminderHour: 20));
    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();
    expect(find.text('20:00'), findsOneWidget);
  });

  testWidgets('sinov xabari — kanal natijalari', (tester) async {
    api.testResult = const Ok([
      (channel: 'push', queued: true, reason: null),
      (channel: 'telegram', queued: false, reason: 'not_linked'),
    ]);
    await open(tester);
    await tester.tap(find.text('Sinov xabari yuborish'));
    await tester.pumpAndSettle();
    expect(find.text('✅ push: yuborildi'), findsOneWidget);
    expect(find.text('— telegram: ulanmagan'), findsOneWidget);
  });

  testWidgets('Telegram ulangan — uzish', (tester) async {
    api.linked = true;
    await open(tester);
    expect(find.text('Ulangan'), findsOneWidget);
    await tester.tap(find.text('Uzish'));
    await tester.pumpAndSettle();
    expect(api.unlinkCalls, 1);
    expect(find.text('Ulanmagan'), findsOneWidget);
  });
}
