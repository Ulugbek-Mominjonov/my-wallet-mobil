import 'package:meta/meta.dart';

import '../entities/month_summary.dart';
import '../value_objects/month_key.dart';

/// Bitta maydondagi farq (drift).
@immutable
final class FieldDrift {
  const FieldDrift({
    required this.field,
    required this.stored,
    required this.computed,
  });

  final String field;

  /// Firestore'da turgan qiymat (delta bilan yig'ilgan).
  final int stored;

  /// Xom yozuvlardan noldan hisoblangan qiymat.
  final int computed;

  int get difference => computed - stored;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldDrift &&
          other.field == field &&
          other.stored == stored &&
          other.computed == computed;

  @override
  int get hashCode => Object.hash(field, stored, computed);

  @override
  String toString() => '$field: $stored → $computed';
}

/// Bir oydagi barcha farqlar.
@immutable
final class MonthDrift {
  const MonthDrift({required this.monthKey, required this.fields});

  final MonthKey monthKey;
  final List<FieldDrift> fields;

  bool get isClean => fields.isEmpty;

  @override
  String toString() => 'MonthDrift($monthKey, $fields)';
}

/// §5.5 — "🩺 Tekshirish va tuzatish" ning mantiqiy yadrosi.
///
/// Klient tomonda hisoblangan agregat nazariy jihatdan xato yig'ishi mumkin
/// (batch o'rtasida crash, konsoldan qo'lda tahrir, migratsiya). Reconciler
/// noldan hisoblab, farqni topadi va tuzatadi.
abstract final class ReconcileCalc {
  /// Ikki agregatni solishtiradi. Bo'sh ro'yxat — drift yo'q.
  static MonthDrift compare({
    required MonthSummary stored,
    required MonthSummary computed,
  }) {
    final fields = <FieldDrift>[];
    void check(String name, int storedValue, int computedValue) {
      if (storedValue != computedValue) {
        fields.add(
          FieldDrift(
            field: name,
            stored: storedValue,
            computed: computedValue,
          ),
        );
      }
    }

    check('income', stored.income, computed.income);
    check('incomeCard', stored.incomeCard, computed.incomeCard);
    check('incomeCash', stored.incomeCash, computed.incomeCash);
    check('expense', stored.expense, computed.expense);
    check('expenseCard', stored.expenseCard, computed.expenseCard);
    check('expenseCash', stored.expenseCash, computed.expenseCash);
    check('planned', stored.planned, computed.planned);
    check('unpaidTotal', stored.unpaidTotal, computed.unpaidTotal);
    check('unknownCount', stored.unknownCount, computed.unknownCount);
    check(
      'personalAllocated',
      stored.personalAllocated,
      computed.personalAllocated,
    );
    check('personalSpent', stored.personalSpent, computed.personalSpent);

    for (final key in <String>{
      ...stored.byType.keys,
      ...computed.byType.keys,
    }) {
      final storedSplit = stored.byType[key] ?? const MethodSplit();
      final computedSplit = computed.byType[key] ?? const MethodSplit();
      check('byType.$key.card', storedSplit.card, computedSplit.card);
      check('byType.$key.cash', storedSplit.cash, computedSplit.cash);
    }

    for (final key in <String>{
      ...stored.byCategory.keys,
      ...computed.byCategory.keys,
    }) {
      final storedSplit = stored.byCategory[key] ?? const CategorySplit();
      final computedSplit = computed.byCategory[key] ?? const CategorySplit();
      check(
        'byCategory.$key.planned',
        storedSplit.planned,
        computedSplit.planned,
      );
      check(
        'byCategory.$key.actual',
        storedSplit.actual,
        computedSplit.actual,
      );
    }

    return MonthDrift(monthKey: computed.monthKey, fields: fields);
  }
}
