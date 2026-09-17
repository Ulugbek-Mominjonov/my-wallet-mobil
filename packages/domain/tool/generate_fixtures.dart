// Umumiy fixture'larni yaratadi: `dart run tool/generate_fixtures.dart`
//
// Natija: `testdata/aggregate-cases.json` — uni HAM Dart testi
// (`test/interop/fixtures_test.dart`), HAM TypeScript testi
// (`packages/calc-ts/test/fixtures.test.ts`) o'qiydi. Ikkala platforma
// bir xil natija berishi shu fayl orqali kafolatlanadi (§12.3).
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:domain/domain.dart';
import 'package:domain/interop.dart';

const String personalCategory = "O'zim uchun";
const String personalCategoryKey = "o'zim uchun";

void main(List<String> args) {
  final output = File(
    args.isNotEmpty ? args.first : '../../testdata/aggregate-cases.json',
  );
  final payload = <String, Object?>{
    'version': 1,
    'generatedBy': 'packages/domain/tool/generate_fixtures.dart',
    'personalCategoryKey': personalCategoryKey,
    'deltaCases': _deltaCases(),
    'aggregateCases': _aggregateCases(),
  };
  output
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(payload)}\n',
    );
  stdout.writeln('✅ ${output.path} yozildi');
}

List<Map<String, Object?>> _deltaCases() {
  final cases = <Map<String, Object?>>[];

  void addExpenseCase(String name, {Expense? before, Expense? after}) {
    cases.add(<String, Object?>{
      'name': name,
      'kind': 'expense',
      'before': before == null ? null : WireCodec.expenseToWire(before),
      'after': after == null ? null : WireCodec.expenseToWire(after),
      'expected': WireCodec.deltaToWire(
        AggregateDelta.forExpense(
          personalCategoryKey: personalCategoryKey,
          before: before,
          after: after,
        ),
      ),
    });
  }

  void addIncomeCase(String name, {Income? before, Income? after}) {
    cases.add(<String, Object?>{
      'name': name,
      'kind': 'income',
      'before': before == null ? null : WireCodec.incomeToWire(before),
      'after': after == null ? null : WireCodec.incomeToWire(after),
      'expected': WireCodec.deltaToWire(
        AggregateDelta.forIncome(before: before, after: after),
      ),
    });
  }

  void addSpendCase(
    String name, {
    PersonalSpend? before,
    PersonalSpend? after,
  }) {
    cases.add(<String, Object?>{
      'name': name,
      'kind': 'personalSpend',
      'before': before == null ? null : WireCodec.spendToWire(before),
      'after': after == null ? null : WireCodec.spendToWire(after),
      'expected': WireCodec.deltaToWire(
        AggregateDelta.forPersonalSpend(before: before, after: after),
      ),
    });
  }

  final paid = _expense(id: 'e1', planned: 500000, actual: 500000);
  final unpaid = _expense(id: 'e2', planned: 700000);
  final unknown = _expense(id: 'e3');
  final personal = _expense(
    id: 'e4',
    name: "O'zim uchun (ajratma)",
    category: personalCategory,
    planned: 1200000,
    actual: 1200000,
  );
  final linked = _expense(
    id: 'e5',
    category: 'Qarz',
    planned: 5300000,
    debtId: 'debt_mashina',
  );

  addExpenseCase("to'langan xarajat qo'shildi", after: paid);
  addExpenseCase("to'lanmagan xarajat qo'shildi", after: unpaid);
  addExpenseCase("summasi noma'lum xarajat", after: unknown);
  addExpenseCase('shaxsiy fond ajratmasi', after: personal);
  addExpenseCase("qarzga bog'langan to'lanmagan", after: linked);
  addExpenseCase("qarz to'landi", before: linked, after: linked.copyWith(
    actual: const Money(5300000),
  ),);
  addExpenseCase("xarajat o'chirildi", before: paid);
  addExpenseCase(
    'summa tahrirlandi',
    before: paid,
    after: paid.copyWith(actual: const Money(620000)),
  );
  addExpenseCase(
    "oy qo'lda ko'chirildi",
    before: paid,
    after: paid.copyWith(
      monthKey: const MonthKey('2026-10'),
      monthKeySource: MonthKeySource.manual,
    ),
  );
  addExpenseCase(
    "to'lov usuli o'zgardi",
    before: paid,
    after: paid.copyWith(method: PaymentMethod.card),
  );
  addExpenseCase(
    "kategoriya o'zgardi",
    before: paid,
    after: paid.copyWith(category: 'Transport'),
  );
  addExpenseCase(
    "to'lov belgilandi",
    before: unpaid,
    after: unpaid.copyWith(actual: const Money(700000)),
  );

  final salary = _income(id: 'i1', amount: 12000000, monthKey: '2026-08');
  addIncomeCase("oylik qo'shildi", after: salary);
  addIncomeCase(
    "qoida o'zgardi — daromad boshqa oyga ko'chdi",
    before: salary,
    after: salary.copyWith(monthKey: const MonthKey('2026-09')),
  );
  addIncomeCase(
    "qarzga bog'langan daromad",
    after: _income(id: 'i2', amount: 400000, debtId: 'debt_ukam'),
  );
  addIncomeCase("daromad o'chirildi", before: salary);

  final spend = _spend(id: 'p1', amount: 250000);
  addSpendCase("shaxsiy sarf qo'shildi", after: spend);
  addSpendCase(
    'shaxsiy sarf tahrirlandi',
    before: spend,
    after: spend.copyWith(amount: const Money(300000)),
  );
  addSpendCase("shaxsiy sarf o'chirildi", before: spend);

  return cases;
}

