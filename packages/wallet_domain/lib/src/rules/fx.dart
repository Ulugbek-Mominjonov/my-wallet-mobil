import 'package:meta/meta.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';
import 'package:wallet_domain/src/value_objects/fx_rate.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// BR-191: hisob valyutasidagi summa → asosiy valyuta (serverdagi
/// `private.to_base_amount`): kasr xonalari farqi bilan, noldan uzoqqa
/// yaxlitlanadi. Katta summada ham aniq bo'lishi uchun — `BigInt`.
Money toBaseAmount(
  Money amount, {
  required Currency base,
  required FxRate rate,
}) {
  if (amount.currency == base) return Money(amount.minor, base);
  final shift = base.exponent - amount.currency.exponent;
  final numerator =
      BigInt.from(amount.minor) *
      BigInt.from(rate.scaled) *
      _pow10(shift > 0 ? shift : 0);
  final denominator =
      BigInt.from(FxRate.scale) * _pow10(shift < 0 ? -shift : 0);
  return Money(_roundDiv(numerator, denominator).toInt(), base);
}

/// BR-194: summani asosiy valyutaga o'tkazadi; kurs yo'q bo'lsa — `null`
/// (jamga kirmaydi, 0 deb hisoblanmaydi).
typedef ToBaseAmount = Money? Function(Money amount);

/// Kurslar jadvali (serverdagi `exchange_rates` nusxasi): sanadagi yoki undan
/// oldingi eng yaqin kurs. Qiymatlar so'mga nisbatan (`rate_to_base`).
@immutable
final class FxRates {
  /// [rows] — tartibi ahamiyatsiz; bir valyuta-sana juftligi bir marta.
  factory of(Iterable<FxRateRow> rows) {
    final byCurrency = <String, List<FxRateRow>>{};
    for (final row in rows) {
      (byCurrency[row.currency.code] ??= []).add(row);
    }
    for (final list in byCurrency.values) {
      list.sort((a, b) => a.date.compareTo(b.date));
    }
    return FxRates._(byCurrency);
  }

  const new _(this._byCurrency);

  static const empty = FxRates._({});

  final Map<String, List<FxRateRow>> _byCurrency;

  /// 1 birlik [from] necha birlik [to] ([on] sanasida) — serverdagi
  /// `private.fx_rate` kabi so'm orqali; kurs yo'q bo'lsa `null`.
  FxRate? rate(Currency from, Currency to, LocalDate on) {
    if (from == to) return FxRate.one;
    final fromUzs = _toUzs(from, on);
    final toUzs = _toUzs(to, on);
    if (fromUzs == null || toUzs == null || toUzs.scaled == 0) return null;
    return FxRate.fromScaled(
      _roundDiv(
        BigInt.from(fromUzs.scaled) * BigInt.from(FxRate.scale),
        BigInt.from(toUzs.scaled),
      ).toInt(),
    );
  }

  /// Summani [base] ga o'tkazuvchi funksiya (BR-194 jamlari uchun).
  ToBaseAmount converter(Currency base, LocalDate on) => (amount) {
    final found = rate(amount.currency, base, on);
    return found == null ? null : toBaseAmount(amount, base: base, rate: found);
  };

  FxRate? _toUzs(Currency currency, LocalDate on) {
    if (currency.code == _uzs) return FxRate.one;
    final rows = _byCurrency[currency.code];
    if (rows == null) return null;
    FxRate? found;
    for (final row in rows) {
      if (row.date.isAfter(on)) break;
      found = row.rate;
    }
    return found;
  }

  static const _uzs = 'UZS';
}

/// Bir valyutaning bir kundagi kursi (`exchange_rates` qatori).
typedef FxRateRow = ({Currency currency, LocalDate date, FxRate rate});

BigInt _pow10(int power) => BigInt.from(10).pow(power);

/// Noldan uzoqqa yaxlitlash — Postgres `round(numeric)` bilan bir xil.
BigInt _roundDiv(BigInt numerator, BigInt denominator) {
  final negative = numerator.isNegative != denominator.isNegative;
  final n = numerator.abs();
  final d = denominator.abs();
  final quotient = (BigInt.two * n + d) ~/ (BigInt.two * d);
  return negative ? -quotient : quotient;
}
