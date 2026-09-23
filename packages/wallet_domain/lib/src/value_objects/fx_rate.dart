import 'package:meta/meta.dart';

/// BR-191: valyuta kursi — 1 birlik valyuta necha birlik asosiy valyuta.
///
/// Serverdagi `numeric(18, 6)` bilan bir xil aniqlik: qiymat 10^6 ga
/// ko'paytirilgan butun son sifatida saqlanadi (double bilan hisoblanmaydi —
/// server bilan paritet uchun).
@immutable
final class FxRate implements Comparable<FxRate> {
  const new _(this.scaled);

  /// [scaled] — 10^6 ga ko'paytirilgan qiymat (lokal bazadan, serverdan).
  factory fromScaled(int scaled) => FxRate._(scaled);

  /// Kasrli qiymatdan (masalan lokal bazadagi `REAL` ustun).
  factory fromDouble(double value) => FxRate._((value * scale).round());

  static const decimals = 6;
  static const scale = 1000000;

  /// Valyuta o'ziga — 1.
  static const one = FxRate._(scale);

  static final _pattern = RegExp(r'^\d+(\.\d+)?$');

  /// Matndan (`12 600`, `12600.5`, `0.000123`) — noto'g'ri bo'lsa `null`.
  static FxRate? tryParse(String input) {
    final text = input.trim();
    if (!_pattern.hasMatch(text)) return null;
    final dot = text.indexOf('.');
    final whole = dot < 0 ? text : text.substring(0, dot);
    final fraction = dot < 0 ? '' : text.substring(dot + 1);
    if (fraction.length > decimals) return null;
    final scaled =
        int.parse(whole) * scale +
        (fraction.isEmpty ? 0 : int.parse(fraction.padRight(decimals, '0')));
    return scaled > 0 ? FxRate._(scaled) : null;
  }

  /// 10^6 ga ko'paytirilgan qiymat.
  final int scaled;

  double get asDouble => scaled / scale;

  @override
  int compareTo(FxRate other) => scaled.compareTo(other.scaled);

  @override
  bool operator ==(Object other) => other is FxRate && other.scaled == scaled;

  @override
  int get hashCode => scaled.hashCode;

  /// Serverga yuboriladigan ko'rinish: ortiqcha nollarsiz (`12600`, `12600.5`).
  @override
  String toString() {
    final whole = scaled ~/ scale;
    final fraction = (scaled % scale).toString().padLeft(decimals, '0');
    final trimmed = fraction.replaceAll(RegExp(r'0+$'), '');
    return trimmed.isEmpty ? '$whole' : '$whole.$trimmed';
  }
}
