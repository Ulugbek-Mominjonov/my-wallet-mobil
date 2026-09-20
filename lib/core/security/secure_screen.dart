import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/logging/app_log.dart';

/// BR-211: ilova almashtirgichda ekran ko'rinmasin (Android `FLAG_SECURE`).
abstract interface class SecureScreen {
  Future<void> setSecure({required bool enabled});
}

final secureScreenProvider = Provider<SecureScreen>(
  (ref) => const PlatformSecureScreen(),
);

final class PlatformSecureScreen implements SecureScreen {
  const new();

  static const channel = MethodChannel('uz.mywallet.app/secure_screen');

  @override
  Future<void> setSecure({required bool enabled}) async {
    try {
      await channel.invokeMethod<void>('setSecure', enabled);
    } on MissingPluginException {
      // Android'dan boshqa platforma (yoki test) — bayroq yo'q.
    } on PlatformException catch (error, stackTrace) {
      AppLog.error('FLAG_SECURE', error, stackTrace);
    }
  }
}
