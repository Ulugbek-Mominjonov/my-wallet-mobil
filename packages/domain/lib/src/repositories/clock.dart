/// Vaqt manbai.
///
/// Hech bir hisob-kitob `DateTime.now()` ni to'g'ridan-to'g'ri chaqirmaydi —
/// aks holda testlarda "bugun" ni boshqarib bo'lmasdi va "1-sentabrdagi
/// oylik avgustga tushadi" kabi qoidalarni tekshirish imkonsiz bo'lardi.
abstract interface class Clock {
  DateTime now();
}

/// Ish vaqtidagi haqiqiy soat.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Testlar uchun qotirilgan soat.
final class FixedClock implements Clock {
  const FixedClock(this._value);

  final DateTime _value;

  @override
  DateTime now() => _value;
}
