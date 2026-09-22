import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:my_wallet/core/logging/app_log.dart';

/// E20: xatolar Firebase Crashlytics'ga (release/profil build, Firebase
/// sozlangan bo'lsa). Xabar — faqat texnik sabab; foydalanuvchi ma'lumoti
/// (summa, nom, email) yuborilmaydi.
final class CrashlyticsReporter implements ErrorReporter {
  const new(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    required bool fatal,
  }) =>
      _crashlytics.recordError(error, stackTrace, reason: reason, fatal: fatal);
}
