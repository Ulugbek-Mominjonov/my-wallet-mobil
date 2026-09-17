/// Oy kaliti — `YYYY-MM`.
///
/// Firestore'da oddiy string sifatida saqlanadi: tenglik so'rovi
/// (`where('monthKey', isEqualTo: ...)`) va leksikografik saralash
/// to'g'ridan-to'g'ri xronologik tartib beradi — alohida indeks turi
/// kerak emas.
extension type const MonthKey(String value) implements String {
  /// `2026-09` ko'rinishidagi matndan o'qiydi.
  factory MonthKey.parse(String raw) {
    final key = MonthKey.tryParse(raw);
    if (key == null) {
      throw FormatException("Oy YYYY-MM ko'rinishida bo'lishi kerak", raw);
    }
    return key;
  }

  /// Sanadan oy kalitini yasaydi (lokal vaqt zonasida).
  factory MonthKey.of(DateTime date) => MonthKey(
        '${date.year.toString().padLeft(4, '0')}'
        '-${date.month.toString().padLeft(2, '0')}',
      );

  /// Noto'g'ri qiymatda `null` qaytaradi — tashqi ma'lumotni tekshirish uchun.
  static MonthKey? tryParse(Object? raw) {
    if (raw is! String) return null;
    final trimmed = raw.trim();
    return pattern.hasMatch(trimmed) ? MonthKey(trimmed) : null;
  }

  static bool isValid(Object? raw) => tryParse(raw) != null;

  /// `Code.gs` dagi `OY_REGEX` ning aynan o'zi.
  static final RegExp pattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

  int get year => int.parse(value.substring(0, 4));

  int get month => int.parse(value.substring(5, 7));

  /// Oydagi kunlar soni (kabisa yili ham to'g'ri).
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  DateTime get firstDay => DateTime(year, month);

  DateTime get lastDay => DateTime(year, month, daysInMonth);

  /// `oySurish_` ning analogi: oyni [months] ga suradi (manfiy ham bo'ladi).
  MonthKey shift(int months) =>
      months == 0 ? this : MonthKey.of(DateTime(year, month + months));

  MonthKey get next => shift(1);

  MonthKey get previous => shift(-1);

  /// Oy ichidagi [day] kuni; oy oxiridan oshsa oxirgi kunga qisiladi
  /// (`sanaYasa_` ning analogi: 31-kun fevralda 28/29 ga tushadi).
  DateTime dayOf(int day) => DateTime(year, month, day.clamp(1, daysInMonth));

  bool containsDate(DateTime date) => date.year == year && date.month == month;

  /// Shu oydan [end] gacha (ikkalasi ham kiritilgan) oylar ro'yxati.
  List<MonthKey> rangeTo(MonthKey end) {
    final months = <MonthKey>[];
    var cursor = this;
    while (cursor.compareTo(end) <= 0) {
      months.add(cursor);
      cursor = cursor.next;
      if (months.length > 1200) break; // 100 yil — himoya chegarasi
    }
    return months;
  }
}
