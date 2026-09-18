import 'package:meta/meta.dart';

/// Ilova muhiti (flavor) — DEPLOY.md 3-bo'lim.
enum AppEnv { dev, staging, prod }

/// Build paytida `--dart-define-from-file=env/<flavor>.json` bilan
/// kiritiladigan sozlamalar. Bu yerda faqat ochiq qiymatlar (publishable
/// kalit) — sir hech qachon ilovaga tushmaydi.
@immutable
final class AppConfig {
  const new({
    required this.env,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.googleWebClientId,
    required this.authRedirect,
    required this.telegramBotUsername,
  });

  /// Qiymatlarni o'qiydi va tekshiradi. Noto'g'ri env fayl bilan ishga
  /// tushirilgan build darhol aniq xato beradi (prod'da staging backend
  /// bo'lib qolmasin).
  factory fromEnvironment({required AppEnv expected}) {
    const envName = String.fromEnvironment('APP_ENV');
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    final env = AppEnv.values.asNameMap()[envName];
    if (env != expected) {
      throw StateError(
        "APP_ENV='$envName', kutilgan '${expected.name}'. "
        'Build: --dart-define-from-file=env/${expected.name}.json',
      );
    }
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL va SUPABASE_PUBLISHABLE_KEY kerak '
        '(env/${expected.name}.json — namuna: env/${expected.name}.example.json)',
      );
    }

    return AppConfig(
      env: env!,
      supabaseUrl: supabaseUrl,
      supabasePublishableKey: supabaseKey,
      googleWebClientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
      authRedirect: const String.fromEnvironment('AUTH_REDIRECT'),
      telegramBotUsername: const String.fromEnvironment(
        'TELEGRAM_BOT_USERNAME',
      ),
    );
  }

  final AppEnv env;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String googleWebClientId;
  final String authRedirect;
  final String telegramBotUsername;
}
