import 'package:flutter/foundation.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Klaviatura tugmalari (BR-140: `000` va oddiy `+ −` hisob).
enum AmountKey {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  tripleZero,
  backspace,
  plus,
  minus,
  equals,
}

/// Kiritilayotgan summa: raqamlar asosiy birlikda (so'm), ixtiyoriy
/// `+`/`−` amali bilan. Sof mantiq — UI'dan mustaqil sinaladi.
@immutable
final class AmountEntry {
  const new({this.digits = '', this.pending, this.left});

  /// Hozir terilayotgan raqamlar (asosiy birlikda, `''` — bo'sh).
  final String digits;

  /// Kutayotgan amal (`+` yoki `−`).
  final String? pending;

  /// Amaldan oldingi qiymat (asosiy birlikda).
  final int? left;

  static const maxDigits = 12;

  AmountEntry press(AmountKey key) => switch (key) {
    AmountKey.backspace => _backspace(),
    AmountKey.plus => _operator('+'),
    AmountKey.minus => _operator('−'),
    AmountKey.equals => _apply(),
    AmountKey.tripleZero => _digits('000'),
    _ => _digits('${key.index}'),
  };

  /// Kiritilgan (yoki hisoblangan) summa — eng kichik birlikda.
  Money value(Currency currency) =>
      Money(_result() * currency.minorPerMajor, currency);

  /// Ekranda ko'rsatiladigan raqam (amal tugamagan bo'lsa — terilayotgani).
  int get display => int.tryParse(digits) ?? (pending == null ? left ?? 0 : 0);

  bool get isEmpty => digits.isEmpty && left == null;

  int _result() {
    final current = int.tryParse(digits) ?? 0;
    return switch (pending) {
      '+' => (left ?? 0) + current,
      '−' => (left ?? 0) - current,
      _ => digits.isEmpty ? left ?? 0 : current,
    };
  }

  AmountEntry _digits(String suffix) {
    // Boshidagi nollar yig'ilmasin.
    final next = (digits.isEmpty && suffix == '000' ? '0' : digits + suffix)
        .replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (next.length > maxDigits) return this;
    return AmountEntry(digits: next, pending: pending, left: left);
  }

  AmountEntry _backspace() {
    if (digits.isNotEmpty) {
      return AmountEntry(
        digits: digits.substring(0, digits.length - 1),
        pending: pending,
        left: left,
      );
    }
    if (pending != null) return AmountEntry(digits: '${left ?? 0}');
    return const AmountEntry();
  }

  /// Amal bosilganda avvalgisi hisoblanadi (`2+3+` → `5+`).
  AmountEntry _operator(String operator) =>
      AmountEntry(pending: operator, left: _result());

  AmountEntry _apply() =>
      pending == null ? this : AmountEntry(digits: '${_result()}');
}
