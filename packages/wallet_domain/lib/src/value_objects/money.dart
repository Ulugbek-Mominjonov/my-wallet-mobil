import 'package:meta/meta.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';

/// Pul — eng kichik birlikdagi butun son + valyuta (BR-001). Kasr yo'q:
/// hamma hisob butun sonlarda, yaxlitlash — faqat aniq qoidada (`roundTo`).
@immutable
final class Money implements Comparable<Money> {
  const new(this.minor, [this.currency = Currency.uzs]);

  /// Foydalanuvchi kiritgan summa (asosiy birlikda): `1 200 000`,
  /// `1,200,000`, `1 200 000,50`, `1200.5`. Minglik ajratgich — bo'shliq,
  /// vergul yoki nuqta (3 raqamli guruhlar); kasr — oxirgi ajratgichdan keyin
  /// valyuta kasr xonalaridan oshmagan raqamlar.
  factory parse(String input, {Currency currency = Currency.uzs}) {
    final parsed = tryParse(input, currency: currency);
    if (parsed == null) {
      throw FormatException("Summa noto'g'ri", input);
    }
    return parsed;
  }

  /// Yig'indi; bo'sh ro'yxat — nol ([currency] da).
  factory sum(Iterable<Money> values, [Currency currency = Currency.uzs]) =>
      values.fold(Money(0, currency), (total, value) => total + value);

  static const zero = Money(0);

  final int minor;
  final Currency currency;

  static final _spaces = RegExp(r'[\s   ]');
  static final _digits = RegExp(r'^\d+$');

  /// 15 raqam — int chegarasidan (2^63) ancha uzoq, eng kichik birlikda ham.
  static const _maxWholeDigits = 15;

  /// `parse` ning xato bermaydigan varianti.
  static Money? tryParse(String input, {Currency currency = Currency.uzs}) {
    var text = input.replaceAll(_spaces, '');
    var sign = 1;
    if (text.startsWith('-') || text.startsWith('−')) {
      sign = -1;
      text = text.substring(1);
    }
    final parts = text.isEmpty ? null : _split(text);
    if (parts == null) return null;
    final (whole, fraction) = parts;
    final valid =
        _digits.hasMatch(whole) &&
        whole.length <= _maxWholeDigits &&
        (fraction.isEmpty || _digits.hasMatch(fraction)) &&
        fraction.length <= currency.exponent;
    if (!valid) return null;

    final fractionMinor = fraction.isEmpty
        ? 0
        : int.parse(fraction.padRight(currency.exponent, '0'));
    return Money(
      sign * (int.parse(whole) * currency.minorPerMajor + fractionMinor),
      currency,
    );
  }

  /// Butun va kasr qismlari (ajratgichlarsiz) yoki null (noto'g'ri guruhlash).
  static (String, String)? _split(String text) {
    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');
    if (lastComma < 0 && lastDot < 0) return (text, '');

    final last = lastComma > lastDot ? lastComma : lastDot;
    final separator = text[last];
    final tail = text.substring(last + 1);
    // Kasr: ikkala ajratgich bo'lsa — oxirgisi; bittasi bo'lsa — bir marta va
    // undan keyin 3 emas raqam (1 200,5 / 1200.50). Aks holda — minglik.
    final isDecimal =
        (lastComma >= 0 && lastDot >= 0) ||
        (separator.allMatches(text).length == 1 && tail.length != 3);
    if (!isDecimal) {
      final whole = _ungroup(text, separator);
      return whole == null ? null : (whole, '');
    }
    final head = text.substring(0, last);
    final other = separator == ',' ? '.' : ',';
    final whole = head.contains(other) ? _ungroup(head, other) : head;
    return whole == null ? null : (whole, tail);
  }

  /// `1,200,000` → `1200000`; guruhlar 3 raqamli bo'lmasa — null.
  static String? _ungroup(String text, String separator) {
    final groups = text.split(separator);
    final valid =
        groups.first.isNotEmpty &&
        groups.first.length <= 3 &&
        groups.skip(1).every((group) => group.length == 3);
    return valid ? groups.join() : null;
  }

  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;
  bool get isPositive => minor > 0;

  Money abs() => isNegative ? -this : this;

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(minor + other.minor, currency);
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(minor - other.minor, currency);
  }

  Money operator -() => Money(-minor, currency);

  Money operator *(int factor) => Money(minor * factor, currency);

  /// [unit] ga karrali qiymatga yaxlitlash (noldan uzoqqa, 0.5 — yuqoriga):
  /// `Money(149_960_00).roundTo(1000_00)` → `150 000 so'm` (BR-060).
  Money roundTo(int unit) {
    if (unit <= 0) {
      throw ArgumentError.value(unit, 'unit', "musbat bo'lishi kerak");
    }
    return Money(roundDiv(minor, unit) * unit, currency);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minor.compareTo(other.minor);
  }

  void _requireSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Valyutalar farqli: $currency va ${other.currency}');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  /// Diagnostika uchun (`1500.00 UZS`); UI formati — ilovadagi `formatMoney`.
  @override
  String toString() {
    final unit = currency.minorPerMajor;
    final sign = minor < 0 ? '-' : '';
    final whole = minor.abs() ~/ unit;
    if (currency.exponent == 0) return '$sign$whole ${currency.code}';
    final fraction = (minor.abs() % unit).toString().padLeft(
      currency.exponent,
      '0',
    );
    return '$sign$whole.$fraction ${currency.code}';
  }
}
