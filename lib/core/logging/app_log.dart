import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Xatolarni tashqi xizmatga yuboruvchi (release'da Crashlytics — E20).
abstract interface class ErrorReporter {
  Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    required bool fatal,
  });
}

/// Ilovadagi YAGONA log nuqtasi. Debug'da konsolga, release'da ulangan
/// reporter'ga. Xato hech qachon jimgina yutilmaydi (CONTRIBUTING 2-bo'lim).
abstract final class AppLog {
  static ErrorReporter? _reporter;

  // ignore: avoid_setters_without_getters — reporter faqat ulanadi, o'qilmaydi.
  static set reporter(ErrorReporter reporter) => _reporter = reporter;

  static void info(String message) {
    if (kDebugMode) developer.log(message, name: 'my_wallet');
  }

  static void error(
    String reason,
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) {
    if (kDebugMode) {
      developer.log(
        reason,
        name: 'my_wallet',
        error: error,
        stackTrace: stackTrace,
        level: fatal ? 1200 : 1000,
      );
    }
    final reporter = _reporter;
    if (reporter != null) {
      // Reporter xatosi ilovani yiqitmasin, lekin yo'qolmasin ham.
      unawaited(
        reporter
            .record(error, stackTrace, reason: reason, fatal: fatal)
            .catchError((Object reportError, StackTrace reportStack) {
              developer.log(
                'ErrorReporter ishlamadi',
                name: 'my_wallet',
                error: reportError,
                stackTrace: reportStack,
              );
            }),
      );
    }
  }
}
