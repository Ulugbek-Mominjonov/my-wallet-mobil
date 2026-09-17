import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../value_objects/money.dart';
import '../value_objects/month_key.dart';
import 'entity_support.dart';

/// Daromad turi kesimi: karta / naqd.
@immutable
final class MethodSplit {
  const MethodSplit({this.card = Money.zero, this.cash = Money.zero});

  final Money card;
  final Money cash;

  Money get total => card + cash;

  bool get isZero => card.isZero && cash.isZero;

  MethodSplit operator +(MethodSplit other) =>
      MethodSplit(card: card + other.card, cash: cash + other.cash);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MethodSplit && other.card == card && other.cash == cash;

  @override
  int get hashCode => Object.hash(card, cash);

  @override
  String toString() => 'MethodSplit(card: $card, cash: $cash)';
}

/// Kategoriya kesimi: reja / fakt.
@immutable
final class CategorySplit {
  const CategorySplit({this.planned = Money.zero, this.actual = Money.zero});

  final Money planned;
  final Money actual;

  bool get isZero => planned.isZero && actual.isZero;

  CategorySplit operator +(CategorySplit other) => CategorySplit(
        planned: planned + other.planned,
        actual: actual + other.actual,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorySplit &&
          other.planned == planned &&
          other.actual == actual;

  @override
  int get hashCode => Object.hash(planned, actual);

  @override
  String toString() => 'CategorySplit(reja: $planned, fakt: $actual)';
}

/// ★ Oylik agregat — `months/{YYYY-MM}` hujjatining domen ko'rinishi.
///
/// Dashboard AYNAN shu bitta hujjatdan quriladi. Hosila qiymatlar
/// ([balance], [forecast], [saved] ...) SAQLANMAYDI — ular shu yerda
/// hisoblanadi, chunki ikkita manba = drift (§4.1).
@immutable
final class MonthSummary {
  const MonthSummary({
    required this.monthKey,
    this.income = Money.zero,
    this.incomeCard = Money.zero,
    this.incomeCash = Money.zero,
    this.expense = Money.zero,
    this.expenseCard = Money.zero,
    this.expenseCash = Money.zero,
    this.planned = Money.zero,
    this.unpaidTotal = Money.zero,
    this.unknownCount = 0,
    this.personalAllocated = Money.zero,
    this.personalSpent = Money.zero,
    this.byType = const <String, MethodSplit>{},
    this.byCategory = const <String, CategorySplit>{},
    this.closed = false,
    this.version = 1,
    this.updatedAt,
  });

  /// Bo'sh oy — hujjat hali yozilmagan holat.
  factory MonthSummary.empty(MonthKey monthKey) =>
      MonthSummary(monthKey: monthKey);

  final MonthKey monthKey;
  final Money income;
  final Money incomeCard;
  final Money incomeCash;

  /// Fakt xarajat (to'langan summalar yig'indisi).
  final Money expense;
  final Money expenseCard;
  final Money expenseCash;

  /// Reja jami.
  final Money planned;

  /// To'lanmagan qatorlarning rejasi.
  final Money unpaidTotal;

  /// Rejasi ham ko'rsatilmagan to'lanmagan qatorlar soni.
  final int unknownCount;

  /// 👤 "O'zim uchun" kategoriyasiga ajratilgan fakt summa.
  final Money personalAllocated;

  /// 👤 Shaxsiy fonddan shu oyda sarflangan summa.
  final Money personalSpent;
  final Map<String, MethodSplit> byType;
  final Map<String, CategorySplit> byCategory;
  final bool closed;
  final int version;
  final DateTime? updatedAt;

  /// Qoldiq = daromad − xarajat (§2.3).
  Money get balance => income - expense;

  /// Prognoz = qoldiq − to'lanmagan jami.
  Money get forecast => balance - unpaidTotal;

  /// Karta kesimi = karta daromadi − karta xarajati.
  Money get card => incomeCard - expenseCard;

