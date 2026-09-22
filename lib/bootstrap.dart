import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/logging/crashlytics_reporter.dart';
import 'package:my_wallet/core/notifications/push_service.dart';
import 'package:my_wallet/core/settings/app_settings.dart';
import 'package:my_wallet/data/auth/secure_session_storage.dart';
import 'package:my_wallet/data/sync/background_worker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Barcha flavor'lar uchun yagona ishga tushirish nuqtasi.
///
/// Xatolar ikki joydan ushlanadi: Flutter freymvorki (`FlutterError.onError`)
/// va qolgan hamma asinxron xatolar (`PlatformDispatcher.onError`) —
/// zamonaviy Flutter tavsiyasi, `runZonedGuarded` kerak emas.
Future<void> bootstrap({required AppEnv env}) async {
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

  runApp(
    ProviderScope(
      overrides: await prepareApp(AppConfig.fromEnvironment(expected: env)),
      observers: const [AppProviderObserver()],
      child: const MyWalletApp(),
    ),
  );
  // Sovuq start (E20-T02): fon sinxroni birinchi kadrdan keyin
  // ro'yxatdan o'tadi — ekran tezroq chiqadi.
  if (Platform.isAndroid) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(registerBackgroundSync()),
    );
  }
}

/// Ilova xizmatlarini ishga tushiradi (Supabase sessiyasi, fon sinxroni,
/// Firebase, sozlamalar) va `ProviderScope` uchun override'larni qaytaradi.
/// E2E testlari ham shundan foydalanadi (xato ushlagichlarisiz).
Future<List<Override>> prepareApp(AppConfig config) async {
  AppLog.info('My Wallet ishga tushdi: ${config.env.name}');

  // Mustaqil ishlar parallel (sovuq start, E20-T02): sessiya shifrlangan
  // xotiradan tiklanadi, Firebase va sozlamalar bir vaqtda.
  final (_, firebaseReady, preferences) = await (
    initSupabase(config),
    _initFirebase(config.firebase),
    SharedPreferences.getInstance(),
  ).wait;
  if (firebaseReady && !kDebugMode) {
    AppLog.reporter = CrashlyticsReporter(FirebaseCrashlytics.instance);
  }
  return [
    appConfigProvider.overrideWithValue(config),
    firebaseReadyProvider.overrideWithValue(firebaseReady),
    sharedPreferencesProvider.overrideWithValue(preferences),
  ];
}

/// Push (E19): Firebase faqat sozlangan bo'lsa ishga tushadi; xato bo'lsa —
/// ilova push'siz ishlayveradi (lokal eslatmalar bor).
Future<bool> _initFirebase(FirebaseSettings? settings) async {
  if (settings == null) return false;
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: settings.apiKey,
        appId: settings.appId,
        messagingSenderId: settings.messagingSenderId,
        projectId: settings.projectId,
      ),
    );
    return true;
  } on Object catch (error, stackTrace) {
    AppLog.error('Firebase ishga tushmadi', error, stackTrace);
    return false;
  }
}
