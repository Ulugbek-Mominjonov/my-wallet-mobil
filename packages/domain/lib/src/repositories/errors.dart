/// Domen xatolari — barchasi `Exception`, hech qayerda yutib yuborilmaydi.
sealed class BudgetFailure implements Exception {
  const BudgetFailure(this.message);

  final String message;

  /// Log va telemetriya uchun barqaror kod (obfuscation'ga bog'liq emas).
  String get code;

  @override
  String toString() => '$code: $message';
}

/// Kirish ma'lumoti noto'g'ri (tashqi kirish DOIM validatsiya qilinadi).
final class ValidationFailure extends BudgetFailure {
  const ValidationFailure(this.field, super.message);

  final String field;

  @override
  String get code => 'validation.$field';
}

/// Oy yopilgan — tahrirlash uchun avval ochish kerak.
final class MonthClosedFailure extends BudgetFailure {
  const MonthClosedFailure(this.monthKey)
      : super('Oy yopilgan — avval sozlamalardan oching');

  final String monthKey;

  @override
  String get code => 'month_closed';
}

/// Yozuv topilmadi.
final class NotFoundFailure extends BudgetFailure {
  const NotFoundFailure(this.id) : super('Yozuv topilmadi');

  final String id;

  @override
  String get code => 'not_found';
}

/// Boshqa joyda o'zgargan (optimistik konflikt).
final class ConflictFailure extends BudgetFailure {
  const ConflictFailure(super.message);

  @override
  String get code => 'conflict';
}
