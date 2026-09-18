import 'package:flutter/widgets.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Qurilma tili qo'llab-quvvatlanmasa — o'zbekcha (asosiy til, ADR-15).
/// Tanlangan tilni saqlash — sozlamalarda (E19-T04).
Locale resolveAppLocale(Locale? device, Iterable<Locale> supported) {
  final code = device?.languageCode;
  for (final locale in supported) {
    if (locale.languageCode == code) return locale;
  }
  return const Locale('uz');
}

/// MaterialApp uchun tayyor sozlamalar.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    AppL10n.localizationsDelegates;
const List<Locale> appSupportedLocales = AppL10n.supportedLocales;
