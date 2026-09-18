/// Pul — hamma joyda eng kichik birlikdagi butun son (tiyin/sent), BR-001.
/// Kasr faqat shu yerda, ko'rsatishda paydo bo'ladi. Qoida admin paneldagi
/// `formatMoney` bilan bir xil: UZS so'mgacha yaxlitlanadi, minglar NBSP bilan.
library;

/// UI tillari (ADR-15).
enum AppLocale { uz, ru, en }

const _nbsp = ' ';
const _minus = '−';

/// ISO 4217 kasr xonalari (ma'lumotnoma — serverdagi `currencies.exponent`).
const Map<String, int> _currencyExponent = {
  'UZS': 2,
  'USD': 2,
  'EUR': 2,
  'RUB': 2,
};

const Map<AppLocale, String> _uzsSuffix = {
  AppLocale.uz: "so'm",
  AppLocale.ru: 'сум',
  AppLocale.en: 'UZS',
};

const Map<String, String> _currencySymbol = {
  'USD': r'$',
  'EUR': '€',
  'RUB': '₽',
};

int currencyExponent(String currency) => _currencyExponent[currency] ?? 2;

/// `1234567` → `1 234 567` (NBSP bilan; qatorga bo'linmaydi).
String _groupDigits(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_nbsp);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _sign(num value, {required bool signed}) {
  if (value < 0) return _minus;
  return signed && value > 0 ? '+' : '';
}

/// `formatMoney(123456700)` → `1 234 567 so'm`.
String formatMoney(
  int minor, {
  String currency = 'UZS',
  AppLocale locale = AppLocale.uz,
  bool signed = false,
}) {
  final divisor = _pow10(currencyExponent(currency));

  if (currency == 'UZS') {
    final whole = (minor / divisor).round();
    return '${_sign(whole, signed: signed)}${_groupDigits(whole)}'
        '$_nbsp${_uzsSuffix[locale]}';
  }

  final cents = minor.abs() % divisor;
  final whole = minor.abs() ~/ divisor;
  final fraction = cents.toString().padLeft(currencyExponent(currency), '0');
  final symbol = _currencySymbol[currency] ?? '$currency$_nbsp';
  return '${_sign(minor, signed: signed)}$symbol${_groupDigits(whole)}'
      '.$fraction';
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
