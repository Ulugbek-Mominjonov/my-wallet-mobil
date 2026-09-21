import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/dashboard/application/dashboard_controller.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-160: "yaqin" to'lovlar oynasi — standart 3 kun (E19 da a'zo
/// sozlamasidan).
const int upcomingDays = 3;

/// "To'lovlar" tablari: xarajat (ajratma bilan) va kutilayotgan daromad.
enum PaymentsTab {
  expenses,
  income;

  bool includes(PlannedItem plan) =>
      (plan.kind == PlanKind.income) == (this == income);
}

/// "To'lovlar"da tanlangan oy.
final NotifierProvider<SelectedMonth, MonthKey> paymentsMonthProvider =
    NotifierProvider(SelectedMonth.new);

/// Tanlangan oy rejalari (lokal bazadan, reaktiv).
final StreamProvider<List<PlannedItem>> monthPlansProvider = StreamProvider((
  ref,
) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final startup = ref.watch(startupProvider);
  if (householdId == null || startup is! StartupReady) {
    return Stream.value(const []);
  }
  final base = startup.currency;
  return ref
      .watch(appDatabaseProvider)
      .ledgerDao
      .watchMonthPlans(householdId, ref.watch(paymentsMonthProvider))
      .map((rows) => [for (final row in rows) row.toDomain(base)]);
});

/// Tab bo'limlari va sarlavha jami (BR-071, BR-076); yuklanmoqda — null.
final ProviderFamily<PlanBoard?, PaymentsTab> planBoardProvider =
    Provider.family((ref, tab) {
      final plans = ref.watch(monthPlansProvider).value;
      final startup = ref.watch(startupProvider);
      if (plans == null || startup is! StartupReady) return null;
      return PlanBoard.of(
        plans.where(tab.includes),
        today: ref.watch(clockProvider).today(),
        soonDays: upcomingDays,
        base: startup.currency,
      );
    });

/// Oy holati (ochilgan/yopilgan) — "Oyni ochish" taklifi uchun.
final StreamProvider<MonthState> paymentsMonthStateProvider = StreamProvider((
  ref,
) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return Stream.value((opened: false, closed: false));
  return ref
      .watch(appDatabaseProvider)
      .reportDao
      .watchMonthState(householdId, ref.watch(paymentsMonthProvider));
});

/// Reja amallari (BR-071..084): to'lash, o'tkazib yuborish, yopish, shu oy
/// summasi (lokal, oflayn) va oyni ochish (server, tarmoq kerak).
final Provider<PlanActions> planActionsProvider = Provider(PlanActions.new);

final class PlanActions {
  const new(this._ref);

  final Ref _ref;

  DomainDeps? get _deps => _ref.read(domainDepsProvider);

  /// "To'landi"/"Keldi" — summa standart qolgan (BR-073); [settle] —
  /// qisman to'lovdan keyin "Yopish".
  Future<Result<Transaction>> pay(
    String planId, {
    Money? amount,
    String? accountId,
    LocalDate? date,
    bool settle = false,
    bool confirmClosedMonth = false,
  }) async {
    final deps = _deps;
    if (deps == null) return const Err(UnauthorizedFailure());
    return await PayPlanned(deps)(
      planId,
      amount: amount,
      accountId: accountId,
      date: date,
      settle: settle,
      confirmClosedMonth: confirmClosedMonth,
    );
  }

  Future<Result<PlannedItem>> skip(
    String planId, {
    bool skipped = true,
    bool confirmClosedMonth = false,
  }) async {
    final deps = _deps;
    if (deps == null) return const Err(UnauthorizedFailure());
    return await SkipPlanned(deps)(
      planId,
      skipped: skipped,
      confirmClosedMonth: confirmClosedMonth,
    );
  }

  Future<Result<PlannedItem>> close(
    String planId, {
    bool closed = true,
    bool confirmClosedMonth = false,
  }) async {
    final deps = _deps;
    if (deps == null) return const Err(UnauthorizedFailure());
    return await ClosePlan(deps)(
      planId,
      closed: closed,
      confirmClosedMonth: confirmClosedMonth,
    );
  }

  Future<Result<PlannedItem>> edit(
    String planId, {
    required Money? plannedAmount,
    LocalDate? dueDate,
    bool confirmClosedMonth = false,
  }) async {
    final deps = _deps;
    if (deps == null) return const Err(UnauthorizedFailure());
    return await EditPlan(deps)(
      planId,
      plannedAmount: plannedAmount,
      dueDate: dueDate,
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
