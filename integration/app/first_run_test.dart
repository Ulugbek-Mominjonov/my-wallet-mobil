// E14-T06: yangi foydalanuvchining birinchi ochilishi — haqiqiy lokal
// Supabase bilan: email kodi → byudjet yuklanishi → sozlash ustasi →
// dashboard. Ilovaning o'zi (router, ekranlar, sinxron) ishlaydi.

import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/core/security/secure_screen.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/receipts/receipt_platform.dart';
import 'package:my_wallet/data/receipts/receipt_providers.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';

import '../../test/support/fake_notifier.dart';
import '../support/local_supabase.dart';

final class _NoGoogle implements GoogleIdTokenSource {
  @override
  bool get available => false;

  @override
  Future<GoogleIdToken?> obtain() async => null;
}

final class _NoSecureScreen implements SecureScreen {
  @override
  Future<void> setSecure({required bool enabled}) async {}
}

void main() {
  setUpAll(() {
    requireLocalSupabase();
    // `testWidgets` HTTP so'rovlarini soxtalashtiradi — bu testda tarmoq
    // haqiqiy (lokal Supabase).
    HttpOverrides.global = null;
    // Har test o'z bazasini ochadi (umumiy executor yo'q).
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    // Testda Keystore yo'q (integration/ — test papkasi emas).
    // ignore: invalid_use_of_visible_for_testing_member
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('yangi foydalanuvchi: kirish → sozlash ustasi → dashboard', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uz')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    // O'z HTTP klientimiz: test oxirida yopamiz (ochiq ulanish taymeri
    // `testWidgets` tekshiruvida "pending timer" bo'lib qolmasin).
    final httpClient = IOClient(
      HttpClient()..idleTimeout = const Duration(milliseconds: 1),
    );
    final client = newClient(httpClient: httpClient);
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              env: AppEnv.dev,
              supabaseUrl: supabaseUrl,
              supabasePublishableKey: publishableKey,
              googleWebClientId: '',
              authRedirect: 'mywallet-dev://auth-callback',
              telegramBotUsername: '',
            ),
          ),
          appDatabaseProvider.overrideWithValue(db),
          authGatewayProvider.overrideWithValue(
            SupabaseAuthGateway(client.auth, _NoGoogle()),
          ),
          remoteApiProvider.overrideWithValue(
            RpcRemoteApi(supabaseTransport(client)),
          ),
          secureScreenProvider.overrideWithValue(_NoSecureScreen()),
          receiptStorageProvider.overrideWithValue(
            SupabaseReceiptStorage(client),
          ),
          // Plaginlar host'da yo'q — tarmoq bor deb hisoblaymiz.
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
          inviteLinksProvider.overrideWith(
            (ref) => const Stream<String>.empty(),
          ),
          // Versiya tekshiruvi (BR-214) — plagin host'da yo'q.
          appVersionProvider.overrideWith((ref) async => '9.9.9'),
          // Bildirishnomalar plagini host'da yo'q (E19).
          localNotifierProvider.overrideWithValue(FakeLocalNotifier()),
        ],
        child: const MyWalletApp(),
      ),
    );
    await _settle(tester);

    // 1. Kirish: email → xatdagi kod.
    final email = uniqueEmail();
    expect(find.text('Kod olish'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
    await tester.tap(find.text('Kod olish'));
    await _until(tester, find.widgetWithText(TextField, 'Kod'));

    final text = await tester.runAsync(() => lastEmailText(email));
    final code = RegExp('\\b\\d{$emailCodeLength}\\b')
        .firstMatch(text!)!
        .group(0)!;
    await tester.enterText(find.widgetWithText(TextField, 'Kod'), code);

    // 2. Sozlash ustasi: spravochniklar sinxrondan keladi.
    await _until(tester, find.text('Hisoblar va qoldiq'));
    await _until(tester, find.widgetWithText(TextField, 'Naqd'));

    await tester.enterText(find.widgetWithText(TextField, 'Naqd'), '1500000');
    await _settle(tester);
    await tester.tap(find.text('Davom etish'));
    await _settle(tester);

    // Maosh jadvali: birinchi daromad turini yoqamiz.
    await _until(tester, find.text('Maosh jadvali'));
    await tester.tap(find.byType(Switch).first);
    await _settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Summa').first,
      '8000000',
    );
    await _settle(tester);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Davom etish'));
      await _settle(tester);
    }
    await _until(tester, find.text('Tayyor!'));

    // 3. Yakun: onboarding_apply + joriy oy → dashboard.
    await tester.tap(find.text('Boshlash'));
    await _until(tester, find.byType(BottomAppBar));

    expect(find.text('Xulosa'), findsWidgets);

    // Spravochniklar sinxrondan keladi — sekin CI'da dashboard'dan keyin.
    await _untilTrue(
      tester,
      () async => (await db.select(db.accounts).get()).isNotEmpty,
      reason: 'spravochniklar sinxrondan keldi',
    );
    // Ochilgan oy rejalari serverda — `integration/onboarding` tekshiradi.

    httpClient.close();
    // Daraxtni yig'ishtiramiz: drift oqimlari yopilishini kutadi.
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.runAsync(db.close);
  });
}

/// Bir necha kadr chizadi (`pumpAndSettle` sinxron taymerlari bilan osiladi).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await _tick(tester);
  }
}

/// Haqiqiy vaqt o'tkazadi (tarmoq javobi `runAsync` ichida keladi) va
/// keyin kadr chizadi.
Future<void> _tick(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pump();
}

/// Shart bajarilguncha kutadi (masalan sinxron natijasi lokal bazada).
Future<void> _untilTrue(
  WidgetTester tester,
  Future<bool> Function() check, {
  required String reason,
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await tester.runAsync(check) ?? false) return;
    await _tick(tester);
  }
  fail('shart bajarilmadi: $reason');
}

/// Element chiqquncha kutadi (tarmoq — haqiqiy).
Future<void> _until(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await _tick(tester);
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('kutilgan element chiqmadi: $finder');
}
