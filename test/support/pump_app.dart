import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';

import 'fake_auth.dart';

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
}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('uz')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  // Cheksiz animatsiyalar (skeleton) pumpAndSettle'ni to'xtatmasin —
  // vidjetlar "animatsiyalarni kamaytirish" sozlamasini hurmat qiladi.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final container = ProviderContainer.test(
    overrides: [
      appConfigProvider.overrideWithValue(testConfig(env: env)),
      authGatewayProvider.overrideWithValue(
        auth ?? FakeAuthGateway(currentUserId: 'user-1'),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyWalletApp()),
  );
  await tester.pumpAndSettle();
  final router = container.read(routerProvider);
  return router;
}
