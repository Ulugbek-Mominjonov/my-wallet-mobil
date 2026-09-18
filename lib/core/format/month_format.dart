import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Oy sarlavhasi: `Sentabr 2026` (admin panel bilan bir xil ko'rinish).
/// `MonthKey` value object E12-T01 da — hozircha yil va oy raqami.
String formatMonthTitle(AppL10n l10n, {required int year, required int month}) {
  RangeError.checkValueInInterval(month, 1, 12, 'month');
  return '${l10n.monthName('$month')} $year';
}
