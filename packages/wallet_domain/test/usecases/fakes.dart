import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Natija qiymati (xato bo'lsa — test yiqiladi).
T ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('Ok kutilgan, $failure keldi'),
};

/// Natija xatosi (qiymat bo'lsa — test yiqiladi).
Failure err<T>(Result<T> result) => switch (result) {
  Ok(:final value) => fail('Err kutilgan, $value keldi'),
  Err(:final failure) => failure,
};

/// Xotiradagi byudjet — E13 dagi drift implementatsiyasi o'rnida. Har
/// repository — shu umumiy holat ustidagi kichik adapter.
final class FakeStore {
  new({LocalDate? today}) : today = today ?? LocalDate(2026, 10, 5) {
    for (final (id, type, currency) in const [
      ('cash', AccountType.cash, Currency.uzs),
      ('card', AccountType.card, Currency.uzs),
      ('fund', AccountType.personalFund, Currency.uzs),
      ('usd', AccountType.card, Currency.usd),
    ]) {
      accounts[id] = Account(
        id: id,
        householdId: 'h',
        name: id,
        type: type,
        openingBalance: Money(0, currency),
      );
    }
    for (final (id, kind, shift, system) in const [
      ('oylik', CategoryKind.income, -1, null),
      ('avans', CategoryKind.income, 0, null),
      ('food', CategoryKind.expense, 0, null),
      ('self', CategoryKind.expense, 0, SystemCode.personalAllocation),
    ]) {
      categories[id] = Category(
        id: id,
        householdId: 'h',
        kind: kind,
        name: id,
        monthShift: shift,
        systemCode: system,
      );
    }
  }

  final LocalDate today;
  final DateTime now = DateTime.utc(2026, 10, 5, 9);
  Household household = const Household(
    id: 'h',
    name: 'Uy',
    personalFund: PersonalFundRule(),
  );
  final Set<MonthKey> closedMonths = {};
  final Map<String, Account> accounts = {};
  final Map<String, Category> categories = {};
  final Map<String, PlannedItem> plans = {};
  final Map<String, Transaction> transactions = {};
  final Map<String, QuickAction> quickActions = {};
  final Map<String, Debt> debts = {};
  final Map<String, Goal> goals = {};
  final Map<String, CategoryLimit> limits = {};

  /// E29 (BR-191): kurslar — testlarda to'g'ridan-to'g'ri qo'yiladi.
  FxRates rates = FxRates.empty;

  /// Nechta lokal tranzaksiya ochilgan (yozuvlar birga bo'lishi uchun).
  int transactorRuns = 0;
  int _nextId = 0;

  DomainDeps get deps => DomainDeps(
    households: _Households(this),
    accounts: _Accounts(this),
    categories: _Categories(this),
    plans: _Plans(this),
    transactions: _Transactions(this),
    quickActions: _QuickActions(this),
    debts: _Debts(this),
    goals: _Goals(this),
    limits: _Limits(this),
    fx: _FxRates(this),
    transactor: _Transactor(this),
    ids: _Ids(this),
    clock: _Clock(this),
  );
}

final class _FxRates implements FxRateRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<FxRate?> rate(Currency from, Currency to, LocalDate on) async =>
      _store.rates.rate(from, to, on);
}

final class _Households implements HouseholdRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<Household> current() async => _store.household;

  @override
  Future<bool> isMonthClosed(MonthKey month) async =>
      _store.closedMonths.contains(month);
}

final class _Accounts implements AccountRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<Account?> byId(String id) async => _store.accounts[id];

  @override
  Future<Account> personalFund() async =>
      _store.accounts.values.firstWhere((account) => account.isPersonalFund);
}

final class _Categories implements CategoryRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<Category?> byId(String id) async => _store.categories[id];

  @override
  Future<Category> allocationCategory() async =>
      _store.categories.values.firstWhere((category) => category.isSystem);

  @override
  Future<Category?> byName(CategoryKind kind, String name) async => _store
      .categories
      .values
      .where(
        (c) =>
            c.kind == kind &&
            c.deletedAt == null &&
            normalizeName(c.name) == normalizeName(name),
      )
      .firstOrNull;

  @override
  Future<void> save(Category category) async =>
      _store.categories[category.id] = category;
}

final class _Plans implements PlannedItemRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<PlannedItem?> byId(String id) async => _store.plans[id];

  @override
  Future<void> save(PlannedItem item) async => _store.plans[item.id] = item;
}

final class _Transactions implements TransactionRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<Transaction?> byId(String id) async => _store.transactions[id];

  @override
  Future<void> save(Transaction transaction) async =>
      _store.transactions[transaction.id] = transaction;
}

final class _QuickActions implements QuickActionRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<QuickAction?> byId(String id) async => _store.quickActions[id];
}

final class _Debts implements DebtRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<Debt?> byId(String id) async => _store.debts[id];

  @override
  Future<Debt?> byName(String name) async => _store.debts.values
      .where(
        (d) =>
            d.deletedAt == null && normalizeName(d.name) == normalizeName(name),
      )
      .firstOrNull;

  @override
  Future<void> save(Debt debt) async => _store.debts[debt.id] = debt;
}

final class _Goals implements GoalRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<Goal?> byId(String id) async => _store.goals[id];

  @override
  Future<Goal?> byName(String name) async => _store.goals.values
      .where(
        (g) =>
            g.deletedAt == null && normalizeName(g.name) == normalizeName(name),
      )
      .firstOrNull;

  @override
  Future<void> save(Goal goal) async => _store.goals[goal.id] = goal;
}

final class _Limits implements CategoryLimitRepository {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<CategoryLimit?> forCategory(String categoryId) async => _store
      .limits
      .values
      .where((l) => l.categoryId == categoryId && l.deletedAt == null)
      .firstOrNull;

  @override
  Future<void> save(CategoryLimit limit) async =>
      _store.limits[limit.id] = limit;
}

final class _Transactor implements Transactor {
  const new(this._store);
  final FakeStore _store;

  @override
  Future<T> run<T>(Future<T> Function() action) {
    _store.transactorRuns++;
    return action();
  }
}

final class _Ids implements IdGenerator {
  const new(this._store);
  final FakeStore _store;

  @override
  String newId() => 'id-${_store._nextId++}';
}

final class _Clock implements Clock {
  const new(this._store);
  final FakeStore _store;

  @override
  LocalDate today() => _store.today;

  @override
  DateTime now() => _store.now;
}
