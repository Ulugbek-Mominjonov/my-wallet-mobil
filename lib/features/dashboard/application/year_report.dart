import 'package:meta/meta.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Yil oyi: faktlar, hosila ko'rsatkichlar va yopilganmi (BR-092, BR-150).
typedef YearMonth = ({MonthFacts facts, MonthSummary summary, bool closed});

/// Yillik ko'rinish (serverdagi `report_year` ma'nosida) — lokal bazadan.
@immutable
final class YearReport {
  const new({required this.year, required this.months, required this.totals});

  final int year;
  final List<YearMonth> months;
  final ({
    Money income,
    Money expense,
    Money allocated,
    Money fundSpent,
    MonthSummary summary,
  })
  totals;

  /// Yozuvi bor oylar (bo'sh oylar grafikda ko'rsatilmaydi).
  Iterable<YearMonth> get active => months.where((m) => m.facts.hasRecords);
}

final class YearReportLoader {
  const new(this._db, this._householdId, {required this.base});

  final AppDatabase _db;
  final String _householdId;
  final Currency base;

  Future<YearReport> load(int year) async {
    final facts = await _db.ledgerDao.monthFacts(
      _householdId,
      MonthKey(year, 1),
      MonthKey(year, 12),
      base: base,
    );
    final closed = await _db.reportDao.closedMonths(_householdId, year);
    Money sum(Money Function(MonthFacts) of) => Money.sum(facts.map(of), base);
    final income = sum((m) => m.income);
    final expense = sum((m) => m.expense);
    final allocated = sum((m) => m.allocated);
    final fundSpent = sum((m) => m.fundSpent);
    return YearReport(
      year: year,
      months: [
        for (final month in facts)
          (
            facts: month,
            summary: MonthSummary.of(month),
            closed: closed.contains(month.month),
          ),
      ],
      totals: (
        income: income,
        expense: expense,
        allocated: allocated,
        fundSpent: fundSpent,
        summary: MonthSummary.fromTotals(
          income: income,
          expense: expense,
          unpaid: sum((m) => m.unpaid),
          allocated: allocated,
          fundSpent: fundSpent,
          planned: sum((m) => m.planned),
        ),
      ),
    );
  }
}
