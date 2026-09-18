import 'package:meta/meta.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';

/// Byudjet oyi (`YYYY-MM`) — serverda `YYYY-MM-01` (`month_start` domeni).
@immutable
final class MonthKey implements Comparable<MonthKey> {
  factory(int year, int month) {
    if (year < 1 || year > 9999 || month < 1 || month > 12) {
      throw ArgumentError('Oy mavjud emas: $year-$month');
    }
    return MonthKey._(year, month);
  }

  /// `2026-09` yoki `2026-09-01` (kun faqat 01 bo'lishi mumkin).
  factory parse(String iso) {
    final match = _iso.firstMatch(iso);
    if (match == null) throw FormatException("Oy formati noto'g'ri", iso);
    return MonthKey(int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  factory ofDate(LocalDate date) => MonthKey(date.year, date.month);

  const new _(this.year, this.month);

  static final _iso = RegExp(r'^(\d{4})-(\d{2})(?:-01)?$');

  final int year;
  final int month;

  /// [months] oy keyin (manfiy — oldin): `2026-01` → `shift(-1)` → `2025-12`.
  MonthKey shift(int months) {
    final index = year * 12 + (month - 1) + months;
    return MonthKey(index ~/ 12, index % 12 + 1);
  }

  /// [other] gacha oylar soni (keyin bo'lsa musbat).
  int monthsUntil(MonthKey other) =>
      (other.year * 12 + other.month) - (year * 12 + month);

  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  LocalDate get firstDay => LocalDate(year, month, 1);
  LocalDate get lastDay => LocalDate(year, month, daysInMonth);

  /// Oyning [day]-kuni; qisqa oyda oxirgi kunga qisiladi (BR-080: 31 →
  /// 30/29/28). Serverdagi `private.month_day` bilan bir xil.
  LocalDate dayOf(int day) {
    if (day < 1 || day > 31) {
      throw ArgumentError.value(day, 'day', "1–31 oralig'ida");
    }
    return LocalDate(year, month, day > daysInMonth ? daysInMonth : day);
  }

  bool contains(LocalDate date) => date.year == year && date.month == month;

  bool isBefore(MonthKey other) => compareTo(other) < 0;
  bool isAfter(MonthKey other) => compareTo(other) > 0;

  @override
  int compareTo(MonthKey other) =>
      (year * 12 + month).compareTo(other.year * 12 + other.month);

  @override
  bool operator ==(Object other) =>
      other is MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  /// Server formati: `2026-09-01`.
  String toIsoDate() => '$this-01';

  /// `2026-09`.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}
