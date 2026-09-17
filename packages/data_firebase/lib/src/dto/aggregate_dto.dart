import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import 'converters.dart';

/// `months/{YYYY-MM}` — oylik agregat.
abstract final class MonthSummaryDto {
  /// Reconciler uchun MUTLAQ qiymat (delta emas).
  static Map<String, Object?> toFirestore(MonthSummary summary) =>
      <String, Object?>{
        'monthKey': summary.monthKey.value,
        'income': summary.income.soum,
        'incomeCard': summary.incomeCard.soum,
        'incomeCash': summary.incomeCash.soum,
        'expense': summary.expense.soum,
        'expenseCard': summary.expenseCard.soum,
        'expenseCash': summary.expenseCash.soum,
        'planned': summary.planned.soum,
        'unpaidTotal': summary.unpaidTotal.soum,
        'unknownCount': summary.unknownCount,
        'personalAllocated': summary.personalAllocated.soum,
        'personalSpent': summary.personalSpent.soum,
        'byType': <String, Object?>{
          for (final entry in summary.byType.entries)
            entry.key: <String, Object?>{
              'card': entry.value.card.soum,
              'cash': entry.value.cash.soum,
            },
        },
        'byCategory': <String, Object?>{
          for (final entry in summary.byCategory.entries)
            entry.key: <String, Object?>{
              'planned': entry.value.planned.soum,
              'actual': entry.value.actual.soum,
            },
        },
        'closed': summary.closed,
        'version': summary.version,
        'updatedAt': Write.now,
      };

  static MonthSummary fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final monthKey = MonthKey.tryParse(data['monthKey']) ??
        MonthKey.tryParse(doc.id) ??
        MonthKey.of(DateTime.now());

    final byType = <String, MethodSplit>{};
    Read.map(data, 'byType').forEach((key, value) {
      if (value is! Map) return;
      final split = Map<String, dynamic>.from(value);
      final entry = MethodSplit(
        card: Read.money(split, 'card'),
        cash: Read.money(split, 'cash'),
      );
      if (!entry.isZero) byType[key] = entry;
    });

    final byCategory = <String, CategorySplit>{};
    Read.map(data, 'byCategory').forEach((key, value) {
      if (value is! Map) return;
      final split = Map<String, dynamic>.from(value);
      final entry = CategorySplit(
        planned: Read.money(split, 'planned'),
        actual: Read.money(split, 'actual'),
      );
      if (!entry.isZero) byCategory[key] = entry;
    });

    return MonthSummary(
      monthKey: monthKey,
      income: Read.money(data, 'income'),
      incomeCard: Read.money(data, 'incomeCard'),
      incomeCash: Read.money(data, 'incomeCash'),
      expense: Read.money(data, 'expense'),
      expenseCard: Read.money(data, 'expenseCard'),
      expenseCash: Read.money(data, 'expenseCash'),
      planned: Read.money(data, 'planned'),
      unpaidTotal: Read.money(data, 'unpaidTotal'),
      unknownCount: Read.integer(data, 'unknownCount'),
      personalAllocated: Read.money(data, 'personalAllocated'),
      personalSpent: Read.money(data, 'personalSpent'),
      byType: byType,
      byCategory: byCategory,
      closed: Read.flag(data, 'closed'),
      version: Read.integer(data, 'version', or: 1),
      updatedAt: Read.optionalDate(data, 'updatedAt'),
    );
  }
}

/// `meta/totals` — global agregat.
abstract final class TotalsDto {
  static Map<String, Object?> toFirestore(OverallTotals totals) =>
      <String, Object?>{
        'income': totals.income.soum,
        'expense': totals.expense.soum,
        'personalAllocated': totals.personalAllocated.soum,
        'personalSpent': totals.personalSpent.soum,
        'updatedAt': Write.now,
      };

  static OverallTotals fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return OverallTotals(
      income: Read.money(data, 'income'),
      expense: Read.money(data, 'expense'),
      personalAllocated: Read.money(data, 'personalAllocated'),
      personalSpent: Read.money(data, 'personalSpent'),
      updatedAt: Read.optionalDate(data, 'updatedAt'),
    );
  }
}

/// `meta/health` — 🩺 reconciler hisoboti (faqat o'qish).
abstract final class HealthDto {
  static HealthReport fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final months = data['checkedMonths'];
    return HealthReport(
      lastRun: Read.optionalDate(data, 'lastRun'),
      checkedMonths: months is List
          ? months.map((item) => item.toString()).toList()
          : const <String>[],
      driftCount: Read.integer(data, 'driftCount'),
      fixedCount: Read.integer(data, 'fixedCount'),
      details: Read.map(data, 'drift'),
    );
  }
}
