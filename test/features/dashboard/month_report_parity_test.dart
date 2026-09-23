import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/features/dashboard/application/month_report.dart';
import 'package:my_wallet/features/dashboard/application/year_report.dart';
import 'package:wallet_domain/testing.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fixtures.dart';

/// Lokal [MonthReport] → serverdagi `report_month` JSON ko'rinishi
/// (fixture solishtiruvi uchun, contracts/api.md).
Map<String, Object?> _json(MonthReport report) => {
  'month': report.month.toIsoDate(),
  'closed': report.state.closed,
  'is_current': report.isCurrent,
  'totals': {
    'income': report.facts.income.minor,
    'income_card': report.facts.incomeCard.minor,
    'income_cash': report.facts.incomeCash.minor,
    'expense': report.facts.expense.minor,
    'expense_card': report.facts.expenseCard.minor,
    'expense_cash': report.facts.expenseCash.minor,
    'planned': report.facts.planned.minor,
    'unpaid': report.facts.unpaid.minor,
    'unknown_count': report.facts.unknownCount,
    'allocated': report.facts.allocated.minor,
    'fund_spent': report.facts.fundSpent.minor,
  },
  'derived': {
    'balance': report.summary.balance.minor,
    'forecast': report.summary.forecast.minor,
    'saved': report.summary.saved.minor,
    'saved_ratio': report.summary.savedRatio,
    'spent_ratio': report.summary.spentRatio,
    'plan_ratio': report.summary.planRatio,
    'card': report.summary.card.minor,
    'cash': report.summary.cash.minor,
  },
  'projection': {
    'days_in_month': report.forecast.daysInMonth,
    'days_elapsed': report.forecast.daysElapsed,
    'daily_spend': report.forecast.dailySpend.minor,
    'month_end_spend': report.forecast.monthEndSpend.minor,
    'income_received': report.forecast.incomeReceived.minor,
    'income_expected': report.forecast.incomeExpected.minor,
    'income_pending': report.forecast.incomePending,
    'month_end_balance': report.forecast.monthEndBalance.minor,
    'per_day_available': report.forecast.perDayAvailable?.minor,
  },
  'by_type': [
    for (final line in report.incomeTypes)
      {'name': line.name, 'card': line.card.minor, 'cash': line.cash.minor},
  ],
  'by_category': [
    for (final (:line, :status, :ratio) in report.categories)
      {
        'name': line.name,
        'planned': line.planned.minor,
        'actual': line.actual.minor,
        'actual_total': line.actualTotal.minor,
        'limit': line.limit?.minor,
        'limit_carry': line.limitCarry.minor,
        'limit_ratio': ratio,
        'limit_status': status?.name,
      },
  ],
  'unpaid': [
    for (final (:plan, :status) in report.openPlans)
      {
        'name': plan.name,
        'kind': plan.kind.wire,
        'planned_amount': plan.plannedAmount?.minor,
        'paid_amount': plan.paidAmount.minor,
        'due_date': plan.dueDate.toString(),
        'status': status.name,
      },
  ],
  'fund': {
    'allocated': report.facts.allocated.minor,
    'spent': report.facts.fundSpent.minor,
    'balance': report.fundBalance.minor,
  },
  'savings': {
    'before': report.savings.before.minor,
    'this_month': report.savings.thisMonth.minor,
    'total': report.savings.total.minor,
  },
};

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  // BR-092: yillik ko'rinish jami = admin `report_year`.
  group('golden fixture: yillik = report_year', () {
    for (final testCase in fixtureCases()) {
      final steps = [
        for (final step
            in (testCase['expect']! as List).cast<Map<String, Object?>>())
          if (step['rpc'] == 'report_year') step,
      ];
      if (steps.isEmpty) continue;
      test('${testCase['file']}: ${testCase['name']}', () async {
        final ledger = FixtureLedger.load(testCase);
        await storeFixture(db, ledger);
        for (final step in steps) {
          final args = step['args']! as Map<String, Object?>;
          final report = await YearReportLoader(
            db,
            'h',
            base: Currency.uzs,
          ).load(args['year']! as int);
          final totals = report.totals;
          expect(
            compareJson(step['result'], {
              'year': report.year,
              'totals': {
                'income': totals.income.minor,
                'expense': totals.expense.minor,
                'allocated': totals.allocated.minor,
                'fund_spent': totals.fundSpent.minor,
                'balance': totals.summary.balance.minor,
                'saved': totals.summary.saved.minor,
              },
            }, 'report_year'),
            isEmpty,
          );
        }
      });
    }
  });

  // E16 DoD: lokal dashboard raqamlari = admin `report_month` (fixture'lar).
  group('golden fixture: lokal oy hisobi = report_month', () {
    for (final testCase in fixtureCases()) {
      final steps = [
        for (final step
            in (testCase['expect']! as List).cast<Map<String, Object?>>())
          if (step['rpc'] == 'report_month') step,
      ];
      if (steps.isEmpty) continue;
      test('${testCase['file']}: ${testCase['name']}', () async {
        final ledger = FixtureLedger.load(testCase);
        await storeFixture(db, ledger);
        final loader = MonthReportLoader(
          db,
          'h',
          base: Currency.uzs,
          today: ledger.today,
        );
        for (final step in steps) {
          final args = step['args']! as Map<String, Object?>;
          final month = MonthKey.parse(args['month']! as String);
          final report = await loader.load(month);
          expect(
            compareJson(step['result'], _json(report), 'report_month'),
            isEmpty,
          );
        }
      });
    }
  });
}
