import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/notifications/push_service.dart';
import 'package:my_wallet/data/auth/secure_session_storage.dart';
import 'package:my_wallet/data/sync/background_worker.dart';

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

  final config = AppConfig.fromEnvironment(expected: env);
  AppLog.info('My Wallet ishga tushdi: ${config.env.name}');

  // Sessiya shifrlangan xotirada saqlanadi va shu yerda tiklanadi.
  await initSupabase(config);
  if (Platform.isAndroid) await registerBackgroundSync();
  final firebaseReady = await _initFirebase(config.firebase);

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        firebaseReadyProvider.overrideWithValue(firebaseReady),
      ],
      observers: const [AppProviderObserver()],
      child: const MyWalletApp(),
    ),
  );
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
