import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/l10n/locale_resolution.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Qurilmadagi ilova sozlamalari (tema, til, eslatma soati keshi) —
/// `bootstrap` ishga tushirishdan oldin yuklaydi (tema miltillamasin).
final Provider<SharedPreferences> sharedPreferencesProvider = Provider(
  (ref) => throw StateError('sharedPreferencesProvider — bootstrap beradi'),
);

/// E19-T04: tema — tizim / och / to'q.
final NotifierProvider<ThemeModeSetting, ThemeMode> themeModeProvider =
    NotifierProvider(ThemeModeSetting.new);

final class ThemeModeSetting extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
  }

  Future<void> select(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

/// E19-T04: tanlangan til; null — qurilma tili (qo'llanmasa — o'zbekcha).
final NotifierProvider<LanguageSetting, Locale?> languageProvider =
    NotifierProvider(LanguageSetting.new);

final class LanguageSetting extends Notifier<Locale?> {
  static const _key = 'language';

  @override
  Locale? build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return appSupportedLocales
        .where((l) => l.languageCode == saved)
        .firstOrNull;
  }

  Future<void> select(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

/// Amaldagi til — widget daraxtidan tashqarida (masalan rejali eslatma
/// matni) ham ishlatiladi.
final Provider<Locale> appLocaleProvider = Provider(
  (ref) =>
      ref.watch(languageProvider) ??
      // MaterialApp kabi — qurilma tillari ro'yxatining birinchisi.
      resolveAppLocale(
        WidgetsBinding.instance.platformDispatcher.locales.firstOrNull,
        appSupportedLocales,
      ),
);

final Provider<AppL10n> appL10nProvider = Provider(
  (ref) => lookupAppL10n(ref.watch(appLocaleProvider)),
);
