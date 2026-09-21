import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:meta/meta.dart';
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Kategoriya qatori + limit holati (BR-130, BR-131).
typedef CategoryReport = ({
  CategoryLine line,
  LimitStatus? status,
  double? ratio,
});

/// Reja va uning holati (BR-071) — dashboard "yaqin to'lovlar".
typedef PlanReport = ({PlannedItem plan, PlannedStatus status});

/// Bir oyning to'liq hisobi (serverdagi `report_month` ma'nosida) — lokal
/// bazadan, tarmoqsiz (E16 DoD: < 300 ms). Formulalar — `wallet_domain`.
@immutable
final class MonthReport {
  const new({
    required this.month,
    required this.today,
    required this.state,
    required this.facts,
    required this.summary,
    required this.forecast,
    required this.categories,
    required this.incomeTypes,
    required this.openPlans,
    required this.fundBalance,
    required this.savings,
    required this.debts,
    required this.goals,
  });

  final MonthKey month;
  final LocalDate today;
  final MonthState state;
  final MonthFacts facts;
  final MonthSummary summary;
  final MonthForecast forecast;
  final List<CategoryReport> categories;
  final List<IncomeTypeLine> incomeTypes;
  final List<PlanReport> openPlans;

  /// 👤 fond qoldig'i (fond hisobi qoldig'i, BR-063).
  final Money fundBalance;
  final MonthSavings savings;
  final DebtTotals debts;
  final List<(Goal, GoalProgress)> goals;

  bool get isCurrent => month == today.monthKey;

  /// Dashboard "yaqin to'lovlar": xarajat/ajratma rejalari, muddati bo'yicha.
  List<PlanReport> get upcomingPayments => [
    for (final plan in openPlans)
      if (plan.plan.kind != PlanKind.income) plan,
  ];
}

/// [MonthReport] ni lokal bazadan yig'adi.
final class MonthReportLoader {
  const new(
    this._db,
    this._householdId, {
    required this.base,
    required this.today,
  });

  final AppDatabase _db;
  final String _householdId;
  final Currency base;
  final LocalDate today;

  Future<MonthReport> load(MonthKey month) async {
    final reports = _db.reportDao;
    final ledger = _db.ledgerDao;
    final current = today.monthKey;
    final first = await reports.firstRecordMonth(_householdId) ?? month;
    final from = first.isBefore(month) ? first : month;
    final to = month.isAfter(current) ? month : current;

    final history = await ledger.monthFacts(_householdId, from, to, base: base);
    final facts = history.firstWhere((f) => f.month == month);
    final incomePlans = await reports.incomePlans(
      _householdId,
      month,
      base: base,
    );
    // Prognoz tarixi — birinchi yozuvdan (BR-093: boshqa oylar o'rtachasi).
    final withRecords = [
      for (final f in history)
        if (!f.month.isBefore(first)) f,
    ];
    final forecast = MonthForecast.of(
      month: facts,
      today: today,
      history: withRecords,
      incomePlanCount: incomePlans.count,
      incomePlansPending: incomePlans.pending,
    );

    final balances = await ledger.accountBalances(_householdId);
    final accounts = await (_db.select(
      _db.accounts,
    )..where((a) => a.householdId.equals(_householdId))).get();
    final fund = accounts
        .where((a) => a.type == AccountType.personalFund.wire)
        .firstOrNull;

    return MonthReport(
      month: month,
      today: today,
      state: await reports.monthState(_householdId, month),
      facts: facts,
      summary: MonthSummary.of(facts),
      forecast: forecast,
      categories: [
        for (final line in await reports.byCategory(
          _householdId,
          month,
          base: base,
        ))
          (
            line: line,
            status: limitStatus(line.actualTotal, line.limit),
            ratio: limitRatio(line.actualTotal, line.limit),
          ),
      ],
      incomeTypes: await reports.byIncomeType(_householdId, month, base: base),
      openPlans: [
        for (final plan in await reports.openPlans(
          _householdId,
          month,
          base: base,
        ))
          (plan: plan, status: PlannedStatus.of(plan, today)),
      ],
      fundBalance: fund == null
          ? Money(0, base)
          : balances[fund.id] ?? Money(0, base),
      savings: MonthSavings.of(withRecords, month),
      debts: await _debts(month),
      goals: await _goals(withRecords, balances),
    );
  }

  Future<DebtTotals> _debts(MonthKey month) async {
    final activity = await _db.ledgerDao.debtActivity(_householdId);
    final rows =
        await (_db.select(_db.debts)..where(
              (d) => d.householdId.equals(_householdId) & d.deletedAt.isNull(),
            ))
            .get();
    final current = today.monthKey;
    return DebtTotals.of(
      [
        for (final row in rows)
          if (row.toDomain() case final debt)
            (
              debt,
              DebtProgress.of(
                debt,
                paidInApp:
                    activity[debt.id]?.paidInApp ??
                    Money(0, debt.total.currency),
                paymentCount: activity[debt.id]?.paymentCount ?? 0,
                pendingAmount:
                    activity[debt.id]?.pendingAmount ??
                    Money(0, debt.total.currency),
                pendingCount: activity[debt.id]?.pendingCount ?? 0,
                currentMonth: current,
              ),
            ),
      ],
      baseCurrency: base,
      paidThisMonth: await _db.ledgerDao.debtPaymentsIn(
        _householdId,
        month,
        base: base,
      ),
    );
  }

  Future<List<(Goal, GoalProgress)>> _goals(
    List<MonthFacts> history,
    Map<String, Money> balances,
  ) async {
    final rows =
        await (_db.select(_db.goals)..where(
              (g) => g.householdId.equals(_householdId) & g.deletedAt.isNull(),
            ))
            .get();
    final totals = OverallTotals.of(history);
    return [
      for (final row in rows)
        if (row.toDomain() case final goal)
          (
            goal,
            GoalProgress.of(
              goal,
              avgMonthlySaved: totals.avgMonthlySaved,
              currentMonth: today.monthKey,
              accountBalance: goal.accountId == null
                  ? null
                  : balances[goal.accountId],
            ),
          ),
    ];
  }
}
