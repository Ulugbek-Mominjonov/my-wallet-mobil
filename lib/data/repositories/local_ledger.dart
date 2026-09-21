import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/local/outbox_writer.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import 'package:wallet_domain/wallet_domain.dart';

// Domen repository interfeyslarining lokal (drift) implementatsiyasi — joriy
// byudjet doirasida. Yozuv: qator + outbox mutatsiyasi bitta tranzaksiyada
// (`DriftTransactor` ichida use-case chaqiradi; `save` o'zi ham atomar).

/// Joriy byudjet uchun use-case bog'liqliklari.
DomainDeps localDomainDeps(
  AppDatabase db, {
  required String householdId,
  required Clock clock,
  IdGenerator ids = const UuidV7Ids(),
}) {
  final outbox = OutboxWriter(db, newId: ids.newId, now: clock.now);
  return DomainDeps(
    households: DriftHouseholdRepository(db, householdId),
    accounts: DriftAccountRepository(db, householdId),
    categories: DriftCategoryRepository(db, householdId, outbox),
    plans: DriftPlannedItemRepository(db, householdId, outbox),
    transactions: DriftTransactionRepository(db, householdId, outbox),
    quickActions: DriftQuickActionRepository(db, householdId),
    debts: DriftDebtRepository(db, householdId, outbox),
    goals: DriftGoalRepository(db, householdId, outbox),
    limits: DriftCategoryLimitRepository(db, householdId, outbox),
    transactor: DriftTransactor(db),
    ids: ids,
    clock: clock,
  );
}

final class DriftTransactor implements Transactor {
  const new(this._db);
  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) => _db.transaction(action);
}

/// UUIDv7 — vaqt bo'yicha tartiblangan (ADR-07, indeks lokalligi).
final class UuidV7Ids implements IdGenerator {
  const new();

  @override
  String newId() => const Uuid().v7();
}

/// BR-002: "bugun" — byudjet vaqt zonasida (IANA), `now` — UTC.
final class TzClock implements Clock {
  new(String timezone, {DateTime Function()? utcNow})
    : _location = locationOf(timezone),
      _utcNow = utcNow ?? (() => DateTime.now().toUtc());

  final tz.Location _location;
  final DateTime Function() _utcNow;

  static var _initialized = false;

  /// Hozir — byudjet vaqt zonasida (rejali eslatmalar uchun).
  tz.TZDateTime localNow() => tz.TZDateTime.from(_utcNow(), _location);

  static tz.Location locationOf(String timezone) {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
    return tz.getLocation(timezone);
  }

  @override
  LocalDate today() =>
      LocalDate.fromDateTime(tz.TZDateTime.from(_utcNow(), _location));

  @override
  DateTime now() => _utcNow();
}

/// Byudjet sozlamalari sinxrondan keladi; bo'lmasa — oqim xatosi (ekran
/// sinxrondan oldin ochilgan).
Future<HouseholdRow> _household(AppDatabase db, String householdId) async {
  final row = await (db.select(
    db.households,
  )..where((h) => h.id.equals(householdId))).getSingleOrNull();
  if (row == null) {
    throw StateError("Byudjet lokal bazada yo'q (sinxron kerak): $householdId");
  }
  return row;
}

Future<Currency> _baseCurrency(AppDatabase db, String householdId) async =>
    currencyOfCode((await _household(db, householdId)).baseCurrency);

final class DriftHouseholdRepository implements HouseholdRepository {
  const new(this._db, this._householdId);
  final AppDatabase _db;
  final String _householdId;

  @override
  Future<Household> current() async =>
      (await _household(_db, _householdId)).toDomain();

  @override
  Future<bool> isMonthClosed(MonthKey month) async {
    final row =
        await (_db.select(_db.months)..where(
              (m) =>
                  m.householdId.equals(_householdId) &
                  m.month.equals(month.toIsoDate()),
            ))
            .getSingleOrNull();
    return row?.closedAt != null;
  }
}

final class DriftAccountRepository implements AccountRepository {
  const new(this._db, this._householdId);
  final AppDatabase _db;
  final String _householdId;

