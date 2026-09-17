import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../value_objects/enums.dart';
import '../value_objects/name_key.dart';

/// Umumiy ilova sozlamalari — `settings/app`.
@immutable
final class AppSettings {
  const AppSettings({
    this.locale = 'uz',
    this.themeMode = 'system',
    this.currency = 'UZS',
    this.timezone = 'Asia/Tashkent',
    this.personalCategory = defaultPersonalCategory,
    this.personalRowName = defaultPersonalRowName,
  });

  /// 👤 Shaxsiy fond ajratmasi shu kategoriya orqali yuritiladi.
  static const String defaultPersonalCategory = "O'zim uchun";

  /// Yangi oy ochilganda yaratiladigan ajratma qatorining nomi.
  static const String defaultPersonalRowName = "O'zim uchun (ajratma)";

  final String locale;
  final String themeMode;
  final String currency;
  final String timezone;
  final String personalCategory;
  final String personalRowName;

  String get personalCategoryKey => normalizeKey(personalCategory);

  AppSettings copyWith({
    String? locale,
    String? themeMode,
    String? currency,
    String? timezone,
    String? personalCategory,
    String? personalRowName,
  }) =>
      AppSettings(
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
        currency: currency ?? this.currency,
        timezone: timezone ?? this.timezone,
        personalCategory: personalCategory ?? this.personalCategory,
        personalRowName: personalRowName ?? this.personalRowName,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.locale == locale &&
          other.themeMode == themeMode &&
          other.currency == currency &&
          other.timezone == timezone &&
          other.personalCategory == personalCategory &&
          other.personalRowName == personalRowName;

  @override
  int get hashCode => Object.hash(
        locale,
        themeMode,
        currency,
        timezone,
        personalCategory,
        personalRowName,
      );
}

/// 👤 Shaxsiy fond qoidasi — `settings/personalFund`.
@immutable
final class PersonalFundSettings {
  const PersonalFundSettings({
    this.mode = PersonalFundMode.percent,
    this.value = 10,
    this.method = PaymentMethod.cash,
    this.day = 1,
  });

  final PersonalFundMode mode;

  /// Foiz rejimida — foiz (masalan 10); qat'iy rejimda — so'm.
  final int value;
  final PaymentMethod method;

  /// Ajratma qaysi kunda rejalashtiriladi.
  final int day;

  PersonalFundSettings copyWith({
    PersonalFundMode? mode,
    int? value,
    PaymentMethod? method,
    int? day,
  }) =>
      PersonalFundSettings(
        mode: mode ?? this.mode,
        value: value ?? this.value,
        method: method ?? this.method,
        day: day ?? this.day,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalFundSettings &&
          other.mode == mode &&
          other.value == value &&
          other.method == method &&
          other.day == day;

  @override
  int get hashCode => Object.hash(mode, value, method, day);
}

/// Bitta daromad turi uchun oy siljishi qoidasi.
@immutable
final class IncomeRule {
  const IncomeRule({required this.type, required this.shift});

  final String type;

  /// Oy siljishi: `-1` — oldingi oy, `0` — joriy oy.
  final int shift;

  String get typeKey => normalizeKey(type);

  IncomeRule copyWith({String? type, int? shift}) =>
      IncomeRule(type: type ?? this.type, shift: shift ?? this.shift);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeRule && other.type == type && other.shift == shift;

  @override
  int get hashCode => Object.hash(type, shift);

  @override
  String toString() => 'IncomeRule($type -> $shift)';
}

/// Daromad turi → tegishli oy qoidalari — `settings/incomeRules`.
///
/// Ro'yxat sifatida saqlanadi (map emas): ko'rsatish tartibi va turning
/// asl yozilishi (katta-kichik harf) saqlanib qoladi.
@immutable
final class IncomeRules {
  const IncomeRules(this.rules);

  /// Foydalanuvchining odatdagi holati (§2.1).
  static const IncomeRules defaults = IncomeRules(<IncomeRule>[
    IncomeRule(type: 'Avans', shift: 0),
    IncomeRule(type: 'Oylik', shift: -1),
    IncomeRule(type: 'KPI', shift: -1),
    IncomeRule(type: "Qo'shimcha", shift: -1),
  ]);

