import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  late AppDatabase db;

  Transaction tx(
    String id, {
    TransactionKind kind = TransactionKind.expense,
    String account = 'cash',
    String? to,
    String? category = 'food',
    String day = '2026-10-05',
    String month = '2026-10-01',
    int amount = 4500000,
    String? payee,
    String? note,
  }) => Transaction(
    id: id,
    householdId: 'h',
    kind: kind,
    accountId: account,
    toAccountId: to,
    amount: Money(amount),
    amountBase: Money(amount),
    categoryId: kind == TransactionKind.transfer ? null : category,
    occurredOn: LocalDate.parse(day),
    budgetMonth: MonthKey.parse(month),
    payee: payee,
    note: note,
    rowVersion: 1,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.batch((b) {
      b
        ..insertAll(
          db.transactions,
          [
            tx('t1', payee: 'Korzinka'),
            tx('t2', note: 'Taksi uyga', day: '2026-10-04', amount: 2000000),
            tx(
              't3',
              kind: TransactionKind.income,
              category: 'salary',
              account: 'card',
              day: '2026-10-02',
              month: '2026-09-01',
            ),
            tx(
              't4',
              kind: TransactionKind.transfer,
              account: 'card',
              to: 'cash',
              day: '2026-10-03',
            ),
            tx('t5', day: '2026-09-28', month: '2026-09-01'),
          ].map((t) => t.toCompanion()),
        )
        ..insert(
          db.transactionTags,
          TransactionTagsCompanion.insert(
            id: 'l1',
            householdId: 'h',
            transactionId: 't2',
            tagId: 'trip',
          ),
        );
    });
  });
  tearDown(() => db.close());

  Future<List<String>> ids(TransactionFilter filter) async => [
    for (final row
        in await db.ledgerDao.watchTransactionPage('h', filter: filter).first)
      row.id,
  ];

  test("filtrsiz — sana bo'yicha yangidan eskiga", () async {
    expect(await ids(const TransactionFilter()), [
      't1',
      't2',
      't4',
      't3',
      't5',
    ]);
  });

  test("oy — tegishli oy bo'yicha (daromad oldingi oyga tushgan)", () async {
    expect(await ids(TransactionFilter(month: MonthKey(2026, 9))), [
      't3',
      't5',
    ]);
  });

  test("tur, kategoriya, hisob (o'tkazmaning ikkala tomoni), teg", () async {
    expect(await ids(const TransactionFilter(kind: TransactionKind.income)), [
      't3',
    ]);
    expect(await ids(const TransactionFilter(categoryId: 'food')), [
      't1',
      't2',
      't5',
    ]);
    expect(await ids(const TransactionFilter(accountId: 'card')), ['t4', 't3']);
    expect(await ids(const TransactionFilter(tagId: 'trip')), ['t2']);
  });

  test('qidiruv: joy nomi, izoh (registrsiz) va summa', () async {
    expect(await ids(const TransactionFilter(search: 'korz')), ['t1']);
    expect(await ids(const TransactionFilter(search: 'TAKSI')), ['t2']);
    expect(await ids(const TransactionFilter(search: '20 000')), ['t2']);
    expect(await ids(const TransactionFilter(search: '100%')), isEmpty);
  });

  test("o'chirilganlar ko'rinmaydi; filtr tengligi", () async {
    await (db.update(db.transactions)..where((t) => t.id.equals('t1'))).write(
      TransactionsCompanion(deletedAt: Value(DateTime.utc(2026, 10, 6))),
    );
    expect((await ids(const TransactionFilter())).contains('t1'), isFalse);
    expect(
      const TransactionFilter(search: 'a'),
      const TransactionFilter(search: 'a'),
    );
    expect(const TransactionFilter().isEmpty, isTrue);
    expect(
      const TransactionFilter(kind: TransactionKind.expense)
          .copyWith(clearKind: true)
          .isEmpty,
      isTrue,
    );
  });

  test("oy filtri indeksdan (SEARCH), to'liq skan emas", () async {
    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN SELECT * FROM transactions '
          "WHERE household_id = 'h' AND deleted_at IS NULL "
          "AND budget_month = '2026-10-01' "
          'ORDER BY occurred_on DESC, id DESC LIMIT 50',
        )
        .get();
    final detail = plan.map((r) => r.read<String>('detail')).join('\n');
    expect(detail, contains('SEARCH transactions USING INDEX'));
  });
}