  @override
  Future<Account?> byId(String id) async =>
      (await (_db.select(_db.accounts)..where(
                (a) => a.householdId.equals(_householdId) & a.id.equals(id),
              ))
              .getSingleOrNull())
          ?.toDomain();

  @override
  Future<Account> personalFund() async =>
      (await (_db.select(_db.accounts)..where(
                (a) =>
                    a.householdId.equals(_householdId) &
                    a.type.equals(AccountType.personalFund.wire) &
                    a.deletedAt.isNull(),
              ))
              .getSingle())
          .toDomain();
}

final class DriftCategoryRepository implements CategoryRepository {
  const new(this._db, this._householdId, this._outbox);
  final AppDatabase _db;
  final String _householdId;
  final OutboxWriter _outbox;

  @override
  Future<Category?> byId(String id) async =>
      (await (_db.select(_db.categories)..where(
                (c) => c.householdId.equals(_householdId) & c.id.equals(id),
              ))
              .getSingleOrNull())
          ?.toDomain();

  @override
  Future<Category> allocationCategory() async =>
      (await (_db.select(_db.categories)..where(
                (c) =>
                    c.householdId.equals(_householdId) &
                    c.systemCode.equals(SystemCode.personalAllocation.wire),
              ))
              .getSingle())
          .toDomain();

  @override
  Future<Category?> byName(CategoryKind kind, String name) async =>
      (await (_db.select(_db.categories)..where(
                (c) =>
                    c.householdId.equals(_householdId) &
                    c.kind.equals(kind.wire) &
                    c.deletedAt.isNull() &
                    c.name.lower().equals(normalizeName(name)),
              ))
              .getSingleOrNull())
          ?.toDomain();

  @override
  Future<void> save(Category category) => _db.transaction(() async {
    final query = _db.select(_db.categories)
      ..where((c) => c.id.equals(category.id));
    final before = await query.getSingleOrNull();
    await _db
        .into(_db.categories)
        .insertOnConflictUpdate(category.toCompanion());
    await _outbox.enqueue(
      table: 'categories',
      householdId: _householdId,
      row: await query.getSingle(),
      before: before,
    );
  });
}

final class DriftPlannedItemRepository implements PlannedItemRepository {
  const new(this._db, this._householdId, this._outbox);
  final AppDatabase _db;
  final String _householdId;
  final OutboxWriter _outbox;

  @override
  Future<PlannedItem?> byId(String id) async {
    final row =
        await (_db.select(_db.plannedItems)..where(
              (p) => p.householdId.equals(_householdId) & p.id.equals(id),
            ))
            .getSingleOrNull();
    return row?.toDomain(await _baseCurrency(_db, _householdId));
  }

  @override
  Future<void> save(PlannedItem item) => _db.transaction(() async {
    final query = _db.select(_db.plannedItems)
      ..where((p) => p.id.equals(item.id));
    final before = await query.getSingleOrNull();
    await _db.into(_db.plannedItems).insertOnConflictUpdate(item.toCompanion());
    await _outbox.enqueue(
      table: 'planned_items',
      householdId: _householdId,
      row: await query.getSingle(),
      before: before,
    );
  });
}

final class DriftTransactionRepository implements TransactionRepository {
  const new(this._db, this._householdId, this._outbox);
  final AppDatabase _db;
  final String _householdId;
  final OutboxWriter _outbox;

  @override
  Future<Transaction?> byId(String id) async {
    final row =
        await (_db.select(_db.transactions)..where(
              (t) => t.householdId.equals(_householdId) & t.id.equals(id),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    Future<Currency?> currencyOf(String? accountId) async {
      if (accountId == null) return null;
      final account = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(accountId))).getSingleOrNull();
      return account == null ? null : currencyOfCode(account.currency);
    }

    final base = await _baseCurrency(_db, _householdId);
    return row.toDomain(
      accountCurrency: await currencyOf(row.accountId) ?? base,
      base: base,
      toCurrency: await currencyOf(row.toAccountId),
    );
  }

  @override
  Future<void> save(Transaction transaction) => _db.transaction(() async {
    final query = _db.select(_db.transactions)
      ..where((t) => t.id.equals(transaction.id));
    final before = await query.getSingleOrNull();
    await _db
        .into(_db.transactions)
        .insertOnConflictUpdate(transaction.toCompanion());
    await _outbox.enqueue(
      table: 'transactions',
      householdId: _householdId,
      row: await query.getSingle(),
      before: before,
    );
  });
}

