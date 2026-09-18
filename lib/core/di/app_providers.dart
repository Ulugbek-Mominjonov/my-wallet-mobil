import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/logging/app_log.dart';

/// Muhit sozlamalari — `bootstrap` override qiladi (testlarda ham shunday).
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider bootstrap da beriladi'),
);

/// Provider xatolarini yagona log nuqtasiga yuboradi.
final class AppProviderObserver extends ProviderObserver {
  const new();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    AppLog.error('Provider xatosi: ${context.provider}', error, stackTrace);
  }
}
