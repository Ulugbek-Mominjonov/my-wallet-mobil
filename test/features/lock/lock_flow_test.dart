import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/core/security/app_lock.dart';
import 'package:my_wallet/core/security/privacy_mode.dart';
import 'package:my_wallet/core/security/secure_screen.dart';

import '../../support/pump_app.dart';

final class _FakeSecureScreen implements SecureScreen {
  final calls = <bool>[];

  @override
  Future<void> setSecure({required bool enabled}) async => calls.add(enabled);
}

void main() {
  late _FakeSecureScreen secureScreen;
  var now = DateTime.utc(2026, 10, 5, 12);

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    secureScreen = _FakeSecureScreen();
    now = DateTime.utc(2026, 10, 5, 12);
  });

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MyWalletApp)));

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.widgetWithText(TextButton, digit));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  /// Ilovani fonga chiqarib, [minutes] daqiqadan keyin qaytaradi.
  Future<void> away(WidgetTester tester, int minutes) async {
    const <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    now = now.add(Duration(minutes: minutes));
    const <AppLifecycleState>[
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();
  }

  testWidgets("PIN o'rnatish → fonda turgach qulf → PIN bilan ochish", (
    tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [secureScreenProvider.overrideWithValue(secureScreen)],
    );
    containerOf(tester).read(appLockProvider.notifier).useClock(() => now);

    // Profil menyusidan ilova qulfi.
    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ilova qulfi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("PIN o'rnatish"));
    await tester.pumpAndSettle();
    await enterPin(tester, '1234');
    expect(find.text('PIN ni takrorlang'), findsOneWidget);
    await enterPin(tester, '4321');
    expect(find.text('PIN mos kelmadi'), findsOneWidget);
    await enterPin(tester, '1234');
    await enterPin(tester, '1234');
    expect(find.text('Avto-qulf'), findsOneWidget);
    expect(find.text("PIN ni o'zgartirish"), findsOneWidget);

    // 1 daqiqa — hali qulflanmaydi (standart 5 daqiqa).
    await away(tester, 1);
    expect(find.text('PIN kodni kiriting'), findsNothing);

    await away(tester, 5);
    expect(find.text('PIN kodni kiriting'), findsOneWidget);

    await enterPin(tester, '0000');
    expect(find.text("PIN noto'g'ri"), findsOneWidget);

    await enterPin(tester, '1234');
    expect(find.text('PIN kodni kiriting'), findsNothing);
    expect(find.widgetWithText(AppBar, 'Uy'), findsOneWidget);
  });

  testWidgets('maxfiylik rejimi — summalar yashiriladi (BR-212)', (
    tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [secureScreenProvider.overrideWithValue(secureScreen)],
    );
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(containerOf(tester).read(privacyModeProvider), isTrue);
  });
}
