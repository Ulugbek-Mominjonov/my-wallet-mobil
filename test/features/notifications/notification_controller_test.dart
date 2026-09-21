import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/notifications/push_service.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/notifications/application/notification_controller.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';

import '../../data/sync/fake_remote.dart';
import '../../support/fake_notifier.dart';
import '../../support/pump_app.dart';

void main() {
  test("push turi → oq ro'yxatdagi marshrut; noma'lum — Xulosa", () {
    expect(pushRoute('daily_reminder'), '/payments');
    expect(pushRoute('income_missing'), '/payments');
    expect(pushRoute('limit_alert'), '/wallet/limits');
    expect(pushRoute('monthly_report'), '/');
    expect(pushRoute('https://evil.example'), '/');
    expect(pushRoute(null), '/');
  });

  group('E19-T01: push', () {
    late FakePushService push;
    late FakeRemote remote;
    late FakeLocalNotifier notifier;

    setUp(() {
      push = FakePushService();
      remote = FakeRemote();
      notifier = FakeLocalNotifier();
    });

    Future<void> pump(WidgetTester tester) => pumpApp(
      tester,
      notifier: notifier,
      overrides: [
        pushServiceProvider.overrideWithValue(push),
        remoteApiProvider.overrideWithValue(remote),
        syncSchedulerProvider.overrideWith((ref) async => null),
        appVersionProvider.overrideWith((ref) async => '1.0.0'),
      ],
    );

    testWidgets("token ro'yxatdan o'tadi va yangilanganda qayta", (
      tester,
    ) async {
      await pump(tester);
      expect(remote.devices, ['token-1']);
      push.refreshes.add('token-2');
      await tester.pumpAndSettle();
      expect(remote.devices, ['token-1', 'token-2']);
    });

    testWidgets('bosilgan push — tegishli ekran', (tester) async {
      await pump(tester);
      push.opened.add((type: 'limit_alert', title: null, body: null));
      await tester.pumpAndSettle();
      expect(find.text('📊 Limitlar'), findsOneWidget);
    });

    testWidgets('ochiq paytdagi push — lokal bildirishnoma, bosilsa ekran', (
      tester,
    ) async {
      await pump(tester);
      push.foreground.add((
        type: 'daily_reminder',
        title: "Bugun to'lov",
        body: 'Ijara',
      ));
      await tester.pumpAndSettle();
      expect(notifier.shown.single.title, "Bugun to'lov");
      expect(notifier.shown.single.payload, '/payments');

      notifier.tap('/payments');
      await tester.pumpAndSettle();
      expect(find.text('Xarajatlar'), findsOneWidget);
    });

    testWidgets("oq ro'yxatda yo'q marshrut — e'tiborsiz", (tester) async {
      final router = await pumpApp(tester, notifier: notifier);
      notifier.tap('/sign-in');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/');
    });
  });
}
