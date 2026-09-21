import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;
import 'package:meta/meta.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

typedef AccountLine = ({Account account, Money balance});

/// BR-020..025: hisoblar va qoldiqlar. Jami — valyuta bo'yicha, 👤 fond
/// hisobisiz (BR-005: fond boshqa pullar bilan bitta "jami"ga qo'shilmaydi).
@immutable
final class AccountsReport {
  const new(this.lines);

  /// Turi, keyin tartib bo'yicha; arxivlanganlar yo'q.
  final List<AccountLine> lines;

  AccountLine? get fund =>
      lines.where((l) => l.account.isPersonalFund).firstOrNull;

  /// Fondsiz jami — valyuta bo'yicha.
  Map<Currency, Money> get totals {
    final totals = <Currency, Money>{};
    for (final (:account, :balance) in lines) {
      if (account.isPersonalFund) continue;
      totals[balance.currency] =
          (totals[balance.currency] ?? Money(0, balance.currency)) + balance;
    }
    return totals;
  }

  /// BR-025: manfiy naqd hisoblar.
  List<AccountLine> get negativeCash => [
    for (final line in lines)
      if (line.account.type == AccountType.cash && line.balance.isNegative)
        line,
  ];
}

typedef FundMonth = ({MonthKey month, Money allocated, Money spent});

/// BR-063, BR-064 (serverdagi `report_personal_fund`): 👤 fond qoldig'i,
/// jami ajratilgan/sarflangan va oylar kesimi.
@immutable
final class FundReport {
  const new({
    required this.balance,
    required this.totalAllocated,
    required this.totalSpent,
    required this.months,
  });

  final Money balance;
  final Money totalAllocated;
  final Money totalSpent;

  /// Xronologik.
  final List<FundMonth> months;
}

/// BR-100..102, BR-092 (serverdagi `report_savings`): 🏦 jamg'arma jadvali
/// va barcha oylar jami.
@immutable
final class SavingsReport {
  const new({required this.rows, required this.totals});

  /// Xronologik; oxirgisi — joriy oy (⏳).
  final List<SavingsRow> rows;
  final OverallTotals totals;
}

typedef DebtLine = ({Debt debt, DebtProgress progress});

/// BR-112..116 (serverdagi `report_debts`).
@immutable
final class DebtsReport {
  const new({required this.lines, required this.totals});

  /// Arxivlanganlar ham (ro'yxatda alohida); jamlarga kirmaydi.
  final List<DebtLine> lines;
  final DebtTotals totals;
}

typedef GoalLine = ({Goal goal, GoalProgress progress});

/// BR-120..122 (serverdagi `report_goals`).
@immutable
final class GoalsReport {
  const new({required this.avgMonthlySaved, required this.lines});

  final Money avgMonthlySaved;
  final List<GoalLine> lines;
}

/// "Hamyon" hisobotlari lokal bazadan — serverdagi hisobotlar bilan bir xil
/// ma'no (golden fixture'lar bilan qotirilgan); formulalar `wallet_domain`da.
final class WalletReportLoader {
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

  MonthKey get _current => today.monthKey;

  /// Birinchi yozuvdan joriy oygacha oylar (serverdagi hisobotlar oralig'i).
  Future<List<MonthFacts>> history() async {
    final first = (await _db.reportDao.recordMonths(_householdId))?.first;
    final from = first == null || first.isAfter(_current) ? _current : first;
    return await _db.ledgerDao.monthFacts(
      _householdId,
      from,
      _current,
      base: base,
    );
  }

  Future<AccountsReport> accounts() async {
    final balances = await _db.ledgerDao.accountBalances(_householdId);
    final rows =
        await (_db.select(_db.accounts)
              ..where(
                (a) =>
                    a.householdId.equals(_householdId) &
                    a.deletedAt.isNull() &
                    a.archivedAt.isNull(),
              )
              ..orderBy([
                (a) => OrderingTerm.asc(a.sortOrder),
                (a) => OrderingTerm.asc(a.name),
              ]))
            .get();
    final lines = [
      for (final row in rows)
        if (row.toDomain() case final account)
          (
            account: account,
            balance:
                balances[account.id] ??
                Money(0, account.openingBalance.currency),
          ),
    ]..sort((a, b) => a.account.type.index.compareTo(b.account.type.index));
    return AccountsReport(lines);
  }

