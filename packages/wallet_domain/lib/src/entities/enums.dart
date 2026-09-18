// Server enum'lari (contracts/api.md) — `wire` — aynan serverdagi qiymat.

/// Wire qiymatidan enum; noma'lum qiymat — `FormatException` (shartnoma
/// buzilgan).
T _fromWire<T extends Enum>(
  List<T> values,
  String wire,
  String Function(T) of,
) => values.firstWhere(
  (value) => of(value) == wire,
  orElse: () => throw FormatException("Noma'lum qiymat", wire),
);

enum MemberRole {
  owner('owner'),
  admin('admin'),
  member('member'),
  viewer('viewer');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;

  /// BR-011: amal yoza oladiganlar.
  bool get canWrite => this != viewer;

  /// Spravochniklar va sozlamalarni boshqaradiganlar.
  bool get canManage => this == owner || this == admin;
}

/// BR-020..026. `personalFund` — 👤 shaxsiy fond, byudjetda bitta.
enum AccountType {
  cash('cash'),
  card('card'),
  bank('bank'),
  ewallet('ewallet'),
  deposit('deposit'),
  personalFund('personal_fund'),
  other('other');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;

  /// BR-022: naqd → `cash`, qolgan byudjet hisoblari → `card` usuli.
  bool get isCash => this == cash;
}

enum CategoryKind {
  income('income'),
  expense('expense');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}

/// Reja/doimiy reja turi; `allocation` — 👤 fondga ajratma (BR-060, BR-061).
enum PlanKind {
  expense('expense'),
  income('income'),
  allocation('allocation');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}

enum TransactionKind {
  income('income'),
  expense('expense'),
  transfer('transfer');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}

/// BR-042: tegishli oy qoidadan (`auto`) yoki qo'lda (`manual`).
enum BudgetMonthSource {
  auto('auto'),
  manual('manual');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}

enum TransactionSource {
  manual('manual'),
  quickAction('quick_action'),
  autoPay('auto_pay'),
  import('import'),
  telegram('telegram');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}

/// BR-111: `iOwe` — men qarzdorman, `owedToMe` — menga qarzdor.
enum DebtDirection {
  iOwe('i_owe'),
  owedToMe('owed_to_me');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}

/// BR-060: fond qoidasi — daromaddan foiz yoki qat'iy summa.
enum PersonalFundMode {
  percent('percent'),
  fixed('fixed');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}

/// Tizim yozuvlari (kategoriya va reja): 👤 fond ajratmasi.
enum SystemCode {
  personalAllocation('personal_allocation');

  new(this.wire);

  factory fromWire(String wire) => _fromWire(values, wire, (v) => v.wire);

  final String wire;
}
