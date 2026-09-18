/// Butun sonli bo'lish, **noldan uzoqqa** yaxlitlash (Postgres `round(numeric)`
/// bilan bir xil): `roundDiv(5, 2) == 3`, `roundDiv(-5, 2) == -3`.
///
/// Server hisobotlari bilan pariteti uchun kasrli (double) hisob ishlatilmaydi.
int roundDiv(int numerator, int denominator) {
  if (denominator == 0) {
    throw ArgumentError.value(
      denominator,
      'denominator',
      "0 ga bo'lib bo'lmaydi",
    );
  }
  final negative = (numerator < 0) != (denominator < 0);
  final n = numerator.abs();
  final d = denominator.abs();
  final quotient = (2 * n + d) ~/ (2 * d);
  return negative ? -quotient : quotient;
}

/// `round(numerator / denominator, 4)` — hisobotlardagi nisbatlar (0.5739).
double ratio4(int numerator, int denominator) =>
    roundDiv(numerator * 10000, denominator) / 10000;