/// Tasodifiy, lekin QOTIRILGAN (seed) ma'lumot to'plamlari.
///
/// TypeScript porti aynan shu yozuvlardan aynan shu agregatni olishi shart.
List<Map<String, Object?>> _aggregateCases() {
  final random = Random(20260916);
  const categories = <String>[
    'Oziq-ovqat',
    'Kommunal',
    'Qarz',
    personalCategory,
    'Transport',
  ];
  const types = <String>['Oylik', 'Avans', 'KPI', "Qo'shimcha"];
  const methods = PaymentMethod.values;
  final cases = <Map<String, Object?>>[];

  for (var index = 0; index < 40; index++) {
    final month = MonthKey(
      '2026-${(random.nextInt(12) + 1).toString().padLeft(2, '0')}',
    );
    final incomes = <Income>[
      for (var i = 0; i < random.nextInt(4); i++)
        Income(
          id: 'i$index-$i',
          amount: Money((random.nextInt(40) + 1) * 100000),
          type: types[random.nextInt(types.length)],
          method: methods[random.nextInt(methods.length)],
          paidAt: month.dayOf(random.nextInt(28) + 1),
          monthKey: month,
        ),
    ];
    final expenses = <Expense>[
      for (var i = 0; i < random.nextInt(6); i++)
        Expense(
          id: 'e$index-$i',
          name: 'X$index-$i',
          category: categories[random.nextInt(categories.length)],
          method: methods[random.nextInt(methods.length)],
          planned: random.nextInt(10) == 0
              ? null
              : Money((random.nextInt(20) + 1) * 50000),
          actual: random.nextBool()
              ? Money((random.nextInt(20) + 1) * 50000)
              : null,
          dueDate: month.dayOf(random.nextInt(28) + 1),
          monthKey: month,
        ),
    ];
    final spends = <PersonalSpend>[
      for (var i = 0; i < random.nextInt(3); i++)
        PersonalSpend(
          id: 'p$index-$i',
          amount: Money((random.nextInt(8) + 1) * 50000),
          purpose: 'P$index-$i',
          method: methods[random.nextInt(methods.length)],
          spentAt: month.dayOf(random.nextInt(28) + 1),
          monthKey: month,
        ),
    ];

    cases.add(<String, Object?>{
      'name': 'tasodifiy-$index',
      'monthKey': month.value,
      'incomes': incomes.map(WireCodec.incomeToWire).toList(),
      'expenses': expenses.map(WireCodec.expenseToWire).toList(),
      'personalSpends': spends.map(WireCodec.spendToWire).toList(),
      'expected': WireCodec.summaryToWire(
        MonthSummaryCalc.build(
          monthKey: month,
          personalCategoryKey: personalCategoryKey,
          incomes: incomes,
          expenses: expenses,
          personalSpends: spends,
        ),
      ),
    });
  }
  return cases;
}

Expense _expense({
  required String id,
  String name = 'Xarajat',
  String category = 'Oziq-ovqat',
  PaymentMethod method = PaymentMethod.cash,
  int? planned,
  int? actual,
  String monthKey = '2026-09',
  String? debtId,
}) =>
    Expense(
      id: id,
      name: name,
      category: category,
      method: method,
      planned: planned == null ? null : Money(planned),
      actual: actual == null ? null : Money(actual),
      dueDate: MonthKey(monthKey).dayOf(15),
      monthKey: MonthKey(monthKey),
      debtId: debtId,
    );

Income _income({
  required String id,
  required int amount,
  String type = 'Oylik',
  PaymentMethod method = PaymentMethod.card,
  String monthKey = '2026-09',
  String? debtId,
}) =>
    Income(
      id: id,
      amount: Money(amount),
      type: type,
      method: method,
      paidAt: MonthKey(monthKey).dayOf(2),
      monthKey: MonthKey(monthKey),
      debtId: debtId,
    );

PersonalSpend _spend({required String id, required int amount}) =>
    PersonalSpend(
      id: id,
      amount: Money(amount),
      purpose: 'Kitob',
      method: PaymentMethod.cash,
      spentAt: DateTime(2026, 9, 20),
      monthKey: const MonthKey('2026-09'),
    );
