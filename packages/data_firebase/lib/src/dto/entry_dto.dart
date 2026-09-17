import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import 'converters.dart';

/// `incomes/{id}` hujjati.
abstract final class IncomeDto {
  static Map<String, Object?> toFirestore(Income income) => <String, Object?>{
        'amount': income.amount.soum,
        'type': income.type,
        'method': income.method.wire,
        'paidAt': Write.date(income.paidAt),
        'monthKey': income.monthKey.value,
        'note': income.note,
        'debtId': income.debtId,
        'source': income.source.wire,
        'createdAt': Write.date(income.createdAt) ?? Write.now,
        'updatedAt': Write.now,
      };

  static Income fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final paidAt = Read.date(data, 'paidAt');
    return Income(
      id: doc.id,
      amount: Read.money(data, 'amount'),
      type: Read.text(data, 'type', or: 'Boshqa'),
      method: PaymentMethod.fromWire(data['method']),
      paidAt: paidAt,
      monthKey: Read.monthKey(data, 'monthKey', fallback: paidAt),
      note: Read.text(data, 'note'),
      debtId: Read.optionalText(data, 'debtId'),
      source: EntrySource.fromWire(data['source']),
      createdAt: Read.optionalDate(data, 'createdAt'),
      updatedAt: Read.optionalDate(data, 'updatedAt'),
    );
  }
}

/// `expenses/{id}` hujjati.
abstract final class ExpenseDto {
  static Map<String, Object?> toFirestore(Expense expense) =>
      <String, Object?>{
        'name': expense.name,
        'category': expense.category,
        'method': expense.method.wire,
        'planned': expense.planned?.soum,
        'actual': expense.actual?.soum,
        'dueDate': Write.date(expense.dueDate),
        'monthKey': expense.monthKey.value,
        'monthKeySource': expense.monthKeySource.wire,
        'status': expense.status.wire,
        'debtId': expense.debtId,
        'recurringId': expense.recurringId,
        'autoPay': expense.autoPay,
        'note': expense.note,
        'source': expense.source.wire,
        'createdAt': Write.date(expense.createdAt) ?? Write.now,
        'updatedAt': Write.now,
      };

  static Expense fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final dueDate = Read.date(data, 'dueDate');
    return Expense(
      id: doc.id,
      name: Read.text(data, 'name'),
      category: Read.text(data, 'category', or: 'Boshqa'),
      method: PaymentMethod.fromWire(data['method']),
      planned: Read.optionalMoney(data, 'planned'),
      actual: Read.optionalMoney(data, 'actual'),
      dueDate: dueDate,
      monthKey: Read.monthKey(data, 'monthKey', fallback: dueDate),
      monthKeySource: MonthKeySource.fromWire(data['monthKeySource']),
      status: PaymentStatus.fromWire(data['status']),
      debtId: Read.optionalText(data, 'debtId'),
      recurringId: Read.optionalText(data, 'recurringId'),
      autoPay: Read.flag(data, 'autoPay'),
      note: Read.text(data, 'note'),
      source: EntrySource.fromWire(data['source']),
      createdAt: Read.optionalDate(data, 'createdAt'),
      updatedAt: Read.optionalDate(data, 'updatedAt'),
    );
  }
}

/// `personalSpends/{id}` hujjati.
abstract final class PersonalSpendDto {
  static Map<String, Object?> toFirestore(PersonalSpend spend) =>
      <String, Object?>{
        'amount': spend.amount.soum,
        'purpose': spend.purpose,
        'method': spend.method.wire,
        'spentAt': Write.date(spend.spentAt),
        'monthKey': spend.monthKey.value,
        'note': spend.note,
        'createdAt': Write.date(spend.createdAt) ?? Write.now,
        'updatedAt': Write.now,
      };

  static PersonalSpend fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final spentAt = Read.date(data, 'spentAt');
    return PersonalSpend(
      id: doc.id,
      amount: Read.money(data, 'amount'),
      purpose: Read.text(data, 'purpose'),
      method: PaymentMethod.fromWire(data['method']),
      spentAt: spentAt,
      monthKey: Read.monthKey(data, 'monthKey', fallback: spentAt),
      note: Read.text(data, 'note'),
      createdAt: Read.optionalDate(data, 'createdAt'),
      updatedAt: Read.optionalDate(data, 'updatedAt'),
    );
  }
}

/// `debts/{id}` hujjati.
abstract final class DebtDto {
  /// Hisoblagichlar [includeCounters] bo'lmasa YOZILMAYDI — ular
  /// `increment` bilan yuritiladi va eski qiymat ularni bosib ketmasligi
  /// kerak.
  static Map<String, Object?> toFirestore(
    Debt debt, {
    bool includeCounters = false,
  }) =>
      <String, Object?>{
        'name': debt.name,
        'direction': debt.direction.wire,
        'total': debt.total.soum,
        'paidBefore': debt.paidBefore.soum,
        'monthly': debt.monthly.soum,
        'dueDate': Write.date(debt.dueDate),
        'note': debt.note,
        'archived': debt.archived,
        if (includeCounters) ...<String, Object?>{
          'paidFromExpenses': debt.paidFromExpenses.soum,
          'paidFromIncomes': debt.paidFromIncomes.soum,
          'pendingFromApp': debt.pendingFromApp.soum,
        },
        'createdAt': Write.date(debt.createdAt) ?? Write.now,
        'updatedAt': Write.now,
      };

  static Debt fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Debt(
      id: doc.id,
      name: Read.text(data, 'name'),
      direction: DebtDirection.fromWire(data['direction']),
      total: Read.money(data, 'total'),
      paidBefore: Read.money(data, 'paidBefore'),
      monthly: Read.money(data, 'monthly'),
      paidFromExpenses: Read.money(data, 'paidFromExpenses'),
      paidFromIncomes: Read.money(data, 'paidFromIncomes'),
      pendingFromApp: Read.money(data, 'pendingFromApp'),
      dueDate: Read.optionalDate(data, 'dueDate'),
      note: Read.text(data, 'note'),
      archived: Read.flag(data, 'archived'),
      createdAt: Read.optionalDate(data, 'createdAt'),
      updatedAt: Read.optionalDate(data, 'updatedAt'),
    );
  }
}

/// `goals/{id}` hujjati.
abstract final class GoalDto {
  static Map<String, Object?> toFirestore(Goal goal) => <String, Object?>{
        'name': goal.name,
        'target': goal.target.soum,
        'saved': goal.saved.soum,
        'monthly': goal.monthly?.soum,
        'deadline': Write.date(goal.deadline),
        'note': goal.note,
        'order': goal.order,
        'createdAt': Write.date(goal.createdAt) ?? Write.now,
        'updatedAt': Write.now,
      };

  static Goal fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Goal(
      id: doc.id,
      name: Read.text(data, 'name'),
      target: Read.money(data, 'target'),
      saved: Read.money(data, 'saved'),
      monthly: Read.optionalMoney(data, 'monthly'),
      deadline: Read.optionalDate(data, 'deadline'),
      note: Read.text(data, 'note'),
      order: Read.integer(data, 'order'),
      createdAt: Read.optionalDate(data, 'createdAt'),
      updatedAt: Read.optionalDate(data, 'updatedAt'),
    );
  }
}