  /// Naqd kesimi.
  Money get cash => incomeCash - expenseCash;

  /// Orttirgan: "o'zim uchun" ajratmasi sarf emas — cho'ntak almashdi,
  /// shaxsiy fonddan sarflangani esa haqiqiy sarf (§2.3).
  Money get saved => balance + personalAllocated - personalSpent;

  /// Orttirish foizi (0..1).
  double get savedRatio => income.soum > 0 ? saved.soum / income.soum : 0;

  /// Reja bajarilishi (0..1+) — byudjet progress-bari uchun.
  double get plannedUsage =>
      planned.soum > 0 ? expense.soum / planned.soum : 0;

  bool get isEmpty =>
      income.isZero &&
      expense.isZero &&
      planned.isZero &&
      personalAllocated.isZero &&
      personalSpent.isZero;

  /// Kategoriyalar — faktga ko'ra kamayish tartibida (`kamayishBoyicha_`).
  List<MapEntry<String, CategorySplit>> get categoriesByAmount {
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.actual.compareTo(a.value.actual));
    return entries;
  }

  /// Daromad turlari — summaga ko'ra kamayish tartibida.
  List<MapEntry<String, MethodSplit>> get typesByAmount {
    final entries = byType.entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));
    return entries;
  }

  MonthSummary copyWith({
    MonthKey? monthKey,
    Money? income,
    Money? incomeCard,
    Money? incomeCash,
    Money? expense,
    Money? expenseCard,
    Money? expenseCash,
    Money? planned,
    Money? unpaidTotal,
    int? unknownCount,
    Money? personalAllocated,
    Money? personalSpent,
    Map<String, MethodSplit>? byType,
    Map<String, CategorySplit>? byCategory,
    bool? closed,
    int? version,
    Object? updatedAt = unchanged,
  }) =>
      MonthSummary(
        monthKey: monthKey ?? this.monthKey,
        income: income ?? this.income,
        incomeCard: incomeCard ?? this.incomeCard,
        incomeCash: incomeCash ?? this.incomeCash,
        expense: expense ?? this.expense,
        expenseCard: expenseCard ?? this.expenseCard,
        expenseCash: expenseCash ?? this.expenseCash,
        planned: planned ?? this.planned,
        unpaidTotal: unpaidTotal ?? this.unpaidTotal,
        unknownCount: unknownCount ?? this.unknownCount,
        personalAllocated: personalAllocated ?? this.personalAllocated,
        personalSpent: personalSpent ?? this.personalSpent,
        byType: byType ?? this.byType,
        byCategory: byCategory ?? this.byCategory,
        closed: closed ?? this.closed,
        version: version ?? this.version,
        updatedAt: orKeep(updatedAt, this.updatedAt),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthSummary &&
          other.monthKey == monthKey &&
          other.income == income &&
          other.incomeCard == incomeCard &&
          other.incomeCash == incomeCash &&
          other.expense == expense &&
          other.expenseCard == expenseCard &&
          other.expenseCash == expenseCash &&
          other.planned == planned &&
          other.unpaidTotal == unpaidTotal &&
          other.unknownCount == unknownCount &&
          other.personalAllocated == personalAllocated &&
          other.personalSpent == personalSpent &&
          const MapEquality<String, MethodSplit>()
              .equals(other.byType, byType) &&
          const MapEquality<String, CategorySplit>()
              .equals(other.byCategory, byCategory) &&
          other.closed == closed;

  @override
  int get hashCode => Object.hash(
        monthKey,
        income,
        incomeCard,
        incomeCash,
        expense,
        expenseCard,
        expenseCash,
        planned,
        unpaidTotal,
        unknownCount,
        personalAllocated,
        personalSpent,
        const MapEquality<String, MethodSplit>().hash(byType),
        const MapEquality<String, CategorySplit>().hash(byCategory),
        closed,
      );

  @override
  String toString() => 'MonthSummary($monthKey, daromad: $income, '
      'xarajat: $expense, qoldiq: $balance)';
}
