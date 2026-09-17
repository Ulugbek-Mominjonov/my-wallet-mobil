import 'package:domain/domain.dart';

/// Test dublyorlari: faqat sinovda kerak bo'lgan metodlar javob beradi,
/// qolganlari ataylab `UnsupportedError` tashlaydi — noto'g'ri joyda
/// ishlatilsa test darhol qulaydi (jimgina noto'g'ri natija bermaydi).
Never _unused() => throw UnsupportedError('Bu testda ishlatilmaydi');

final class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository([this.monthExpenses = const <Expense>[]]);

  final List<Expense> monthExpenses;

  @override
  Future<List<Expense>> fetchMonthAll(MonthKey month) async =>
      monthExpenses.where((item) => item.monthKey == month).toList();

  @override
  Future<Page<Expense>> fetchMonth(
    MonthKey month, {
    int limit = 50,
    String? cursor,
  }) async =>
      Page<Expense>(items: await fetchMonthAll(month));

  @override
  Future<List<Expense>> fetchUnpaid({DateTime? until, int limit = 100}) async =>
      monthExpenses.where((item) => !item.isPaid).toList();

  @override
  Future<List<Expense>> fetchByDebt(String debtId, {int limit = 50}) async =>
      monthExpenses.where((item) => item.debtId == debtId).toList();

  @override
  Future<Expense?> fetchById(String id) async =>
      monthExpenses.where((item) => item.id == id).firstOrNull;

  @override
  Stream<List<Expense>> watchMonth(MonthKey month) => _unused();

  @override
  Stream<List<Expense>> watchUnpaid({int limit = 100}) => _unused();
}

final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    this.settings = const BudgetSettings(),
    this.recurring = const <RecurringExpense>[],
    this.limits = const <CategoryLimit>[],
  });

  final BudgetSettings settings;
  final List<RecurringExpense> recurring;
  final List<CategoryLimit> limits;

  @override
  Future<BudgetSettings> fetch() async => settings;

  @override
  Future<List<RecurringExpense>> fetchRecurring() async => recurring;

  @override
  Future<List<CategoryLimit>> fetchLimits() async => limits;

  @override
  Future<List<CategoryDef>> fetchCategories() async => const <CategoryDef>[];

  @override
  Stream<BudgetSettings> watch() => _unused();

  @override
  Stream<List<RecurringExpense>> watchRecurring() => _unused();

  @override
  Stream<List<CategoryLimit>> watchLimits() => _unused();

  @override
  Stream<List<QuickAdd>> watchQuickAdds() => _unused();

  @override
  Stream<List<CategoryDef>> watchCategories() => _unused();
}

final class FakeMonthRepository implements MonthRepository {
  FakeMonthRepository({this.summaries = const <MonthSummary>[]});

  final List<MonthSummary> summaries;

  @override
  Future<MonthSummary> fetch(MonthKey month) async =>
      summaries.where((item) => item.monthKey == month).firstOrNull ??
      MonthSummary.empty(month);

  @override
  Future<List<MonthSummary>> fetchAll({int limit = 36}) async => summaries;

  @override
  Future<bool> isClosed(MonthKey month) async => (await fetch(month)).closed;

  @override
  Stream<MonthSummary> watch(MonthKey month) => _unused();

  @override
  Stream<List<MonthSummary>> watchAll({int limit = 36}) => _unused();
}
