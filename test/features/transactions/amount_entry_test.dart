import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/transactions/application/amount_entry.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  AmountEntry entry(List<AmountKey> keys) =>
      keys.fold(const AmountEntry(), (state, key) => state.press(key));

  const digits = {
    '0': AmountKey.zero,
    '1': AmountKey.one,
    '2': AmountKey.two,
    '3': AmountKey.three,
    '5': AmountKey.five,
    '9': AmountKey.nine,
  };

  AmountEntry type(String input) {
    var state = const AmountEntry();
    for (final char in input.split('')) {
      state = state.press(switch (char) {
        '+' => AmountKey.plus,
        '-' => AmountKey.minus,
        '=' => AmountKey.equals,
        '#' => AmountKey.tripleZero,
        '<' => AmountKey.backspace,
        _ => digits[char]!,
      });
    }
    return state;
  }

  test("raqamlar va `000`; boshida nol yig'ilmaydi", () {
    expect(type('12#').display, 12000);
    expect(type('#').display, 0);
    expect(type('#5').display, 5);
    expect(type('005').display, 5);
    expect(entry(const []).isEmpty, isTrue);
  });

  test("summa eng kichik birlikda (so'm → tiyin)", () {
    expect(type('15#').value(Currency.uzs), const Money(1500000));
    expect(type('12').value(Currency.usd), const Money(1200, Currency.usd));
  });

  test('oddiy hisob: + va −, ketma-ket amallar', () {
    expect(type('12#+3#=').display, 15000);
    expect(type('12#+3#').value(Currency.uzs), const Money(1500000));
    expect(type('5#-2#=').display, 3000);
    // 2+3+ → 5 (avvalgisi hisoblanadi), keyin 1 qo'shiladi.
    expect(type('2+3+1=').display, 6);
  });

  test("⌫: raqam, amal va bo'sh holat", () {
    expect(type('123<').display, 12);
    expect(type('12+<').display, 12);
    expect(type('12+3<<').display, 12);
    expect(type('<').isEmpty, isTrue);
    expect(type('1<').isEmpty, isTrue);
  });

  test('uzunlik chegarasi (12 raqam)', () {
    final long = type('999999999999');
    expect(long.display, 999999999999);
    expect(long.press(AmountKey.nine).display, 999999999999);
  });
}
