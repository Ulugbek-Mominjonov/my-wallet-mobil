import '../entities/catalog.dart';
import '../entities/debt.dart';
import '../entities/expense.dart';
import '../entities/goal.dart';
import '../entities/income.dart';
import '../entities/month_summary.dart';
import '../entities/overall_totals.dart';
import '../entities/personal_spend.dart';
import '../entities/settings.dart';
import '../value_objects/month_key.dart';

/// Ro'yxat so'rovining sahifasi.
///
/// Cheksiz ro'yxat YO'Q: har so'rov `limit` bilan ketadi va keyingi sahifa
/// oxirgi hujjatdan davom etadi (`offset` ishlatilmaydi — Firestore
/// o'tkazib yuborilgan hujjatlar uchun ham pul oladi, §5.4).
final class Page<T> {
  const Page({required this.items, this.cursor, this.hasMore = false});

  final List<T> items;

  /// Keyingi sahifa uchun kursor (oxirgi hujjat identifikatori).
  final String? cursor;
  final bool hasMore;

  bool get isEmpty => items.isEmpty;
}

/// ★ Dashboard'ning yagona manbai — `months/{YYYY-MM}`.
abstract interface class MonthRepository {
  /// Faqat joriy oy uchun tirik ulanish (§5.4).
  Stream<MonthSummary> watch(MonthKey month);

  Future<MonthSummary> fetch(MonthKey month);

  /// Barcha oylar — jamg'arma ekrani va yillik tahlil uchun.
  Future<List<MonthSummary>> fetchAll({int limit = 36});

  Stream<List<MonthSummary>> watchAll({int limit = 36});

  /// Oy yopilganmi? Avval keshdan o'qiladi — odatda 0 ta tarmoq so'rovi.
  Future<bool> isClosed(MonthKey month);
}

/// ★ Global agregat — `meta/totals`.
abstract interface class TotalsRepository {
  Stream<OverallTotals> watch();

  Future<OverallTotals> fetch();
}

abstract interface class IncomeRepository {
  Stream<List<Income>> watchMonth(MonthKey month);

  Future<Page<Income>> fetchMonth(
    MonthKey month, {
    int limit = 50,
    String? cursor,
  });

  Future<Income?> fetchById(String id);

  /// Qoida o'zgarganda qayta joylash uchun — barcha yozuvlar oqimi.
  Stream<List<Income>> streamAll({int chunkSize = 300});
}

abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchMonth(MonthKey month);

  Future<Page<Expense>> fetchMonth(
    MonthKey month, {
    int limit = 50,
    String? cursor,
  });

  /// To'lanmaganlar — `status` indeksidan (butun jadval skanlanmaydi).
  Future<List<Expense>> fetchUnpaid({DateTime? until, int limit = 100});

  Stream<List<Expense>> watchUnpaid({int limit = 100});

  /// Qarz tarixi — BITTA so'rov, har qarz uchun alohida emas (N+1 yo'q).
  Future<List<Expense>> fetchByDebt(String debtId, {int limit = 50});

  Future<Expense?> fetchById(String id);

  /// Yangi oy ochishda idempotentlikni tekshirish uchun.
  Future<List<Expense>> fetchMonthAll(MonthKey month);
}

abstract interface class PersonalSpendRepository {
  Stream<List<PersonalSpend>> watchMonth(MonthKey month);

  Future<Page<PersonalSpend>> fetchRecent({int limit = 50, String? cursor});

  Future<PersonalSpend?> fetchById(String id);
}

abstract interface class DebtRepository {
  Stream<List<Debt>> watchAll();

  Future<List<Debt>> fetchAll();

  Future<Debt?> fetchById(String id);
}

abstract interface class GoalRepository {
  Stream<List<Goal>> watchAll();

  Future<List<Goal>> fetchAll();
}

/// Sozlamalar — kam o'zgaradi, uzoq keshlanadi.
abstract interface class SettingsRepository {
  Stream<BudgetSettings> watch();

  Future<BudgetSettings> fetch();

  Stream<List<RecurringExpense>> watchRecurring();

  Future<List<RecurringExpense>> fetchRecurring();

  Stream<List<CategoryLimit>> watchLimits();

  Future<List<CategoryLimit>> fetchLimits();

  Stream<List<QuickAdd>> watchQuickAdds();

  Stream<List<CategoryDef>> watchCategories();

  Future<List<CategoryDef>> fetchCategories();
}

/// 🩺 Reconciler natijasi — `meta/health`.
abstract interface class HealthRepository {
  Stream<HealthReport> watch();

  Future<HealthReport> fetch();
}

/// Oxirgi tekshiruv hisoboti.
final class HealthReport {
  const HealthReport({
    this.lastRun,
    this.checkedMonths = const <String>[],
    this.driftCount = 0,
    this.fixedCount = 0,
    this.details = const <String, Object?>{},
  });

  final DateTime? lastRun;
  final List<String> checkedMonths;
  final int driftCount;
  final int fixedCount;
  final Map<String, Object?> details;

  bool get isHealthy => driftCount == 0;
}
