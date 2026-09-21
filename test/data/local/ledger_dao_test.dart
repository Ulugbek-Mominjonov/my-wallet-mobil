import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/testing.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fixtures.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('golden fixture: SQL agregat = domen qoidalari', () {
    final cases = fixtureCases();
    test('fixture fayllari topildi', () => expect(cases, isNotEmpty));

    for (final testCase in cases) {
      test('${testCase['file']}: ${testCase['name']}', () async {
        final ledger = FixtureLedger.load(testCase);
        await storeFixture(db, ledger);
        final first = ledger.firstRecordMonth ?? ledger.currentMonth;
        final to = first.isAfter(ledger.currentMonth)
            ? first
            : ledger.currentMonth;

        // BR-090: oylar kesimi.
        expect(
          await db.ledgerDao.monthFacts('h', first, to),
          ledger.monthFacts(first, to),
        );
        // BR-021: hisob qoldiqlari.
        final balances = await db.ledgerDao.accountBalances('h');
        for (final account in ledger.accounts.values) {
          expect(
            balances[account.id],
            ledger.balanceOf(account),
            reason: account.name,
          );
        }
        // BR-112..114: qarzlar — domen hisobi bilan bir xil natija.
        final activity = await db.ledgerDao.debtActivity('h');
        final expected = ledger.reportDebts();
        for (final debt in ledger.debts.values) {
          final a = activity[debt.id]!;
          final progress = DebtProgress.of(
            debt,
            paidInApp: a.paidInApp,
            paymentCount: a.paymentCount,
            pendingAmount: a.pendingAmount,
            pendingCount: a.pendingCount,
            currentMonth: ledger.currentMonth,
          );
          final row = (expected['debts']! as List<Object?>)
              .cast<Map<String, Object?>>()
              .firstWhere((r) => r['name'] == debt.name);
          expect(
            (
              progress.remaining.minor,
              progress.status.name,
              progress.pendingCount,
            ),
            (row['remaining'], row['status'], row['pending_count']),
          );
        }
        expect(
          (await db.ledgerDao.debtPaymentsIn('h', ledger.currentMonth)).minor,
          (expected['totals']! as Map<String, Object?>)['paid_this_month'],
        );
      });
    }
  });

  test("BR-061..063: fonddan qaytish, byudjet hisoblari orasidagi o'tkazma — "
      'domen tasnifi bilan bir xil', () async {
    const types = {
      'cash': AccountType.cash,
      'card': AccountType.card,
      'deposit': AccountType.deposit,
      'fund': AccountType.personalFund,
    };
    await db.batch(
      (b) => b.insertAll(db.accounts, [
        for (final MapEntry(key: id, value: type) in types.entries)
          Account(
            id: id,
            householdId: 'h',
            name: id,
            type: type,
            openingBalance: Money.zero,
          ).toCompanion(),
      ]),
    );
    var n = 0;
    Transaction tx(
      TransactionKind kind,
      String from,
      int amount, {
      String? to,
      DateTime? deletedAt,
    }) => Transaction(
      id: 't${n++}',
      householdId: 'h',
      kind: kind,
      accountId: from,
      toAccountId: to,
      amount: Money(amount),
      amountBase: Money(amount),
      toAmount: to == null ? null : Money(amount),
      categoryId: kind == TransactionKind.transfer ? null : 'c',
      occurredOn: LocalDate(2026, 9, 5),
      budgetMonth: MonthKey(2026, 9),
      deletedAt: deletedAt,
    );
    final all = [
      tx(TransactionKind.income, 'card', 1000000),
      tx(TransactionKind.transfer, 'cash', 200000, to: 'fund'),
      tx(TransactionKind.transfer, 'fund', 50000, to: 'card'),
      tx(TransactionKind.transfer, 'fund', 30000, to: 'cash'),
      tx(TransactionKind.transfer, 'card', 400000, to: 'deposit'),
      tx(TransactionKind.transfer, 'deposit', 100000, to: 'cash'),
      tx(TransactionKind.expense, 'fund', 45000),
      tx(TransactionKind.expense, 'cash', 70000),
      tx(TransactionKind.expense, 'card', 999, deletedAt: DateTime.utc(2026)),
    ];
    await db.batch(
      (b) =>
          b.insertAll(db.transactions, [for (final t in all) t.toCompanion()]),
    );
    final lines = [
      for (final t in all)
        ?BudgetLine.of(
          t,
          accountType: types[t.accountId]!,
          toAccountType: t.toAccountId == null ? null : types[t.toAccountId],
          allocationCategoryId: 'self',
        ),
    ];
    final month = MonthKey(2026, 9);
    final facts = await db.ledgerDao.monthFacts('h', month, month);
    expect(facts.single, monthFactsOf(month, lines, const []));
    // Qo'lda tekshiruv: ajratma 200 000 − 50 000 − 30 000 = 120 000.
    expect(facts.single.allocated, const Money(120000));
    expect(facts.single.expenseCash, const Money(70000 + 200000 - 30000));
  });

  group("ro'yxat va avto-to'ldirish", () {
    Transaction tx(
      int n, {
      String? payee,
      String category = 'c1',
      String day = '10',
    }) => Transaction(
      id: 'tx-${n.toString().padLeft(3, '0')}',
      householdId: 'h',
      kind: TransactionKind.expense,
      accountId: n.isEven ? 'card' : 'cash',
      amount: Money(n),
      amountBase: Money(n),
      categoryId: category,
      payee: payee,
      occurredOn: LocalDate.parse('2026-09-$day'),
      budgetMonth: MonthKey(2026, 9),
    );

    test('keyset sahifalash: takrorsiz, yangidan eskiga', () async {
      await db.batch(
        (b) => b.insertAll(db.transactions, [
          for (var i = 0; i < 120; i++)
            tx(i, day: (i % 28 + 1).toString().padLeft(2, '0')).toCompanion(),
        ]),
      );
      final seen = <String>[];
      TransactionCursor? cursor;
      for (;;) {
        final page = await db.ledgerDao
            .watchTransactionPage('h', after: cursor)
            .first;
        if (page.isEmpty) break;
        seen.addAll(page.map((t) => t.id));
        cursor = (occurredOn: page.last.occurredOn, id: page.last.id);
      }
      expect(seen, hasLength(120));
      expect(seen.toSet(), hasLength(120));
      final keys = [
        for (final id in seen)
          (await (db.select(
            db.transactions,
          )..where((t) => t.id.equals(id))).getSingle()).occurredOn,
      ];
      expect(keys, [...keys]..sort((a, b) => b.compareTo(a)));
    });

    test(
      "o'chirilgan amal ro'yxatda yo'q, yozuvdan keyin stream yangilanadi",
      () async {
        await db.into(db.transactions).insert(tx(1).toCompanion());
        final stream = db.ledgerDao.watchTransactionPage('h');
        expect(await stream.first, hasLength(1));
        await db
            .into(db.transactions)
            .insertOnConflictUpdate(
              tx(1).copyWith(deletedAt: DateTime.utc(2026)).toCompanion(),
            );
        expect(await stream.first, isEmpty);
      },
    );

    test(
      "BR-056: joy nomi — oxirgi kategoriya/hisob, prefiks bo'yicha",
      () async {
        await db.batch(
          (b) => b.insertAll(db.transactions, [
            tx(1, payee: 'Korzinka', day: '01').toCompanion(),
            tx(2, payee: 'Korzinka', category: 'c2', day: '05').toCompanion(),
            tx(3, payee: 'Kafe 100%', day: '03').toCompanion(),
            tx(4, payee: 'Makro', day: '07').toCompanion(),
          ]),
        );
        final all = await db.ledgerDao.recentPayees('h');
        expect(
          [for (final p in all) p.payee],
          ['Makro', 'Korzinka', 'Kafe 100%'],
        );
        final korzinka = all.firstWhere((p) => p.payee == 'Korzinka');
        expect(
          (korzinka.categoryId, korzinka.accountId, korzinka.lastUsedOn),
          ('c2', 'card', '2026-09-05'),
        );
        expect(
          [
            for (final p in await db.ledgerDao.recentPayees('h', prefix: 'k'))
              p.payee,
          ],
          ['Korzinka', 'Kafe 100%'],
        );
        expect(await db.ledgerDao.recentPayees('h', prefix: '100%'), isEmpty);
      },
    );
  });

  test("so'rovlar indeks bilan (SEARCH, SCAN emas)", () async {
    Future<String> plan(String sql) async =>
        (await db.customSelect('EXPLAIN QUERY PLAN $sql').get())
            .map((r) => r.read<String>('detail'))
            .join('\n');
    expect(
      await plan(
        "SELECT * FROM transactions WHERE household_id = 'h' "
        "AND budget_month BETWEEN '2026-01-01' AND '2026-09-01'",
      ),
      contains('USING INDEX transactions_month'),
    );
    expect(
      await plan("SELECT SUM(amount) FROM transactions WHERE account_id = 'a'"),
      contains('USING INDEX transactions_account'),
    );
    expect(
      await plan(
        "SELECT * FROM transactions WHERE household_id = 'h' "
        'AND deleted_at IS NULL ORDER BY occurred_on DESC, id DESC LIMIT 50',
      ),
      allOf(contains('transactions_list'), isNot(contains('TEMP B-TREE'))),
    );
  });
}
