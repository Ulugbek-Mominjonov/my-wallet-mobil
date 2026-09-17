import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import '../dto/entry_dto.dart';
import '../refs.dart';
import 'query_support.dart';

/// Firestore so'rovlari — hammasi `limit` bilan, hammasi indeksli.
final class FirestoreExpenseRepository implements ExpenseRepository {
  const FirestoreExpenseRepository(this._refs);

  final FirestoreRefs _refs;

  Query<Expense> get _typed => _refs.expenses
      .withConverter<Expense>(
        fromFirestore: ExpenseDto.fromFirestore,
        toFirestore: (expense, _) => ExpenseDto.toFirestore(expense),
      )
      .orderBy('dueDate')
      .orderBy(FieldPath.documentId);

  @override
  Stream<List<Expense>> watchMonth(MonthKey month) => _typed
      .where('monthKey', isEqualTo: month.value)
      .limit(200)
      .snapshots()
      .map(_items);

  @override
  Future<Page<Expense>> fetchMonth(
    MonthKey month, {
    int limit = 50,
    String? cursor,
  }) async {
    var query = _typed.where('monthKey', isEqualTo: month.value).limit(limit);
    final start = Cursor.decode(cursor);
    if (start != null) query = query.startAfter(start);
    return _page(await query.get(), limit, (item) => item.dueDate);
  }

  @override
  Future<List<Expense>> fetchMonthAll(MonthKey month) async => _items(
        await _typed.where('monthKey', isEqualTo: month.value).get(),
      );

  @override
  Future<List<Expense>> fetchUnpaid({
    DateTime? until,
    int limit = 100,
  }) async {
    var query = _refs.expenses
        .withConverter<Expense>(
          fromFirestore: ExpenseDto.fromFirestore,
          toFirestore: (expense, _) => ExpenseDto.toFirestore(expense),
        )
        .where(
          'status',
          whereIn: <String>[
            PaymentStatus.pending.wire,
            PaymentStatus.overdue.wire,
          ],
        )
        .orderBy('dueDate');
    if (until != null) {
      query = query.where(
        'dueDate',
        isLessThanOrEqualTo: Timestamp.fromDate(until),
      );
    }
    return _items(await query.limit(limit).get());
  }

  @override
  Stream<List<Expense>> watchUnpaid({int limit = 100}) => _refs.expenses
      .withConverter<Expense>(
        fromFirestore: ExpenseDto.fromFirestore,
        toFirestore: (expense, _) => ExpenseDto.toFirestore(expense),
      )
      .where(
        'status',
        whereIn: <String>[
          PaymentStatus.pending.wire,
          PaymentStatus.overdue.wire,
        ],
      )
      .orderBy('dueDate')
      .limit(limit)
      .snapshots()
      .map(_items);

  /// Qarz tarixi — BITTA so'rov (har qarz uchun alohida emas).
  @override
  Future<List<Expense>> fetchByDebt(String debtId, {int limit = 50}) async =>
      _items(
        await _refs.expenses
            .withConverter<Expense>(
              fromFirestore: ExpenseDto.fromFirestore,
              toFirestore: (expense, _) => ExpenseDto.toFirestore(expense),
            )
            .where('debtId', isEqualTo: debtId)
            .orderBy('dueDate', descending: true)
            .limit(limit)
            .get(),
      );

  @override
  Future<Expense?> fetchById(String id) async {
    final doc = await _refs.expenses
        .withConverter<Expense>(
          fromFirestore: ExpenseDto.fromFirestore,
          toFirestore: (expense, _) => ExpenseDto.toFirestore(expense),
        )
        .doc(id)
        .get();
    return doc.data();
  }
}

final class FirestoreIncomeRepository implements IncomeRepository {
  const FirestoreIncomeRepository(this._refs);

  final FirestoreRefs _refs;

  Query<Income> get _typed => _refs.incomes
      .withConverter<Income>(
        fromFirestore: IncomeDto.fromFirestore,
        toFirestore: (income, _) => IncomeDto.toFirestore(income),
      )
      .orderBy('paidAt', descending: true)
      .orderBy(FieldPath.documentId);

  @override
  Stream<List<Income>> watchMonth(MonthKey month) => _typed
      .where('monthKey', isEqualTo: month.value)
      .limit(100)
      .snapshots()
      .map(_items);

  @override
  Future<Page<Income>> fetchMonth(
    MonthKey month, {
    int limit = 50,
    String? cursor,
  }) async {
    var query = _typed.where('monthKey', isEqualTo: month.value).limit(limit);
    final start = Cursor.decode(cursor);
    if (start != null) query = query.startAfter(start);
    return _page(await query.get(), limit, (item) => item.paidAt);
  }

  @override
  Future<Income?> fetchById(String id) async {
    final doc = await _refs.incomes
        .withConverter<Income>(
          fromFirestore: IncomeDto.fromFirestore,
          toFirestore: (income, _) => IncomeDto.toFirestore(income),
        )
        .doc(id)
        .get();
    return doc.data();
  }

  /// Qoida o'zgarganda barcha yozuvlarni bo'lib-bo'lib o'qiydi —
  /// hammasi bir vaqtda xotiraga yuklanmaydi.
  @override
  Stream<List<Income>> streamAll({int chunkSize = 300}) async* {
    String? cursor;
    while (true) {
      var query = _typed.limit(chunkSize);
      final start = Cursor.decode(cursor);
      if (start != null) query = query.startAfter(start);
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) return;
      final items = _items(snapshot);
      yield items;
      if (items.length < chunkSize) return;
      cursor = Cursor.encode(items.last.paidAt, items.last.id);
    }
  }
}

final class FirestorePersonalSpendRepository
    implements PersonalSpendRepository {
  const FirestorePersonalSpendRepository(this._refs);

  final FirestoreRefs _refs;

  Query<PersonalSpend> get _typed => _refs.personalSpends
      .withConverter<PersonalSpend>(
        fromFirestore: PersonalSpendDto.fromFirestore,
        toFirestore: (spend, _) => PersonalSpendDto.toFirestore(spend),
      )
      .orderBy('spentAt', descending: true)
      .orderBy(FieldPath.documentId);

  @override
  Stream<List<PersonalSpend>> watchMonth(MonthKey month) => _typed
      .where('monthKey', isEqualTo: month.value)
      .limit(100)
      .snapshots()
      .map(_items);

  @override
  Future<Page<PersonalSpend>> fetchRecent({
    int limit = 50,
    String? cursor,
  }) async {
    var query = _typed.limit(limit);
    final start = Cursor.decode(cursor);
    if (start != null) query = query.startAfter(start);
    return _page(await query.get(), limit, (item) => item.spentAt);
  }

  @override
  Future<PersonalSpend?> fetchById(String id) async {
    final doc = await _refs.personalSpends
        .withConverter<PersonalSpend>(
          fromFirestore: PersonalSpendDto.fromFirestore,
          toFirestore: (spend, _) => PersonalSpendDto.toFirestore(spend),
        )
        .doc(id)
        .get();
    return doc.data();
  }
}

List<T> _items<T>(QuerySnapshot<T> snapshot) =>
    snapshot.docs.map((doc) => doc.data()).toList();

Page<T> _page<T>(
  QuerySnapshot<T> snapshot,
  int limit,
  DateTime Function(T) sortValue,
) {
  final items = _items(snapshot);
  return Page<T>(
    items: items,
    cursor: items.isEmpty
        ? null
        : Cursor.encode(sortValue(items.last), snapshot.docs.last.id),
    hasMore: items.length == limit,
  );
}
