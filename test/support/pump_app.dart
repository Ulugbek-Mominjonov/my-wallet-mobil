import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/core/settings/app_settings.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';
import 'package:my_wallet/features/notifications/application/local_reminders.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth.dart';
import 'fake_notifier.dart';
import 'fake_startup.dart';
import 'test_database.dart';

AppConfig testConfig({AppEnv env = AppEnv.dev}) => AppConfig(
  env: env,
  supabaseUrl: 'http://127.0.0.1:54321',
  supabasePublishableKey: 'test-key',
  googleWebClientId: '',
  authRedirect: 'mywallet-dev://auth-callback',
  telegramBotUsername: '',
);

/// Butun ilovani o'zbek tilida, test konfiguratsiyasi bilan chizadi.
/// Standart — kirilgan foydalanuvchi ([auth] bilan boshqariladi).
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  AppEnv env = AppEnv.dev,
  FakeAuthGateway? auth,
  StartupState? startup,
  FakeStartupController? startupController,
  Stream<String>? inviteLinks,

  /// Cheksiz animatsiya (yuklanish indikatori) bo'lsa — `false`.
  bool settle = true,
  List<Override> overrides = const [],

  /// Lokal baza (standart — bo'sh xotiradagi baza).
  AppDatabase? database,

  /// Qurilma bildirishnomalari (standart — yozib boruvchi soxta).
  FakeLocalNotifier? notifier,

  /// Saqlangan ilova sozlamalari (tema, til).
  Map<String, Object> preferences = const {},

  /// Lokal eslatmalar rejalashtiruvchisi (E19-T02) — debounce taymeri
  /// boshqa testlarda "pending timer" bo'lmasin, standart o'chiq.
  bool localReminders = false,
}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('uz')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  // Cheksiz animatsiyalar (skeleton) pumpAndSettle'ni to'xtatmasin —
  // vidjetlar "animatsiyalarni kamaytirish" sozlamasini hurmat qiladi.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  // Keystore yo'q — ilova qulfi (PIN) xotiradagi soxta xotiradan o'qiydi.
  FlutterSecureStorage.setMockInitialValues({});
  // Tema/til sozlamalari — xotirada (E19-T04).
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  final db = database ?? testDatabase();
  if (database == null) addTearDown(db.close);
  final container = ProviderContainer.test(
    overrides: [
      appConfigProvider.overrideWithValue(testConfig(env: env)),
      authGatewayProvider.overrideWithValue(
        auth ?? FakeAuthGateway(currentUserId: 'user-1'),
      ),
      startupProvider.overrideWith(
        () =>
            startupController ?? FakeStartupController(startup ?? readyState()),
      ),
      inviteLinksProvider.overrideWith(
        (ref) => inviteLinks ?? const Stream<String>.empty(),
      ),
      // Lokal baza — xotirada (testda haqiqiy fayl ochilmaydi).
      appDatabaseProvider.overrideWithValue(db),
      localNotifierProvider.overrideWithValue(notifier ?? FakeLocalNotifier()),
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (!localReminders) localRemindersProvider.overrideWith((ref) {}),
      ...overrides,
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyWalletApp()),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  final router = container.read(routerProvider);
  return router;
}
