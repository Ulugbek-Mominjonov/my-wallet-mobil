import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import '../dto/settings_dto.dart';
import '../refs.dart';
import 'query_support.dart';

/// Sozlamalar 4 ta kichik hujjatda; ular bitta oqimga yig'iladi.
///
/// Katalog kolleksiyalari (doimiy xarajatlar, limitlar, tez tugmalar,
/// kategoriyalar) kam o'zgaradi — ular uchun `Source.cache` afzal
/// ko'riladi va faqat kerak bo'lganda serverga boriladi (§5.4).
final class FirestoreSettingsRepository implements SettingsRepository {
  const FirestoreSettingsRepository(this._refs);

  final FirestoreRefs _refs;

  @override
  Stream<BudgetSettings> watch() => combineLatest<Map<String, dynamic>>(
        <Stream<Map<String, dynamic>>>[
          _refs.appSettings.snapshots().map(_data),
          _refs.personalFundSettings.snapshots().map(_data),
          _refs.incomeRules.snapshots().map(_data),
          _refs.reminders.snapshots().map(_data),
        ],
      ).map(_combine);

  @override
  Future<BudgetSettings> fetch() async {
    final documents = await Future.wait<DocumentSnapshot<Map<String, dynamic>>>(
      <Future<DocumentSnapshot<Map<String, dynamic>>>>[
        _refs.appSettings.get(),
        _refs.personalFundSettings.get(),
        _refs.incomeRules.get(),
        _refs.reminders.get(),
      ],
    );
    return _combine(documents.map(_data).toList());
  }

  @override
  Stream<List<RecurringExpense>> watchRecurring() => _refs.recurring
      .withConverter<RecurringExpense>(
        fromFirestore: RecurringDto.fromFirestore,
        toFirestore: (item, _) => RecurringDto.toFirestore(item),
      )
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  @override
  Future<List<RecurringExpense>> fetchRecurring() async => (await _refs
          .recurring
          .withConverter<RecurringExpense>(
            fromFirestore: RecurringDto.fromFirestore,
            toFirestore: (item, _) => RecurringDto.toFirestore(item),
          )
          .orderBy('order')
          .get())
      .docs
      .map((doc) => doc.data())
      .toList();

  @override
  Stream<List<CategoryLimit>> watchLimits() => _refs.limits
      .withConverter<CategoryLimit>(
        fromFirestore: LimitDto.fromFirestore,
        toFirestore: (item, _) => LimitDto.toFirestore(item),
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  @override
  Future<List<CategoryLimit>> fetchLimits() async => (await _refs.limits
          .withConverter<CategoryLimit>(
            fromFirestore: LimitDto.fromFirestore,
            toFirestore: (item, _) => LimitDto.toFirestore(item),
          )
          .get())
      .docs
      .map((doc) => doc.data())
      .toList();

  @override
  Stream<List<QuickAdd>> watchQuickAdds() => _refs.quickAdds
      .withConverter<QuickAdd>(
        fromFirestore: QuickAddDto.fromFirestore,
        toFirestore: (item, _) => QuickAddDto.toFirestore(item),
      )
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  @override
  Stream<List<CategoryDef>> watchCategories() => _refs.categories
      .withConverter<CategoryDef>(
        fromFirestore: CategoryDto.fromFirestore,
        toFirestore: (item, _) => CategoryDto.toFirestore(item),
      )
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  @override
  Future<List<CategoryDef>> fetchCategories() async => (await _refs.categories
          .withConverter<CategoryDef>(
            fromFirestore: CategoryDto.fromFirestore,
            toFirestore: (item, _) => CategoryDto.toFirestore(item),
          )
          .orderBy('order')
          .get())
      .docs
      .map((doc) => doc.data())
      .toList();

  static Map<String, dynamic> _data(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      doc.data() ?? const <String, dynamic>{};

  static BudgetSettings _combine(List<Map<String, dynamic>> documents) =>
      BudgetSettings(
        app: AppSettingsDto.fromMap(documents[0]),
        personalFund: PersonalFundSettingsDto.fromMap(documents[1]),
        incomeRules: IncomeRulesDto.fromMap(documents[2]),
        reminders: ReminderSettingsDto.fromMap(documents[3]),
      );
}
