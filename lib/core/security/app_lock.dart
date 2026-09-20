import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/security/pin_store.dart';
import 'package:my_wallet/core/security/secure_screen.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';

/// Avto-qulf variantlari (BR-211): fonda shuncha turgach qulflanadi.
const autoLockOptions = [1, 5, 15];

/// Ilova qulfi sozlamalari (`app_settings` — qurilmada qoladi).
@immutable
final class LockSettings {
  const new({
    this.pinSet = false,
    this.biometrics = false,
    this.minutes = 5,
    this.secureScreen = true,
  });

  final bool pinSet;
  final bool biometrics;
  final int minutes;

  /// BR-211: ilova almashtirgichda ekran yashiriladi.
  final bool secureScreen;

  LockSettings copyWith({
    bool? pinSet,
    bool? biometrics,
    int? minutes,
    bool? secureScreen,
  }) => LockSettings(
    pinSet: pinSet ?? this.pinSet,
    biometrics: biometrics ?? this.biometrics,
    minutes: minutes ?? this.minutes,
    secureScreen: secureScreen ?? this.secureScreen,
  );
}

@immutable
final class LockState {
  const new({required this.settings, this.locked = false, this.attempts = 0});

  final LockSettings settings;

  /// Qulf ekrani ko'rsatilmoqda.
  final bool locked;

  /// Noto'g'ri PIN urinishlari (ketma-ket).
  final int attempts;

  LockState copyWith({LockSettings? settings, bool? locked, int? attempts}) =>
      LockState(
        settings: settings ?? this.settings,
        locked: locked ?? this.locked,
        attempts: attempts ?? this.attempts,
      );
}

final pinStoreProvider = Provider<PinStore>(
  (ref) => const PinStore(FlutterSecureStorage()),
);

/// Biometrika (test uchun almashtiriladi).
final localAuthProvider = Provider<LocalAuthentication>(
  (ref) => LocalAuthentication(),
);

final NotifierProvider<AppLock, LockState> appLockProvider = NotifierProvider(
  AppLock.new,
);

/// Ilova qulfi (BR-211): PIN, biometrika va fonda turgach avto-qulf.
base class AppLock extends Notifier<LockState> {
  static const biometricsKey = 'lock_biometrics';
  static const minutesKey = 'lock_minutes';
  static const secureScreenKey = 'lock_secure_screen';

  DateTime? _pausedAt;
  DateTime Function() _now = DateTime.now;

  /// Saqlangan sozlamalar o'qilishi; barcha amallar shuni kutadi — aks holda
  /// kech tugagan o'qish foydalanuvchi o'zgartirgan holatni bosib ketardi.
  late final Future<void> _ready = _restore();

  @override
  LockState build() {
    unawaited(_ready);
    final listener = AppLifecycleListener(
      onPause: _onPause,
      onResume: _onResume,
    );
    ref.onDispose(listener.dispose);
    return const LockState(settings: LockSettings());
  }

  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// Testlarda vaqtni boshqarish uchun.
  @visibleForTesting
  // ignore: use_setters_to_change_properties — faqat testdan beriladi.
  void useClock(DateTime Function() now) => _now = now;

  Future<void> _restore() async {
    final pinSet = await ref.read(pinStoreProvider).isSet;
    final settings = LockSettings(
      pinSet: pinSet,
      biometrics: await _db.setting(biometricsKey) == 'true',
      minutes:
          int.tryParse(await _db.setting(minutesKey) ?? '') ??
          const LockSettings().minutes,
      secureScreen: await _db.setting(secureScreenKey) != 'false',
    );
    // PIN o'rnatilgan bo'lsa — ilova qulflangan holda ochiladi.
    state = LockState(settings: settings, locked: pinSet);
    await ref
        .read(secureScreenProvider)
        .setSecure(enabled: settings.secureScreen);
  }

  void _onPause() => _pausedAt = _now();

  void _onResume() {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (!state.settings.pinSet || state.locked || pausedAt == null) return;
    final away = _now().difference(pausedAt);
    if (away >= Duration(minutes: state.settings.minutes)) lock();
  }

  void lock() => state = state.copyWith(locked: true, attempts: 0);

  /// PIN o'rnatish yoki o'zgartirish (qulf shu zahoti yoqiladi).
  Future<void> setPin(String pin) async {
    await _ready;
    await ref.read(pinStoreProvider).setPin(pin);
    state = state.copyWith(
      settings: state.settings.copyWith(pinSet: true),
      locked: false,
      attempts: 0,
    );
  }

  /// Qulfni o'chirish: PIN va biometrika o'chadi.
  Future<void> disable() async {
    await _ready;
    await ref.read(pinStoreProvider).clear();
    await _db.setSetting(biometricsKey, 'false');
    state = LockState(
      settings: state.settings.copyWith(pinSet: false, biometrics: false),
    );
  }

  Future<bool> unlockWithPin(String pin) async {
    await _ready;
    final ok = await ref.read(pinStoreProvider).verify(pin);
    state = ok
        ? state.copyWith(locked: false, attempts: 0)
        : state.copyWith(attempts: state.attempts + 1);
    return ok;
  }

  /// Biometrika; qurilmada yo'q yoki bekor qilinsa — `false` (PIN qoladi).
  Future<bool> unlockWithBiometrics() async {
    await _ready;
    if (!state.settings.biometrics) return false;
    try {
      final auth = ref.read(localAuthProvider);
      final ok = await auth.authenticate(
        localizedReason: 'My Wallet',
        persistAcrossBackgrounding: true,
      );
      if (ok) state = state.copyWith(locked: false, attempts: 0);
      return ok;
    } on Object catch (error, stackTrace) {
      AppLog.error('Biometrika', error, stackTrace);
      return false;
    }
  }

  Future<void> setBiometrics({required bool enabled}) async {
    await _ready;
    await _db.setSetting(biometricsKey, '$enabled');
    state = state.copyWith(
      settings: state.settings.copyWith(biometrics: enabled),
    );
  }

  Future<void> setMinutes(int minutes) async {
    await _ready;
    await _db.setSetting(minutesKey, '$minutes');
    state = state.copyWith(settings: state.settings.copyWith(minutes: minutes));
  }

  Future<void> setSecureScreen({required bool enabled}) async {
    await _ready;
    await _db.setSetting(secureScreenKey, '$enabled');
    await ref.read(secureScreenProvider).setSecure(enabled: enabled);
    state = state.copyWith(
      settings: state.settings.copyWith(secureScreen: enabled),
    );
  }
}
