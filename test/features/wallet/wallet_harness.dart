import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/pump_app.dart';

/// So'm → tiyin.
int som(int amount) => amount * 100;

Transaction _tx(
  String id, {
  required TransactionKind kind,
  required int amount,
  required String day,
  String account = 'card',
  String? to,
  String? category,
  String? debt,
}) {
  final date = LocalDate.parse(day);
  return Transaction(
    id: id,
    householdId: 'h1',
    kind: kind,
    accountId: account,
    toAccountId: to,
    amount: Money(som(amount)),
    amountBase: Money(som(amount)),
    toAmount: to == null ? null : Money(som(amount)),
    categoryId: category,
    debtId: debt,
    occurredOn: date,
    budgetMonth: date.monthKey,
    rowVersion: 1,
  );
}

/// Hamyon testlari (bugun — 2026-10-15, Toshkent):
/// karta 17 000 000, naqd −300 000 (BR-025), 👤 fond 800 000;
/// jamg'arma: sentabr 4 000 000 + oktabr 7 700 000 = 11 700 000;
/// qarzlar — to'lanyapti / bog'lanmagan / menga qarz; maqsadlar — ulguradi,
/// ulgurmaydi, yig'ilgan (hisobga bog'langan); "Oziq-ovqat" limiti oshgan.
Future<void> seedWallet(AppDatabase db) => db.batch((b) {
  b
    ..insert(
      db.households,
      const Household(
        id: 'h1',
        name: 'Uy',
        personalFund: PersonalFundRule(),
      ).toRow(),
    )
    ..insertAll(db.accounts, [
      for (final (id, name, type, opening, order) in [
        ('card', 'Karta', AccountType.card, som(5000000), 1),
        ('cash', 'Naqd', AccountType.cash, 0, 2),
        ('fund', 'Shaxsiy fond', AccountType.personalFund, 0, 3),
      ])
        Account(
          id: id,
          householdId: 'h1',
          name: name,
          type: type,
          openingBalance: Money(opening),
          sortOrder: order,
          rowVersion: 1,
        ).toCompanion(),
    ])
    ..insertAll(db.categories, [
      const Category(
        id: 'salary',
        householdId: 'h1',
        kind: CategoryKind.income,
        name: 'Oylik',
      ).toCompanion(),
      const Category(
        id: 'food',
        householdId: 'h1',
        kind: CategoryKind.expense,
        name: 'Oziq-ovqat',
      ).toCompanion(),
      const Category(
        id: 'credit',
        householdId: 'h1',
        kind: CategoryKind.expense,
        name: 'Kredit',
      ).toCompanion(),
      const Category(
        id: 'self',
        householdId: 'h1',
        kind: CategoryKind.expense,
        name: "O'zim uchun",
        systemCode: SystemCode.personalAllocation,
      ).toCompanion(),
    ])
    ..insertAll(db.debts, [
      Debt(
        id: 'car',
        householdId: 'h1',
        name: 'Mashina',
        direction: DebtDirection.iOwe,
        total: Money(som(10000000)),
        paidBefore: Money(som(2000000)),
        monthlyPayment: Money(som(1000000)),
        rowVersion: 1,
      ).toCompanion(),
      Debt(
        id: 'phone',
        householdId: 'h1',
        name: 'Telefon',
        direction: DebtDirection.iOwe,
        total: Money(som(500000)),
        paidBefore: Money.zero,
        rowVersion: 1,
      ).toCompanion(),
      Debt(
        id: 'bro',
        householdId: 'h1',
        name: 'Aka',
        direction: DebtDirection.owedToMe,
        total: Money(som(300000)),
        paidBefore: Money.zero,
        rowVersion: 1,
      ).toCompanion(),
    ])
    ..insertAll(db.goals, [
      Goal(
        id: 'trip',
        householdId: 'h1',
        name: "Ta'til",
        target: Money(som(10000000)),
        savedManual: Money(som(3000000)),
        monthlyContribution: Money(som(1000000)),
        deadline: MonthKey(2027, 10),
        rowVersion: 1,
      ).toCompanion(),
      Goal(
        id: 'house',
        householdId: 'h1',
        name: 'Uy',
        target: Money(som(100000000)),
        savedManual: Money.zero,
        deadline: MonthKey(2027, 1),
        sortOrder: 1,
        rowVersion: 1,
      ).toCompanion(),
      Goal(
        id: 'cushion',
        householdId: 'h1',
        name: 'Zaxira',
        target: Money(som(1000000)),
        savedManual: Money.zero,
        accountId: 'card',
        sortOrder: 2,
        rowVersion: 1,
      ).toCompanion(),
    ])
    ..insert(
      db.categoryLimits,
      CategoryLimit(
        id: 'l1',
        householdId: 'h1',
        categoryId: 'food',
        amount: Money(som(200000)),
      ).toCompanion(),
    )
    ..insertAll(
      db.transactions,
      [
        _tx(
          's1',
          kind: TransactionKind.income,
          amount: 5000000,
          day: '2026-09-05',
          category: 'salary',
        ),
        _tx(
          's2',
          kind: TransactionKind.expense,
          amount: 1000000,
          day: '2026-09-10',
          category: 'food',
        ),
        _tx(
          'o1',
          kind: TransactionKind.income,
          amount: 10000000,
          day: '2026-10-05',
          category: 'salary',
        ),
        _tx(
          'o2',
          kind: TransactionKind.expense,
          amount: 300000,
          day: '2026-10-06',
          account: 'cash',
          category: 'food',
        ),
        _tx(
          'o3',
          kind: TransactionKind.transfer,
          amount: 1000000,
          day: '2026-10-06',
          to: 'fund',
        ),
        _tx(
          'o4',
          kind: TransactionKind.expense,
          amount: 200000,
          day: '2026-10-07',
          account: 'fund',
          category: 'self',
        ),
        _tx(
          'o5',
          kind: TransactionKind.expense,
          amount: 1000000,
          day: '2026-10-10',
          category: 'credit',
          debt: 'car',
        ),
      ].map((t) => t.toCompanion()),
    );
});

/// Hamyonni ochadi ([path] — bo'lim). Baland ekran — hammasi quriladi.
Future<GoRouter> pumpWallet(
  WidgetTester tester,
  AppDatabase db, {
  String path = '/wallet',
  Size size = const Size(1080, 6000),
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = await pumpApp(
    tester,
    database: db,
    overrides: [
      clockProvider.overrideWithValue(
        TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 15, 4)),
      ),
      ...overrides,
    ],
  );
  router.go(path);
  await tester.pumpAndSettle();
  return router;
}
