import 'package:meta/meta.dart';

/// Valyuta (ISO 4217) va kasr xonalari soni — serverdagi `currencies.exponent`.
@immutable
final class Currency {
  const new(this.code, {this.exponent = 2, this.allocationUnit = 100})
    : assert(exponent >= 0 && exponent <= 4, 'exponent 0–4'),
      assert(allocationUnit > 0, 'allocationUnit > 0');

  /// Fond ajratmasi 1000 so'mga yaxlitlanadi (serverda
  /// `currencies.allocation_rounding`).
  static const uzs = Currency('UZS', allocationUnit: 100000);
  static const usd = Currency('USD');
  static const eur = Currency('EUR');
  static const rub = Currency('RUB');

  final String code;

  /// Eng kichik birlik: UZS — tiyin (2), USD — sent (2).
  final int exponent;

  /// BR-060: fond ajratmasi yaxlitlanadigan birlik (eng kichik birlikda).
  /// Tenglikka kirmaydi — valyuta kod va kasr xonalari bilan aniqlanadi.
  final int allocationUnit;

  /// 1 asosiy birlikdagi eng kichik birliklar soni (10^exponent).
  int get minorPerMajor {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      other is Currency && other.code == code && other.exponent == exponent;

  @override
  int get hashCode => Object.hash(code, exponent);

  @override
  String toString() => code;
}