final class DriftDebtRepository implements DebtRepository {
  const new(this._db, this._householdId, this._outbox);
  final AppDatabase _db;
  final String _householdId;
  final OutboxWriter _outbox;

  @override
  Future<Debt?> byId(String id) async =>
      (await (_db.select(_db.debts)..where(
                (d) => d.householdId.equals(_householdId) & d.id.equals(id),
              ))
              .getSingleOrNull())
          ?.toDomain();

  @override
  Future<Debt?> byName(String name) async =>
      (await (_db.select(_db.debts)..where(
                (d) =>
                    d.householdId.equals(_householdId) &
                    d.deletedAt.isNull() &
                    d.name.lower().equals(normalizeName(name)),
              ))
              .getSingleOrNull())
          ?.toDomain();

  @override
  Future<void> save(Debt debt) => _db.transaction(() async {
    final query = _db.select(_db.debts)..where((d) => d.id.equals(debt.id));
    final before = await query.getSingleOrNull();
    await _db.into(_db.debts).insertOnConflictUpdate(debt.toCompanion());
    await _outbox.enqueue(
      table: 'debts',
      householdId: _householdId,
      row: await query.getSingle(),
      before: before,
    );
  });
}

final class DriftGoalRepository implements GoalRepository {
  const new(this._db, this._householdId, this._outbox);
  final AppDatabase _db;
  final String _householdId;
  final OutboxWriter _outbox;

  @override
  Future<Goal?> byId(String id) async =>
      (await (_db.select(_db.goals)..where(
                (g) => g.householdId.equals(_householdId) & g.id.equals(id),
              ))
              .getSingleOrNull())
          ?.toDomain();

  @override
  Future<Goal?> byName(String name) async =>
      (await (_db.select(_db.goals)..where(
                (g) =>
                    g.householdId.equals(_householdId) &
                    g.deletedAt.isNull() &
                    g.name.lower().equals(normalizeName(name)),
              ))
              .getSingleOrNull())
          ?.toDomain();

  @override
  Future<void> save(Goal goal) => _db.transaction(() async {
    final query = _db.select(_db.goals)..where((g) => g.id.equals(goal.id));
    final before = await query.getSingleOrNull();
    await _db.into(_db.goals).insertOnConflictUpdate(goal.toCompanion());
    await _outbox.enqueue(
      table: 'goals',
      householdId: _householdId,
      row: await query.getSingle(),
      before: before,
    );
  });
}

final class DriftCategoryLimitRepository implements CategoryLimitRepository {
  const new(this._db, this._householdId, this._outbox);
  final AppDatabase _db;
  final String _householdId;
  final OutboxWriter _outbox;

  @override
  Future<CategoryLimit?> forCategory(String categoryId) async {
    final row =
        await (_db.select(_db.categoryLimits)..where(
              (l) =>
                  l.householdId.equals(_householdId) &
                  l.categoryId.equals(categoryId) &
                  l.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row?.toDomain(await _baseCurrency(_db, _householdId));
  }

  @override
  Future<void> save(CategoryLimit limit) => _db.transaction(() async {
    final query = _db.select(_db.categoryLimits)
      ..where((l) => l.id.equals(limit.id));
    final before = await query.getSingleOrNull();
    await _db
        .into(_db.categoryLimits)
        .insertOnConflictUpdate(limit.toCompanion());
    await _outbox.enqueue(
      table: 'category_limits',
      householdId: _householdId,
      row: await query.getSingle(),
      before: before,
    );
  });
}

final class DriftQuickActionRepository implements QuickActionRepository {
  const new(this._db, this._householdId);
  final AppDatabase _db;
  final String _householdId;

  @override
  Future<QuickAction?> byId(String id) async {
    final row =
        await (_db.select(_db.quickActions)..where(
              (q) => q.householdId.equals(_householdId) & q.id.equals(id),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(row.accountId))).getSingleOrNull();
    return row.toDomain(
      account == null
          ? await _baseCurrency(_db, _householdId)
          : currencyOfCode(account.currency),
    );
  }
}
