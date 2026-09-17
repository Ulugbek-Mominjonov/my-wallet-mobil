import 'dart:convert';
import 'dart:io';

import 'package:domain/domain.dart';
import 'package:domain/interop.dart';
import 'package:test/test.dart';

/// Umumiy fixture'lar Dart tomonda ham aynan mos kelishini tekshiradi.
///
/// AYNI SHU faylni `packages/calc-ts` testi ham o'qiydi — shuning uchun bu
/// test ikki vazifani bajaradi:
/// 1. regressiya qo'riqchisi (Dart mantiqi o'zgarib ketmasin);
/// 2. TypeScript porti uchun haqiqat manbai.
void main() {
  final file = File('../../testdata/aggregate-cases.json');

  test('fixture fayli mavjud (tool/generate_fixtures.dart bilan yaratiladi)',
      () {
    expect(
      file.existsSync(),
      isTrue,
      reason: 'dart run tool/generate_fixtures.dart',
    );
  });

  final payload =
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  final personalKey = payload['personalCategoryKey']! as String;

  group('delta holatlari', () {
    final cases = (payload['deltaCases']! as List<Object?>)
        .cast<Map<String, Object?>>();

    test("bo'sh emas", () => expect(cases, isNotEmpty));

    for (final item in cases) {
      test('${item['kind']}: ${item['name']}', () {
        final before = item['before'] as Map<String, Object?>?;
        final after = item['after'] as Map<String, Object?>?;
        final delta = switch (item['kind']) {
          'expense' => AggregateDelta.forExpense(
              personalCategoryKey: personalKey,
              before:
                  before == null ? null : WireCodec.expenseFromWire(before),
              after: after == null ? null : WireCodec.expenseFromWire(after),
            ),
          'income' => AggregateDelta.forIncome(
              before: before == null ? null : WireCodec.incomeFromWire(before),
              after: after == null ? null : WireCodec.incomeFromWire(after),
            ),
          _ => AggregateDelta.forPersonalSpend(
              before: before == null ? null : WireCodec.spendFromWire(before),
              after: after == null ? null : WireCodec.spendFromWire(after),
            ),
        };
        expect(WireCodec.deltaToWire(delta), item['expected']);
      });
    }
  });

  group('agregat holatlari', () {
    final cases = (payload['aggregateCases']! as List<Object?>)
        .cast<Map<String, Object?>>();

    test('40 ta tasodifiy holat mavjud', () {
      expect(cases.length, greaterThanOrEqualTo(40));
    });

    for (final item in cases) {
      test('agregat: ${item['name']}', () {
        final summary = MonthSummaryCalc.build(
          monthKey: MonthKey(item['monthKey']! as String),
          personalCategoryKey: personalKey,
          incomes: (item['incomes']! as List<Object?>)
              .cast<Map<String, Object?>>()
              .map(WireCodec.incomeFromWire),
          expenses: (item['expenses']! as List<Object?>)
              .cast<Map<String, Object?>>()
              .map(WireCodec.expenseFromWire),
          personalSpends: (item['personalSpends']! as List<Object?>)
              .cast<Map<String, Object?>>()
              .map(WireCodec.spendFromWire),
        );
        expect(WireCodec.summaryToWire(summary), item['expected']);
      });
    }
  });
}
