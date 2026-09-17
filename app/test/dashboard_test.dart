import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oylik_byudjet/features/dashboard/presentation/dashboard_screen.dart';

import 'support/harness.dart';

void main() {
  final now = DateTime(2026, 9, 16);
  const september = MonthKey('2026-09');

  const summary = MonthSummary(
    monthKey: september,
    income: Money(12000000),
    incomeCard: Money(8000000),
    incomeCash: Money(4000000),
    expense: Money(9500000),
    expenseCard: Money(6000000),
    expenseCash: Money(3500000),
    planned: Money(10200000),
    unpaidTotal: Money(700000),
    personalAllocated: Money(1500000),
    personalSpent: Money(400000),
    byType: <String, MethodSplit>{
      'Oylik': MethodSplit(card: Money(8000000)),
      'KPI': MethodSplit(cash: Money(4000000)),
    },
    byCategory: <String, CategorySplit>{
      'Oziq-ovqat': CategorySplit(
        planned: Money(3000000),
        actual: Money(3200000),
      ),
    },
  );

  testWidgets("qoldiq, orttirgan va kesimlar ko'rsatiladi", (tester) async {
    await tester.pumpWidget(
      harness(
        child: const DashboardScreen(),
        now: now,
        summary: summary,
        totals: const OverallTotals(
          income: Money(40000000),
          expense: Money(30000000),
          personalAllocated: Money(3000000),
          personalSpent: Money(1000000),
        ),
        months: const <MonthSummary>[summary],
      ),
    );
    await tester.pump();

    // Qoldiq = 12 000 000 − 9 500 000 = 2 500 000
    expect(find.text("2 500 000 so'm"), findsOneWidget);
    // Orttirgan = 2 500 000 + 1 500 000 − 400 000 = 3 600 000
    expect(find.text('3 600 000'), findsWidgets);
    expect(find.text('Sentabr 2026'), findsOneWidget);
    expect(find.text('Oziq-ovqat'), findsOneWidget);
    expect(find.text('Oylik'), findsOneWidget);
  });

  testWidgets("👤 va 🏦 fondlar alohida ko'rsatiladi", (tester) async {
    await tester.pumpWidget(
      harness(
        child: const DashboardScreen(),
        now: now,
        summary: summary,
        totals: const OverallTotals(
          income: Money(40000000),
          expense: Money(30000000),
          personalAllocated: Money(3000000),
          personalSpent: Money(1000000),
        ),
      ),
    );
    await tester.pump();

    // 👤 fond = 3 000 000 − 1 000 000 = 2 000 000
    expect(find.text('2 000 000'), findsWidgets);
    expect(find.textContaining('👤'), findsOneWidget);
    expect(find.textContaining('🏦'), findsOneWidget);
  });

  testWidgets("oy o'zgartirish tugmalari ishlaydi", (tester) async {
    await tester.pumpWidget(
      harness(child: const DashboardScreen(), now: now, summary: summary),
    );
    await tester.pump();

    expect(find.text('Sentabr 2026'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();
    expect(find.text('Avgust 2026'), findsOneWidget);
  });

  testWidgets("bo'sh oyda ham yiqilmaydi", (tester) async {
    await tester.pumpWidget(
      harness(child: const DashboardScreen(), now: now),
    );
    await tester.pump();
    expect(find.text("0 so'm"), findsWidgets);
  });
}
