import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import '../dto/aggregate_dto.dart';
import '../dto/entry_dto.dart';
import '../refs.dart';

/// ★ Dashboard shu ikki repozitoriydan o'qiydi — jami **2 hujjat**.
final class FirestoreMonthRepository implements MonthRepository {
  const FirestoreMonthRepository(this._refs);

  final FirestoreRefs _refs;

  DocumentReference<MonthSummary> _doc(MonthKey month) =>
      _refs.month(month).withConverter<MonthSummary>(
            fromFirestore: MonthSummaryDto.fromFirestore,
            toFirestore: (summary, _) =>
                MonthSummaryDto.toFirestore(summary),
          );

  Query<MonthSummary> get _collection => _refs.months
      .withConverter<MonthSummary>(
        fromFirestore: MonthSummaryDto.fromFirestore,
        toFirestore: (summary, _) => MonthSummaryDto.toFirestore(summary),
      )
      .orderBy(FieldPath.documentId, descending: true);

  @override
  Stream<MonthSummary> watch(MonthKey month) => _doc(month)
      .snapshots()
      .map((doc) => doc.data() ?? MonthSummary.empty(month));

  @override
  Future<MonthSummary> fetch(MonthKey month) async =>
      (await _doc(month).get()).data() ?? MonthSummary.empty(month);

  @override
  Future<List<MonthSummary>> fetchAll({int limit = 36}) async =>
      (await _collection.limit(limit).get())
          .docs
          .map((doc) => doc.data())
          .toList();

  @override
  Stream<List<MonthSummary>> watchAll({int limit = 36}) => _collection
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  /// Avval KESHDAN o'qiydi: oy hujjati odatda dashboard tufayli keshda
  /// bo'ladi, shuning uchun bu tekshiruv ko'p hollarda 0 ta tarmoq so'rovi.
  @override
  Future<bool> isClosed(MonthKey month) async {
    try {
      final cached = await _doc(month).get(
        const GetOptions(source: Source.cache),
      );
      if (cached.exists) return cached.data()?.closed ?? false;
    } on FirebaseException {
      // Keshda yo'q — serverdan o'qiymiz.
    }
    return (await fetch(month)).closed;
  }
}

final class FirestoreTotalsRepository implements TotalsRepository {
  const FirestoreTotalsRepository(this._refs);

  final FirestoreRefs _refs;

  DocumentReference<OverallTotals> get _doc =>
      _refs.totals.withConverter<OverallTotals>(
        fromFirestore: TotalsDto.fromFirestore,
        toFirestore: (totals, _) => TotalsDto.toFirestore(totals),
      );

  @override
  Stream<OverallTotals> watch() => _doc
      .snapshots()
      .map((doc) => doc.data() ?? const OverallTotals());

  @override
  Future<OverallTotals> fetch() async =>
      (await _doc.get()).data() ?? const OverallTotals();
}

/// 🩺 `meta/health` — faqat o'qish (yozishni rules taqiqlaydi).
final class FirestoreHealthRepository implements HealthRepository {
  const FirestoreHealthRepository(this._refs);

  final FirestoreRefs _refs;

  DocumentReference<HealthReport> get _doc =>
      _refs.health.withConverter<HealthReport>(
        fromFirestore: HealthDto.fromFirestore,
        toFirestore: (_, __) => const <String, Object?>{},
      );

  @override
  Stream<HealthReport> watch() =>
      _doc.snapshots().map((doc) => doc.data() ?? const HealthReport());

  @override
  Future<HealthReport> fetch() async =>
      (await _doc.get()).data() ?? const HealthReport();
}

final class FirestoreDebtRepository implements DebtRepository {
  const FirestoreDebtRepository(this._refs);

  final FirestoreRefs _refs;

  Query<Debt> get _typed => _refs.debts
      .withConverter<Debt>(
        fromFirestore: DebtDto.fromFirestore,
        toFirestore: (debt, _) => DebtDto.toFirestore(debt),
      )
      .orderBy('name');

  @override
  Stream<List<Debt>> watchAll() => _typed
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  @override
  Future<List<Debt>> fetchAll() async => (await _typed.limit(100).get())
      .docs
      .map((doc) => doc.data())
      .toList();

  @override
  Future<Debt?> fetchById(String id) async => (await _refs.debts
          .withConverter<Debt>(
            fromFirestore: DebtDto.fromFirestore,
            toFirestore: (debt, _) => DebtDto.toFirestore(debt),
          )
          .doc(id)
          .get())
      .data();
}

final class FirestoreGoalRepository implements GoalRepository {
  const FirestoreGoalRepository(this._refs);

  final FirestoreRefs _refs;

  Query<Goal> get _typed => _refs.goals
      .withConverter<Goal>(
        fromFirestore: GoalDto.fromFirestore,
        toFirestore: (goal, _) => GoalDto.toFirestore(goal),
      )
      .orderBy('order');

  @override
  Stream<List<Goal>> watchAll() => _typed
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  @override
  Future<List<Goal>> fetchAll() async =>
      (await _typed.limit(50).get()).docs.map((doc) => doc.data()).toList();
}
