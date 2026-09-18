import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/logging/app_log.dart';

/// Barcha flavor'lar uchun yagona ishga tushirish nuqtasi.
///
/// Xatolar ikki joydan ushlanadi: Flutter freymvorki (`FlutterError.onError`)
/// va qolgan hamma asinxron xatolar (`PlatformDispatcher.onError`) —
/// zamonaviy Flutter tavsiyasi, `runZonedGuarded` kerak emas.
void bootstrap({required AppEnv env}) {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLog.error(
      'Flutter xatosi',
      details.exception,
      details.stack ?? StackTrace.current,
      fatal: true,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLog.error('Ushlanmagan xato', error, stackTrace, fatal: true);
    return true;
  };

  final config = AppConfig.fromEnvironment(expected: env);
  AppLog.info('My Wallet ishga tushdi: ${config.env.name}');

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      observers: const [AppProviderObserver()],
      child: const MyWalletApp(),
    ),
  );
}
