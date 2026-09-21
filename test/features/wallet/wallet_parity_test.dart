import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/features/wallet/application/wallet_reports.dart';
import 'package:wallet_domain/testing.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fixtures.dart';

// E18: "Hamyon" hisobotlari lokal bazadan = admin hisobotlari (golden
// fixture'lar, contracts/api.md ko'rinishida solishtiriladi).

Future<Map<String, Object?>> _rpc(
  WalletReportLoader loader,
  String rpc,
  Map<String, Object?> args,
) async => switch (rpc) {
  'report_savings' => _savings(await loader.savings()),
  'report_personal_fund' => _fund(
    await loader.fund(
      from: MonthKey.parse(args['from']! as String),
      to: MonthKey.parse(args['to']! as String),
    ),
  ),
  'report_debts' => _debts(await loader.debts()),
  'report_goals' => _goals(await loader.goals()),
  _ => throw ArgumentError.value(rpc, 'rpc'),
};

Map<String, Object?> _savings(SavingsReport report) => {
  'months': [
    for (final row in report.rows)
      {
        'month': row.month.toIsoDate(),
        'income': row.income.minor,
        'expense': row.expense.minor,
        'balance': row.balance.minor,
        'accumulated': row.accumulated.minor,
        'is_current': row.isCurrent,
      },
  ],
  'summary': {
    'months_count': report.totals.monthsCount,
    'total_income': report.totals.totalIncome.minor,
    'total_expense': report.totals.totalExpense.minor,
    'total_balance': report.totals.totalBalance.minor,
    'total_saved': report.totals.totalSaved.minor,
    'avg_monthly_saved': report.totals.avgMonthlySaved.minor,
    'avg_monthly_expense': report.totals.avgMonthlyExpense.minor,
  },
};

Map<String, Object?> _fund(FundReport report) => {
  'balance': report.balance.minor,
  'total_allocated': report.totalAllocated.minor,
  'total_spent': report.totalSpent.minor,
  'months': [
    for (final m in report.months)
      {
        'month': m.month.toIsoDate(),
        'allocated': m.allocated.minor,
        'spent': m.spent.minor,
      },
  ],
};

Map<String, Object?> _debts(DebtsReport report) => {
  'debts': [
    for (final (:debt, :progress) in report.lines)
      {
        'name': debt.name,
        'direction': debt.direction.wire,
        'total': debt.total.minor,
        'paid_before': debt.paidBefore.minor,
        'monthly_payment': debt.monthlyPayment?.minor,
        'archived': debt.archivedAt != null,
        'paid_in_app': progress.paidInApp.minor,
        'pending_amount': progress.pendingAmount.minor,
        'pending_count': progress.pendingCount,
        'remaining': progress.remaining.minor,
        'progress': progress.progress,
        'months_left': progress.monthsLeft,
        'end_month': progress.endMonth?.toIsoDate(),
        'status': progress.status.name,
      },
  ],
  'totals': {
    'i_owe': report.totals.iOwe.minor,
    'owed_to_me': report.totals.owedToMe.minor,
    'monthly_obligation': report.totals.monthlyObligation.minor,
    'net': report.totals.net.minor,
    'paid_this_month': report.totals.paidThisMonth.minor,
  },
};

Map<String, Object?> _goals(GoalsReport report) => {
  'avg_monthly_saved': report.avgMonthlySaved.minor,
  'goals': [
    for (final (:goal, :progress) in report.lines)
      {
        'name': goal.name,
        'target': goal.target.minor,
        'saved': progress.saved.minor,
        'remaining': progress.remaining.minor,
        'progress': progress.progress,
        'monthly': progress.monthly?.minor,
        'monthly_source': progress.monthlySource?.name,
        'months_left': progress.monthsLeft,
        'end_month': progress.endMonth?.toIsoDate(),
        'deadline': goal.deadline?.toIsoDate(),
        'on_track': progress.onTrack,
      },
  ],
};

const _rpcs = {
  'report_savings',
  'report_personal_fund',
  'report_debts',
  'report_goals',
};

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('golden fixture: Hamyon = admin hisobotlari', () {
    for (final testCase in fixtureCases()) {
      final steps = [
        for (final step
            in (testCase['expect']! as List).cast<Map<String, Object?>>())
          if (_rpcs.contains(step['rpc'])) step,
      ];
      if (steps.isEmpty) continue;
      test('${testCase['file']}: ${testCase['name']}', () async {
        final ledger = FixtureLedger.load(testCase);
        await storeFixture(db, ledger);
        final loader = WalletReportLoader(
          db,
          'h',
          base: Currency.uzs,
          today: ledger.today,
        );
        for (final step in steps) {
          final rpc = step['rpc']! as String;
          final actual = await _rpc(
            loader,
            rpc,
            (step['args'] as Map<String, Object?>?) ?? const {},
          );
          expect(compareJson(step['result'], actual, rpc), isEmpty);
        }
      });
    }
  });
}
