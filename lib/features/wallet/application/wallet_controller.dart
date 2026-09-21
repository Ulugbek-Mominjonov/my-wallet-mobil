import 'package:drift/drift.dart' show Table, TableInfo, TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Joriy byudjet uchun hisobotlar yuklovchisi (tanlanmagan — null).
final Provider<WalletReportLoader?> walletLoaderProvider = Provider((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  if (householdId == null || startup is! StartupReady) return null;
  return WalletReportLoader(
    ref.watch(appDatabaseProvider),
    householdId,
    base: startup.currency,
    today: ref.watch(clockProvider).today(),
  );
});

/// Hisobot — [tables] o'zgarsa (yozuv yoki sinxron) qayta hisoblanadi.
Stream<T?> _watch<T>(
  Ref ref,
  Set<TableInfo<Table, Object?>> Function(AppDatabase db) tables,
  Future<T> Function(WalletReportLoader loader) load,
) async* {
  final loader = ref.watch(walletLoaderProvider);
  if (loader == null) {
    yield null;
    return;
  }
  final db = ref.watch(appDatabaseProvider);
  yield await load(loader);
  await for (final _ in db.tableUpdates(
    TableUpdateQuery.onAllTables(tables(db)),
  )) {
    yield await load(loader);
  }
}

final StreamProvider<AccountsReport?> accountsReportProvider = StreamProvider(
  (ref) => _watch(
    ref,
    (db) => {db.accounts, db.transactions},
    (loader) => loader.accounts(),
  ),
);

/// Fond: oxirgi 6 oy kesimi (joriy oy bilan).
const int fundHistoryMonths = 6;

final StreamProvider<FundReport?> fundReportProvider = StreamProvider((ref) {
  final current = ref.watch(clockProvider).today().monthKey;
  return _watch(
    ref,
    (db) => {db.accounts, db.transactions},
    (loader) =>
        loader.fund(from: current.shift(1 - fundHistoryMonths), to: current),
  );
});

final StreamProvider<SavingsReport?> savingsReportProvider = StreamProvider(
  (ref) => _watch(
    ref,
    (db) => {db.accounts, db.transactions, db.plannedItems},
    (loader) => loader.savings(),
  ),
);

final StreamProvider<DebtsReport?> debtsReportProvider = StreamProvider(
  (ref) => _watch(
    ref,
    (db) => {db.debts, db.transactions, db.plannedItems},
    (loader) => loader.debts(),
  ),
);

final StreamProvider<GoalsReport?> goalsReportProvider = StreamProvider(
  (ref) => _watch(
    ref,
    (db) => {db.goals, db.accounts, db.transactions, db.plannedItems},
    (loader) => loader.goals(),
  ),
);

final StreamProvider<FundAllocation?> fundAllocationProvider = StreamProvider(
  (ref) => _watch<FundAllocation?>(
    ref,
    (db) => {db.households, db.plannedItems, db.transactions},
    (loader) => loader.allocation(),
  ),
);

final StreamProvider<List<LimitLine>?> limitsProvider = StreamProvider(
  (ref) => _watch(
    ref,
    (db) => {db.categories, db.categoryLimits, db.transactions, db.accounts},
    (loader) => loader.limits(),
  ),
);

/// BR-130: limitlarni faqat owner/admin o'zgartiradi (server RLS bilan bir
/// xil); qarz va maqsad — member ham.
final Provider<bool> canManageLimitsProvider = Provider((ref) {
  final startup = ref.watch(startupProvider);
  return startup is StartupReady &&
      (startup.household.role == MemberRole.owner ||
          startup.household.role == MemberRole.admin);
});

/// Hamyon yozuvlari (lokal, oflayn; outbox orqali serverga).
final Provider<WalletActions> walletActionsProvider = Provider(
  WalletActions.new,
);

final class WalletActions {
  const new(this._ref);

  final Ref _ref;

  Future<Result<T>> _run<T>(
    Future<Result<T>> Function(DomainDeps deps) action,
  ) async {
    final deps = _ref.read(domainDepsProvider);
    if (deps == null) return const Err(UnauthorizedFailure());
    return await action(deps);
  }

  Future<Result<Debt>> saveDebt(DebtInput input, {String? id}) =>
      _run((deps) => SaveDebt(deps)(input, id: id));

  Future<Result<Debt>> archiveDebt(String id, {required bool archived}) =>
      _run((deps) => SetDebtArchived(deps)(id, archived: archived));

  Future<Result<Goal>> saveGoal(GoalInput input, {String? id}) =>
      _run((deps) => SaveGoal(deps)(input, id: id));

  Future<Result<Goal>> deleteGoal(String id) =>
      _run((deps) => DeleteGoal(deps)(id));

  Future<Result<Goal>> markAchieved(String id) =>
      _run((deps) => MarkGoalAchieved(deps)(id));

  Future<Result<CategoryLimit?>> setLimit(
    String categoryId, {
    required Money? amount,
  }) => _run((deps) => SetCategoryLimit(deps)(categoryId, amount: amount));
}