  final List<IncomeRule> rules;

  /// Qoida topilmasa `0` — joriy oy (Sheets'dagi xulq bilan bir xil).
  int shiftFor(String type) {
    final key = normalizeKey(type);
    return rules
            .firstWhereOrNull((rule) => rule.typeKey == key)
            ?.shift ??
        0;
  }

  IncomeRules withRule(IncomeRule rule) {
    final next = rules.toList();
    final index = next.indexWhere((item) => item.typeKey == rule.typeKey);
    if (index == -1) {
      next.add(rule);
    } else {
      next[index] = rule;
    }
    return IncomeRules(next);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeRules &&
          const ListEquality<IncomeRule>().equals(other.rules, rules);

  @override
  int get hashCode => const ListEquality<IncomeRule>().hash(rules);

  @override
  String toString() => 'IncomeRules($rules)';
}

/// Eslatma sozlamalari — `settings/reminders`.
@immutable
final class ReminderSettings {
  const ReminderSettings({
    this.pushEnabled = true,
    this.telegramEnabled = false,
    this.email = '',
    this.daysAhead = 3,
    this.hour = 9,
    this.monthlyEnabled = true,
    this.reportDay = defaultReportDay,
  });

  /// Daromad oyning ~20-sanasigacha to'liq tushadi, shuning uchun oylik
  /// hisobot 21-kuni yuboriladi (§6.1).
  static const int defaultReportDay = 21;

  final bool pushEnabled;
  final bool telegramEnabled;
  final String email;

  /// Necha kun oldin eslatilsin.
  final int daysAhead;

  /// Kunlik eslatma soati (0..23, foydalanuvchi vaqt zonasida).
  final int hour;
  final bool monthlyEnabled;

  /// Oylik hisobot kuni (1..28).
  final int reportDay;

  ReminderSettings copyWith({
    bool? pushEnabled,
    bool? telegramEnabled,
    String? email,
    int? daysAhead,
    int? hour,
    bool? monthlyEnabled,
    int? reportDay,
  }) =>
      ReminderSettings(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        telegramEnabled: telegramEnabled ?? this.telegramEnabled,
        email: email ?? this.email,
        daysAhead: daysAhead ?? this.daysAhead,
        hour: hour ?? this.hour,
        monthlyEnabled: monthlyEnabled ?? this.monthlyEnabled,
        reportDay: reportDay ?? this.reportDay,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderSettings &&
          other.pushEnabled == pushEnabled &&
          other.telegramEnabled == telegramEnabled &&
          other.email == email &&
          other.daysAhead == daysAhead &&
          other.hour == hour &&
          other.monthlyEnabled == monthlyEnabled &&
          other.reportDay == reportDay;

  @override
  int get hashCode => Object.hash(
        pushEnabled,
        telegramEnabled,
        email,
        daysAhead,
        hour,
        monthlyEnabled,
        reportDay,
      );
}

/// Barcha sozlamalar bitta joyda — ekranlarga shu uzatiladi.
@immutable
final class BudgetSettings {
  const BudgetSettings({
    this.app = const AppSettings(),
    this.personalFund = const PersonalFundSettings(),
    this.incomeRules = IncomeRules.defaults,
    this.reminders = const ReminderSettings(),
  });

  final AppSettings app;
  final PersonalFundSettings personalFund;
  final IncomeRules incomeRules;
  final ReminderSettings reminders;

  BudgetSettings copyWith({
    AppSettings? app,
    PersonalFundSettings? personalFund,
    IncomeRules? incomeRules,
    ReminderSettings? reminders,
  }) =>
      BudgetSettings(
        app: app ?? this.app,
        personalFund: personalFund ?? this.personalFund,
        incomeRules: incomeRules ?? this.incomeRules,
        reminders: reminders ?? this.reminders,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetSettings &&
          other.app == app &&
          other.personalFund == personalFund &&
          other.incomeRules == incomeRules &&
          other.reminders == reminders;

  @override
  int get hashCode => Object.hash(app, personalFund, incomeRules, reminders);
}