  Future<FundReport> fund({
    required MonthKey from,
    required MonthKey to,
  }) async {
    final balances = await _db.ledgerDao.accountBalances(_householdId);
    final fundAccount = await _fundAccount();
    // Jami — butun tarix bo'yicha (kelgusi oylarga yozilganlar ham).
    final range = await _db.reportDao.recordMonths(_householdId);
    final all = range == null
        ? const <MonthFacts>[]
        : await _db.ledgerDao.monthFacts(
            _householdId,
            range.first,
            range.last,
            base: base,
          );
    final months = await _db.ledgerDao.monthFacts(
      _householdId,
      from,
      to,
      base: base,
    );
    return FundReport(
      balance: fundAccount == null
          ? Money(0, base)
          : balances[fundAccount.id] ?? Money(0, base),
      totalAllocated: Money.sum(all.map((m) => m.allocated), base),
      totalSpent: Money.sum(all.map((m) => m.fundSpent), base),
      months: [
        for (final m in months)
          (month: m.month, allocated: m.allocated, spent: m.fundSpent),
      ],
    );
  }

  Future<SavingsReport> savings() async {
    final months = await history();
    return SavingsReport(
      rows: savingsTable(months, current: _current),
      totals: OverallTotals.of(months),
    );
  }

  /// [paidIn] — "shu oyda qarzga to'langan" oyi (standart — joriy oy).
  Future<DebtsReport> debts({MonthKey? paidIn}) async {
    final activity = await _db.ledgerDao.debtActivity(_householdId);
    final rows =
        await (_db.select(_db.debts)
              ..where(
                (d) =>
                    d.householdId.equals(_householdId) & d.deletedAt.isNull(),
              )
              ..orderBy([(d) => OrderingTerm.asc(d.name)]))
            .get();
    final lines = <DebtLine>[
      for (final row in rows)
        if (row.toDomain() case final debt)
          (
            debt: debt,
            progress: DebtProgress.of(
              debt,
              paidInApp:
                  activity[debt.id]?.paidInApp ?? Money(0, debt.total.currency),
              paymentCount: activity[debt.id]?.paymentCount ?? 0,
              pendingAmount:
                  activity[debt.id]?.pendingAmount ??
                  Money(0, debt.total.currency),
              pendingCount: activity[debt.id]?.pendingCount ?? 0,
              currentMonth: _current,
            ),
          ),
    ];
    return DebtsReport(
      lines: lines,
      totals: DebtTotals.of(
        [for (final line in lines) (line.debt, line.progress)],
        baseCurrency: base,
        paidThisMonth: await _db.ledgerDao.debtPaymentsIn(
          _householdId,
          paidIn ?? _current,
          base: base,
        ),
      ),
    );
  }

  /// [history] — oldindan yuklangan oylar (bo'lmasa — yuklanadi).
  Future<GoalsReport> goals({List<MonthFacts>? history}) async {
    final months = history ?? await this.history();
    final average = OverallTotals.of(months).avgMonthlySaved;
    final balances = await _db.ledgerDao.accountBalances(_householdId);
    final rows =
        await (_db.select(_db.goals)
              ..where(
                (g) =>
                    g.householdId.equals(_householdId) & g.deletedAt.isNull(),
              )
              ..orderBy([
                (g) => OrderingTerm.asc(g.sortOrder),
                (g) => OrderingTerm.asc(g.name),
              ]))
            .get();
    return GoalsReport(
      avgMonthlySaved: average,
      lines: [
        for (final row in rows)
          if (row.toDomain() case final goal)
            (
              goal: goal,
              progress: GoalProgress.of(
                goal,
                avgMonthlySaved: average,
                currentMonth: _current,
                accountBalance: goal.accountId == null
                    ? null
                    : balances[goal.accountId],
              ),
            ),
      ],
    );
  }

  Future<AccountRow?> _fundAccount() =>
      (_db.select(_db.accounts)..where(
            (a) =>
                a.householdId.equals(_householdId) &
                a.type.equals(AccountType.personalFund.wire),
          ))
          .getSingleOrNull();
}
