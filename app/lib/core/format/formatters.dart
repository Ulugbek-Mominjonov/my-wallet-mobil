import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

/// Son va sana formatlari — ekranlarda `NumberFormat` qayta yaratilmaydi.
abstract final class Fmt {
  // Lokal ATAYLAB `en_US`: guruh ajratgichi doim vergul bo'ladi va uni
  // o'zbekcha ko'rinishga (probel) almashtiramiz. Aks holda natija
  // qurilma lokaliga qarab o'zgarib ketardi va testlar beqaror bo'lardi.
  static final NumberFormat _money = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _compact = NumberFormat('#,##0.#', 'en_US');
  static final DateFormat _day = DateFormat('dd.MM.yyyy');
  static final DateFormat _shortDay = DateFormat('dd.MM');

  static const List<String> monthNames = <String>[
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'Iyun',
    'Iyul',
    'Avgust',
    'Sentabr',
    'Oktabr',
    'Noyabr',
    'Dekabr',
  ];

  /// `12 000 000` — probel bilan ajratilgan.
  static String money(Money value) =>
      _money.format(value.soum).replaceAll(',', ' ');

  /// `12 000 000 so'm`.
  static String moneyLong(Money value) => "${money(value)} so'm";

  /// Katta summalarni qisqartiradi: `12,3 mln`.
  static String moneyCompact(Money value) {
    final absolute = value.soum.abs();
    if (absolute >= 1000000) {
      return '${_compact.format(value.soum / 1000000)} mln';
    }
    if (absolute >= 1000) {
      return '${_compact.format(value.soum / 1000)} ming';
    }
    return money(value);
  }

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String day(DateTime date) => _day.format(date);

  static String shortDay(DateTime date) => _shortDay.format(date);

  /// `Sentabr 2026`.
  static String monthTitle(MonthKey month) =>
      '${monthNames[month.month - 1]} ${month.year}';

  /// `Sentabr` — qisqa sarlavha.
  static String monthShort(MonthKey month) => monthNames[month.month - 1];

  /// `→ Sentabr 2026 oyining daromadi` — forma ostidagi jonli maslahat.
  static String attributionHint(MonthKey month, {required bool isIncome}) =>
      '→ ${monthTitle(month)} oyining '
      "${isIncome ? 'daromadi' : 'byudjetiga'}";
}
