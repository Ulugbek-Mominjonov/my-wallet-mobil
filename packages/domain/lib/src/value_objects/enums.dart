/// To'lov usuli — karta yoki naqd.
///
/// Sheets'da matn (`Karta` / `Naqd`) edi; Firestore'da qisqa kalit
/// (`card` / `cash`) saqlanadi, ko'rsatish uchun tarjima ishlatiladi.
enum PaymentMethod {
  card('card', 'Karta'),
  cash('cash', 'Naqd');

  const PaymentMethod(this.wire, this.legacyLabel);

  /// Firestore'da saqlanadigan qiymat.
  final String wire;

  /// Sheets'dagi ustun qiymati (migratsiya uchun).
  final String legacyLabel;

  static PaymentMethod fromWire(Object? raw) => switch (raw) {
        'card' => PaymentMethod.card,
        'cash' => PaymentMethod.cash,
        _ => fromLegacy(raw),
      };

  /// Sheets'dan import: `Karta` dan boshqa hamma narsa naqd hisoblanadi —
  /// `Code.gs` dagi qoidaning aynan o'zi.
  static PaymentMethod fromLegacy(Object? raw) =>
      raw.toString().trim().toLowerCase() == 'karta'
          ? PaymentMethod.card
          : PaymentMethod.cash;
}

/// To'lov holati — `ustunlarniToldir_` dagi qoidaning aynan o'zi.
enum PaymentStatus {
  /// Fakt kiritilgan.
  paid('paid'),

  /// Fakt yo'q, muddati hali kelmagan.
  pending('pending'),

  /// Fakt yo'q, muddati o'tib ketgan.
  overdue('overdue'),

  /// Reja ham, fakt ham nol — kuzatilmaydigan qator (Sheets'dagi `—`).
  none('none');

  const PaymentStatus(this.wire);

  final String wire;

  bool get isUnpaid => this == pending || this == overdue;

  static PaymentStatus fromWire(Object? raw) => switch (raw) {
        'paid' => PaymentStatus.paid,
        'pending' => PaymentStatus.pending,
        'overdue' => PaymentStatus.overdue,
        _ => PaymentStatus.none,
      };
}

/// Xarajat qaysi oyga tegishli ekani qayerdan kelgan.
enum MonthKeySource {
  /// To'lov sanasidan avtomatik hisoblangan.
  auto('auto'),

  /// Foydalanuvchi qo'lda boshqa oyga biriktirgan.
  manual('manual');

  const MonthKeySource(this.wire);

  final String wire;

  static MonthKeySource fromWire(Object? raw) =>
      raw == 'manual' ? MonthKeySource.manual : MonthKeySource.auto;
}

/// Qarz yo'nalishi.
enum DebtDirection {
  /// Men qarzdorman — bog'langan XARAJAT qarzni kamaytiradi.
  iOwe('iOwe', 'Men qarzdorman'),

  /// Menga qarzdor — bog'langan DAROMAD haqni kamaytiradi.
  owedToMe('owedToMe', 'Menga qarzdor');

  const DebtDirection(this.wire, this.legacyLabel);

  final String wire;
  final String legacyLabel;

  static DebtDirection fromWire(Object? raw) => switch (raw) {
        'owedToMe' => DebtDirection.owedToMe,
        'iOwe' => DebtDirection.iOwe,
        _ => fromLegacy(raw),
      };

  static DebtDirection fromLegacy(Object? raw) =>
      raw.toString().trim() == 'Menga qarzdor'
          ? DebtDirection.owedToMe
          : DebtDirection.iOwe;
}

/// 👤 Shaxsiy fond ajratmasi qanday hisoblanadi.
enum PersonalFundMode {
  /// Daromadning foizi (1000 so'mgacha yaxlitlanadi).
  percent('percent', 'Foiz'),

  /// Qat'iy summa.
  fixed('fixed', "Qat'iy summa");

  const PersonalFundMode(this.wire, this.legacyLabel);

  final String wire;
  final String legacyLabel;

  static PersonalFundMode fromWire(Object? raw) =>
      raw == 'fixed' ? PersonalFundMode.fixed : PersonalFundMode.percent;

  static PersonalFundMode fromLegacy(Object? raw) =>
      raw.toString().trim().toLowerCase() == 'foiz'
          ? PersonalFundMode.percent
          : PersonalFundMode.fixed;
}

/// Yozuv qayerdan kelgan — kelajakdagi SMS/skaner uchun joy qoldirilgan
/// (reja §15).
enum EntrySource {
  manual('manual'),
  recurring('recurring'),
  imported('imported'),
  sms('sms'),
  scan('scan');

  const EntrySource(this.wire);

  final String wire;

  static EntrySource fromWire(Object? raw) => values.firstWhere(
        (source) => source.wire == raw,
        orElse: () => EntrySource.manual,
      );
}
