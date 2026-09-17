import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('§2.1 daromadning tegishli oyi', () {
    const rules = IncomeRules.defaults;

    test('DoD: 1-sentabrdagi "Oylik" AVGUST byudjetiga tushadi', () {
      expect(
        MonthAttribution.forIncome(
          paidAt: DateTime(2026, 9),
          type: 'Oylik',
          rules: rules,
        ),
        const MonthKey('2026-08'),
      );
    });

    test('KPI ham oldingi oyga', () {
      expect(
        MonthAttribution.forIncome(
          paidAt: DateTime(2026, 9, 6),
          type: 'KPI',
          rules: rules,
        ),
        const MonthKey('2026-08'),
      );
    });

    test('Avans joriy oyda qoladi', () {
      expect(
        MonthAttribution.forIncome(
          paidAt: DateTime(2026, 9, 16),
          type: 'Avans',
          rules: rules,
        ),
        const MonthKey('2026-09'),
      );
    });

    test("noma'lum tur — joriy oy (Sheets bilan bir xil)", () {
      expect(
        MonthAttribution.forIncome(
          paidAt: DateTime(2026, 9, 16),
          type: "Sovg'a",
          rules: rules,
        ),
        const MonthKey('2026-09'),
      );
    });

    test('tur nomi katta-kichik harfga sezgir emas', () {
      expect(rules.shiftFor('  oYLIK '), -1);
    });

    test("yanvarda olingan oylik — o'tgan yilning dekabri", () {
      expect(
        MonthAttribution.forIncome(
          paidAt: DateTime(2026, 1, 2),
          type: 'Oylik',
          rules: rules,
        ),
        const MonthKey('2025-12'),
      );
    });

    test("qoida o'zgartirilsa natija ham o'zgaradi", () {
      const custom = IncomeRules(<IncomeRule>[
        IncomeRule(type: 'Oylik', shift: 0),
      ]);
      expect(
        MonthAttribution.forIncome(
          paidAt: DateTime(2026, 9),
          type: 'Oylik',
          rules: custom,
        ),
        const MonthKey('2026-09'),
      );
    });
  });

  group('§2.2 xarajatning tegishli oyi', () {
    test("odatda to'lov sanasidan olinadi", () {
      expect(
        MonthAttribution.forExpense(dueDate: DateTime(2026, 10, 5)),
        const MonthKey('2026-10'),
      );
    });

    test("DoD: 5-oktabrdagi mashina to'lovi sentabrga biriktiriladi", () {
      expect(
        MonthAttribution.forExpense(
          dueDate: DateTime(2026, 10, 5),
          manualMonth: const MonthKey('2026-09'),
        ),
        const MonthKey('2026-09'),
      );
    });
  });
}
