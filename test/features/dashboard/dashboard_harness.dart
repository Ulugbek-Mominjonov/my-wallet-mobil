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

/// Xulosa testlari: 2026-yil oktabr (bugun — 10-oktabr, Toshkent),
/// karta/naqd/fond hisoblari, "Oziq-ovqat" va "Oylik" kategoriyalari.
Transaction _tx(
  String id, {
  required TransactionKind kind,
  required int amount,
  String account = 'card',
  String? category,
  String day = '2026-10-03',
  String? to,
}) => Transaction(
  id: id,
  householdId: 'h1',
  kind: kind,
  accountId: account,
  toAccountId: to,
  amount: Money(amount),
  amountBase: Money(amount),
  toAmount: to == null ? null : Money(amount),
  categoryId: category,
  occurredOn: LocalDate.parse(day),
  budgetMonth: MonthKey(2026, 10),
  rowVersion: 1,
);

Future<void> seedMonth(
  AppDatabase db, {
  required int income,
  required int expense,
}) => db.batch((b) {
  b
    ..insertAll(db.accounts, [
      for (final (id, type) in const [
        ('card', AccountType.card),
        ('cash', AccountType.cash),
        ('fund', AccountType.personalFund),
      ])
        Account(
          id: id,
          householdId: 'h1',
          name: id,
          type: type,
          openingBalance: Money.zero,
          rowVersion: 1,
        ).toCompanion(),
    ])
    ..insertAll(db.categories, [
      const Category(
        id: 'food',
        householdId: 'h1',
        kind: CategoryKind.expense,
        name: 'Oziq-ovqat',
      ).toCompanion(),
      const Category(
        id: 'salary',
        householdId: 'h1',
        kind: CategoryKind.income,
        name: 'Oylik',
      ).toCompanion(),
    ])
    ..insertAll(
      db.transactions,
      [
        _tx(
          'i',
          kind: TransactionKind.income,
          amount: income,
          category: 'salary',
        ),
        _tx(
          'e',
          kind: TransactionKind.expense,
          amount: expense,
          account: 'cash',
          category: 'food',
        ),
      ].map((t) => t.toCompanion()),
    );
});

/// Xulosani ochadi. Standart — baland ekran (ro'yxatdagi barcha kartalar
/// quriladi); goldenlar uchun — telefon o'lchami.
Future<GoRouter> pumpDashboard(
  WidgetTester tester,
  AppDatabase db, {
  Size size = const Size(1080, 6000),
  List<Override> overrides = const [],
}) {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    database: db,
    overrides: [
      clockProvider.overrideWithValue(
        TzClock('Asia/Tashkent', utcNow: () => DateTime.utc(2026, 10, 10, 4)),
      ),
      ...overrides,
    ],
  );
}
