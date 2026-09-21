import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/dashboard/application/month_report.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Dashboard'da tanlangan oy (standart — joriy oy, byudjet vaqt zonasida).
final NotifierProvider<DashboardMonth, MonthKey> dashboardMonthProvider =
    NotifierProvider(DashboardMonth.new);

final class DashboardMonth extends Notifier<MonthKey> {
  @override
  MonthKey build() => ref.watch(clockProvider).today().monthKey;

  void shift(int months) => state = state.shift(months);

  // Notifier holati tashqaridan o'rnatiladi (oy tanlash).
  // ignore: use_setters_to_change_properties
  void select(MonthKey month) => state = month;
}

/// Tanlangan oy hisobi — lokal bazadan; amallar, rejalar, hisoblar va
/// spravochniklar o'zgarsa (sinxron ham) qayta hisoblanadi.
final StreamProvider<MonthReport?> monthReportProvider = StreamProvider((
  ref,
) async* {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  if (householdId == null || startup is! StartupReady) {
    yield null;
    return;
  }
  final db = ref.watch(appDatabaseProvider);
  final loader = MonthReportLoader(
    db,
    householdId,
    base: startup.currency,
    today: ref.watch(clockProvider).today(),
  );
  final month = ref.watch(dashboardMonthProvider);
  yield await loader.load(month);
  await for (final _ in db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.transactions,
      db.plannedItems,
      db.accounts,
      db.categories,
      db.categoryLimits,
      db.months,
      db.debts,
      db.goals,
    ]),
  )) {
    yield await loader.load(month);
  }
});

/// Dashboard amallari: rejani to'lash (BR-073) va oyni ochish (BR-081).
final Provider<DashboardActions> dashboardActionsProvider = Provider(
  DashboardActions.new,
);

final class DashboardActions {
  const new(this._ref);

  final Ref _ref;

  /// "To'landi" — qolgan summa bilan (serverdagi `pay_planned` qoidasi).
  Future<Result<Transaction>> pay(
    String planId, {
    bool confirmClosedMonth = false,
  }) async {
    final deps = _ref.read(domainDepsProvider);
    if (deps == null) return const Err(UnauthorizedFailure());
    return await PayPlanned(deps)(
      planId,
      confirmClosedMonth: confirmClosedMonth,
    );
  }

  /// Oyni ochish oldidan — yaratiladigan rejalar (server, tarmoq kerak).
  Future<Result<OpenMonthPreview>> preview(MonthKey month) async {
    final householdId = _ref.read(currentHouseholdIdProvider);
    if (householdId == null) return const Err(UnauthorizedFailure());
    return await _ref
        .read(remoteApiProvider)
        .openMonthPreview(householdId, month);
  }

  /// Oyni ochadi va yangi rejalarni sinxron bilan oladi.
  Future<Result<OpenMonthResult>> open(MonthKey month) async {
    final householdId = _ref.read(currentHouseholdIdProvider);
    if (householdId == null) return const Err(UnauthorizedFailure());
    final result = await _ref
        .read(remoteApiProvider)
        .openMonth(householdId, month);
    if (result is Ok) {
      final scheduler = await _ref.read(syncSchedulerProvider.future);
      await scheduler?.refresh();
    }
    return result;
  }
}
