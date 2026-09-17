import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Yagona log nuqtasi.
///
/// `print` ishlatilmaydi: relizda ham chiqib ketadi va formatlanmagan
/// bo'ladi. Keyinchalik Sentry shu yerdan ulanadi — ekranlarda hech narsa
/// o'zgarmaydi.
abstract final class AppLog {
  static void info(String message) {
    if (kDebugMode) developer.log(message, name: 'byudjet');
  }

  static void error(String message, Object error, StackTrace stackTrace) {
    developer.log(
      message,
      name: 'byudjet',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
