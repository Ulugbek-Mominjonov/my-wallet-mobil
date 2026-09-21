import 'package:meta/meta.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// Kun aniqligidagi sana — soatsiz va vaqt zonasiz (BR-002). "Bugun" byudjet
/// vaqt zonasida aniqlanib, shu tipga o'giriladi (chaqiruvchi vazifasi).
@immutable
final class LocalDate implements Comparable<LocalDate> {
  /// Mavjud bo'lmagan sana (masalan 31-sentabr) — `ArgumentError`.
  factory(int year, int month, int day) {
    final normalized = DateTime.utc(year, month, day);
    if (year < 1 ||
        year > 9999 ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError('Sana mavjud emas: $year-$month-$day');
    }
    return LocalDate._(year, month, day);
  }

  /// `2026-09-18`.
  factory parse(String iso) {
    final match = _iso.firstMatch(iso);
    if (match == null) throw FormatException("Sana formati noto'g'ri", iso);
    return LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  /// Soat qismi tashlanadi — [dateTime] allaqachon kerakli vaqt zonasida.
  factory fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  const new _(this.year, this.month, this.day);

  static final _iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  MonthKey get monthKey => MonthKey(year, month);

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(_utc.add(Duration(days: days)));

  /// [other] gacha kunlar (keyin bo'lsa musbat).
  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// Hafta kuni: 1 — dushanba … 7 — yakshanba (ISO 8601).
  int get weekday => _utc.weekday;

  @override
  int compareTo(LocalDate other) => _ordinal.compareTo(other._ordinal);

  int get _ordinal => (year * 12 + month) * 31 + day;

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// ISO: `2026-09-18` (server bilan almashinuv formati).
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
