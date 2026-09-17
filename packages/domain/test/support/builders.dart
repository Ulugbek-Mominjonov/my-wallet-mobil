import 'dart:math';

import 'package:domain/domain.dart';

/// Testlarda yozuv yasash — har bir testda 15 qatorlik konstruktor
/// takrorlanmasligi uchun.
abstract final class Build {
  static Income income({
    String id = 'i1',
    int amount = 1000000,
    String type = 'Oylik',
    PaymentMethod method = PaymentMethod.card,
    DateTime? paidAt,
    String? monthKey,
    String? debtId,
  }) {
    final date = paidAt ?? DateTime(2026, 9, 10);
    return Income(
      id: id,
      amount: Money(amount),
      type: type,
      method: method,
      paidAt: date,
      monthKey: monthKey == null ? MonthKey.of(date) : MonthKey(monthKey),
      debtId: debtId,
    );
  }

  static Expense expense({
    String id = 'e1',
    String name = 'Oziq-ovqat',
    String category = 'Oziq-ovqat',
    PaymentMethod method = PaymentMethod.cash,
    int? planned = 500000,
    int? actual,
    DateTime? dueDate,
    String? monthKey,
    String? debtId,
    bool autoPay = false,
    MonthKeySource monthKeySource = MonthKeySource.auto,
  }) {
    final date = dueDate ?? DateTime(2026, 9, 15);
    return Expense(
      id: id,
      name: name,
      category: category,
      method: method,
      planned: planned == null ? null : Money(planned),
      actual: actual == null ? null : Money(actual),
      dueDate: date,
      monthKey: monthKey == null ? MonthKey.of(date) : MonthKey(monthKey),
      monthKeySource: monthKeySource,
      debtId: debtId,
      autoPay: autoPay,
    );
  }

  static PersonalSpend personalSpend({
    String id = 'p1',
    int amount = 200000,
    String purpose = 'Kitob',
    PaymentMethod method = PaymentMethod.cash,
    DateTime? spentAt,
  }) {
    final date = spentAt ?? DateTime(2026, 9, 20);
    return PersonalSpend(
      id: id,
      amount: Money(amount),
      purpose: purpose,
      method: method,
      spentAt: date,
      monthKey: MonthKey.of(date),
    );
  }

  static Debt debt({
    String id = 'd1',
    String name = 'Mashina',
    DebtDirection direction = DebtDirection.iOwe,
    int total = 50000000,
    int paidBefore = 0,
    int monthly = 5000000,
    int paidFromExpenses = 0,
    int paidFromIncomes = 0,
    int pendingFromApp = 0,
  }) =>
      Debt(
        id: id,
        name: name,
        direction: direction,
        total: Money(total),
        paidBefore: Money(paidBefore),
        monthly: Money(monthly),
        paidFromExpenses: Money(paidFromExpenses),
        paidFromIncomes: Money(paidFromIncomes),
        pendingFromApp: Money(pendingFromApp),
      );

  static Goal goal({
    String id = 'g1',
    String name = 'Sayohat',
    int target = 20000000,
    int saved = 5000000,
    int? monthly,
    DateTime? deadline,
  }) =>
      Goal(
        id: id,
        name: name,
        target: Money(target),
        saved: Money(saved),
        monthly: monthly == null ? null : Money(monthly),
        deadline: deadline,
      );

  static RecurringExpense recurring({
    String id = 'r1',
    String name = 'Internet',
    String category = 'Kommunal',
    int? amount = 200000,
    PaymentMethod method = PaymentMethod.card,
    int day = 5,
    bool autoPay = false,
    bool active = true,
    int order = 0,
    String? debtId,
  }) =>
      RecurringExpense(
        id: id,
        name: name,
        category: category,
        method: method,
        day: day,
        amount: amount == null ? null : Money(amount),
        autoPay: autoPay,
        active: active,
        order: order,
        debtId: debtId,
      );
}

/// Tasodifiy, lekin TAKRORLANADIGAN ma'lumot (seed bilan).
final class Fuzz {
  Fuzz(int seed) : _random = Random(seed);

  static const List<String> categories = <String>[
    'Oziq-ovqat',
    'Kommunal',
    'Qarz',
    "O'zim uchun",
    'Transport',
    'Boshqa',
  ];

  static const List<String> types = <String>[
    'Oylik',
    'Avans',
    'KPI',
    "Qo'shimcha",
  ];

  final Random _random;

  int next(int max) => _random.nextInt(max);

  bool chance(double probability) => _random.nextDouble() < probability;

  T pick<T>(List<T> items) => items[_random.nextInt(items.length)];

  Money amount({int max = 20}) => Money((_random.nextInt(max) + 1) * 50000);

  MonthKey month() =>
      MonthKey('2026-${(_random.nextInt(12) + 1).toString().padLeft(2, '0')}');

  DateTime dayIn(MonthKey month) =>
      month.dayOf(_random.nextInt(month.daysInMonth) + 1);
}
