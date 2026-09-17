/// Pul — HAR DOIM butun son (so'm).
///
/// `double` ataylab ishlatilmaydi: kasrli arifmetika moliyaviy hisobda
/// yaxlitlash driftini beradi (0.1 + 0.2 != 0.3). Hamma hisob-kitob butun
/// sonda ketadi, kasr faqat ko'rsatish (format) bosqichida paydo bo'ladi.
///
/// `extension type` — ish vaqtida bu oddiy `int`, ya'ni qo'shimcha xotira
/// yoki o'rash (boxing) narxi yo'q, lekin kompilyatsiya vaqtida
/// `Money` va oddiy `int` aralashib ketmaydi.
extension type const Money(int soum) implements int {
  /// Nol summa.
  static const Money zero = Money(0);

  /// Foydalanuvchi kiritgan matndan o'qiydi: `1 200 000`, `1,200,000`,
  /// `1200000 so'm` — hammasi 1200000 ga aylanadi.
  static Money parse(String raw) {
    final money = tryParse(raw);
    if (money == null) {
      throw FormatException("Summani o'qib bo'lmadi", raw);
    }
    return money;
  }

  /// [parse] ning xato tashlamaydigan varianti.
  static Money? tryParse(String raw) {
    final cleaned = raw.replaceAll(_noise, '');
    if (cleaned.isEmpty) return null;
    final parsed = int.tryParse(cleaned);
    return parsed == null ? null : Money(parsed);
  }

  /// Iterable'dagi barcha summalar yig'indisi.
  static Money sum(Iterable<Money> items) =>
      items.fold(zero, (total, item) => total + item);

  static final RegExp _noise = RegExp(r'[^\d-]');

  bool get isZero => soum == 0;

  bool get isPositive => soum > 0;

  bool get isNegative => soum < 0;

  Money get absolute => Money(soum.abs());

  Money get negated => Money(-soum);

  Money operator +(Money other) => Money(soum + other.soum);

  Money operator -(Money other) => Money(soum - other.soum);

  Money operator *(int factor) => Money(soum * factor);

  /// [step] gacha yaxlitlaydi (masalan 1000 so'mgacha).
  ///
  /// "O'zim uchun" rejasi shu qoidada hisoblanadi:
  /// `round(daromad * foiz / 100 / 1000) * 1000`.
  Money roundTo(int step) {
    if (step <= 1) return Money(soum);
    return Money((soum / step).round() * step);
  }

  /// [rate] foizini oladi (kasr qismi yaxlitlanadi).
  Money percentage(num rate) => Money((soum * rate / 100).round());

  /// [other] ga nisbati; [other] nol bo'lsa 0 qaytaradi
  /// (bo'linish xatosi yo'q).
  double ratioTo(Money other) => other.soum == 0 ? 0 : soum / other.soum;

  /// Manfiy bo'lsa nolga qisadi (qarz/maqsad qoldig'i uchun).
  Money get clampedToZero => soum < 0 ? zero : Money(soum);
}
