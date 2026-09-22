import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:wallet_domain/wallet_domain.dart';

T ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('Ok kutilgan, $failure keldi'),
};

final class _SeqIds implements IdGenerator {
  var _n = 0;
  @override
  String newId() => 'id-${(_n++).toString().padLeft(3, '0')}';
}

void main() {
  late AppDatabase db;
  late DomainDeps deps;
  final clock = TzClock(
    'Asia/Tashkent',
    utcNow: () => DateTime.utc(2026, 10, 5, 4),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.batch((b) {
      b
        ..insert(
          db.households,
          const Household(
            id: 'h',
            name: 'Uy',
            personalFund: PersonalFundRule(),
          ).toRow(),
        )
        ..insertAll(db.accounts, [
          for (final (id, type) in const [
            ('cash', AccountType.cash),
            ('card', AccountType.card),
            ('fund', AccountType.personalFund),
          ])
            Account(
              id: id,
              householdId: 'h',
              name: id,
              type: type,
              openingBalance: Money.zero,
              rowVersion: 1,
            ).toCompanion(),
        ])
        ..insertAll(db.categories, [
          const Category(
            id: 'food',
            householdId: 'h',
            kind: CategoryKind.expense,
            name: 'Oziq-ovqat',
          ).toCompanion(),
          const Category(
            id: 'oylik',
            householdId: 'h',
            kind: CategoryKind.income,
            name: 'Oylik',
            monthShift: -1,
          ).toCompanion(),
          const Category(
            id: 'self',
            householdId: 'h',
            kind: CategoryKind.expense,
            name: "O'zim uchun",
            systemCode: SystemCode.personalAllocation,
          ).toCompanion(),
        ]);
    });
    deps = localDomainDeps(db, householdId: 'h', clock: clock, ids: _SeqIds());
  });
  tearDown(() => db.close());

  Future<List<OutboxRow>> outbox() =>
      (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.id)])).get();

  TransactionInput expense({int amount = 50000}) => TransactionInput(
    kind: TransactionKind.expense,
    accountId: 'card',
    amount: Money(amount),
    categoryId: 'food',
    payee: 'Korzinka',
  );

  test(
    'yozuv: qator va outbox mutatsiyasi (snake_case, server maydonlarisiz)',
    () async {
      final tx = ok(await AddTransaction(deps)(expense()));
      final stored = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(tx.id))).getSingle();
      expect(stored.budgetMonth, '2026-10-01');
      expect(stored.occurredOn, '2026-10-05');

      final mutation = (await outbox()).single;
      expect(
        (
          mutation.targetTable,
          mutation.recordId,
          mutation.op,
          mutation.baseVersion,
          mutation.status,
        ),
        ('transactions', tx.id, 'upsert', null, 'pending'),
      );
      final data = jsonDecode(mutation.data) as Map<String, Object?>;
      expect(data['amount'], 50000);
      expect(data['budget_month'], '2026-10-01');
      expect(data['payee'], 'Korzinka');
      expect(data['deleted_at'], isNull);
      expect(data.keys, isNot(contains('row_version')));
      expect(data.keys, isNot(contains('id')));
      expect(data.keys, isNot(contains('household_id')));
    },
  );

  test(
    'BR-040: tegishli oy lokal hisoblanadi (Toshkent sanasi bilan)',
    () async {
      final tx = ok(
        await AddTransaction(deps)(
          TransactionInput(
            kind: TransactionKind.income,
            accountId: 'card',
            amount: const Money(800000000),
            categoryId: 'oylik',
            occurredOn: LocalDate(2026, 10, 2),
          ),
        ),
      );
      expect(tx.budgetMonth, MonthKey(2026, 9));
      expect(
        (await deps.transactions.byId(tx.id))!.budgetMonth,
        MonthKey(2026, 9),
      );
    },
  );

  test(
    'ketma-ket tahrirlar — bitta mutatsiya; yuborilayotganiga tegilmaydi',
    () async {
      final tx = ok(await AddTransaction(deps)(expense()));
      ok(
        await EditTransaction(deps)(
          tx.id,
          (t) => t.copyWith(amount: const Money(60000)),
        ),
      );
      ok(await EditTransaction(deps)(tx.id, (t) => t.copyWith(note: 'bonus')));
      var rows = await outbox();
      expect(rows, hasLength(1));
      final data = jsonDecode(rows.single.data) as Map<String, Object?>;
      expect((data['amount'], data['note']), (60000, 'bonus'));

      // Push boshlandi (javob hali yo'q) — yangi tahrir alohida mutatsiya.
      await (db.update(db.outbox)..where((o) => o.id.equals(rows.single.id)))
          .write(const OutboxCompanion(status: Value('sending')));
      ok(await EditTransaction(deps)(tx.id, (t) => t.copyWith(note: 'yangi')));
      rows = await outbox();
      expect([for (final r in rows) r.status], ['sending', 'pending']);
      expect(rows.first.mutationId, isNot(rows.last.mutationId));
    },
  );

  test("serverdagi qator tahriri — base_version = ma'lum versiya", () async {
    final server = Transaction(
      id: 'srv',
      householdId: 'h',
      kind: TransactionKind.expense,
      accountId: 'card',
      amount: const Money(1000),
      amountBase: const Money(1000),
      categoryId: 'food',
      occurredOn: LocalDate(2026, 10, 1),
      budgetMonth: MonthKey(2026, 10),
      rowVersion: 42,
    );
    await db.into(db.transactions).insert(server.toCompanion());
    ok(await EditTransaction(deps)('srv', (t) => t.copyWith(note: 'x')));
    expect((await outbox()).single.baseVersion, 42);
  });

  test(
    "serverga yetmagan qator o'chirilsa — mutatsiya bekor, undo qaytaradi",
    () async {
      final tx = ok(await AddTransaction(deps)(expense()));
      final snapshot = ok(await DeleteTransaction(deps)(tx.id));
      expect(await outbox(), isEmpty);
      final tombstone = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(tx.id))).getSingle();
      expect(tombstone.deletedAt, isNotNull);

      ok(await UndoDeleteTransaction(deps)(snapshot));
      final restored = (await outbox()).single;
      expect(jsonDecode(restored.data), containsPair('deleted_at', null));
    },
  );

  test("serverdagi qatorni o'chirish — upsert (deleted_at bilan)", () async {
    await db
        .into(db.transactions)
        .insert(
          Transaction(
            id: 'srv',
            householdId: 'h',
            kind: TransactionKind.expense,
            accountId: 'card',
            amount: const Money(1000),
            amountBase: const Money(1000),
            categoryId: 'food',
            occurredOn: LocalDate(2026, 10, 1),
            budgetMonth: MonthKey(2026, 10),
            rowVersion: 7,
          ).toCompanion(),
        );
    ok(await DeleteTransaction(deps)('srv'));
    final mutation = (await outbox()).single;
    expect(mutation.baseVersion, 7);
    expect((jsonDecode(mutation.data) as Map)['deleted_at'], isNotNull);
  });

  Future<void> insertRentPlan() => db
      .into(db.plannedItems)
      .insert(
        PlannedItem(
          id: 'rent',
          householdId: 'h',
          kind: PlanKind.expense,
          name: 'Ijara',
          dueDate: LocalDate(2026, 10, 5),
          budgetMonth: MonthKey(2026, 10),
          categoryId: 'food',
          accountId: 'card',
          plannedAmount: const Money(300000000),
          rowVersion: 3,
        ).toCompanion(),
      );

  test(
    "BR-073: reja to'lovi — holat lokal, serverga faqat amal (reja hosila)",
    () async {
      await insertRentPlan();
      final tx = ok(await PayPlanned(deps)('rent'));
      final plan = (await deps.plans.byId('rent'))!;
      expect(plan.paidAmount, const Money(300000000));
      expect(plan.settledAt, isNotNull);
      // To'langan summa/holatni server amal trigger'ida o'zi hisoblaydi:
      // reja mutatsiyasi bo'lsa, trigger versiyani oshirib conflict berardi.
      final rows = await outbox();
      expect([for (final r in rows) r.targetTable], ['transactions']);
      expect(tx.plannedItemId, 'rent');
    },
  );

  test(
    "BR-073: qisman to'lab yopish — reja (closed_at) amaldan oldin navbatda",
    () async {
      await insertRentPlan();
      ok(
        await PayPlanned(deps)(
          'rent',
          amount: const Money(100000000),
          settle: true,
        ),
      );
      final rows = await outbox();
      expect(
        [for (final r in rows) (r.targetTable, r.baseVersion)],
        [('planned_items', 3), ('transactions', null)],
      );
      final data = jsonDecode(rows.first.data) as Map<String, Object?>;
      expect(data['closed_at'], isNotNull);
      expect(data.keys, isNot(contains('paid_amount')));
      expect(data.keys, isNot(contains('settled_at')));
    },
  );

  test('BR-062: fond sarfi — tizim kategoriyasi lokal bazadan', () async {
    final tx = ok(await AddPersonalSpend(deps)(amount: const Money(45000)));
    expect(tx.categoryId, 'self');
    expect(tx.accountId, 'fund');
  });

  test(
    "tranzaksiya xato bilan tugasa — qator ham, mutatsiya ham yo'q",
    () async {
      await expectLater(
        deps.transactor.run(() async {
          await deps.transactions.save(
            Transaction(
              id: 'x',
              householdId: 'h',
              kind: TransactionKind.expense,
              accountId: 'card',
              amount: const Money(1),
              amountBase: const Money(1),
              categoryId: 'food',
              occurredOn: LocalDate(2026, 10, 5),
              budgetMonth: MonthKey(2026, 10),
            ),
          );
          throw StateError("yarim yo'lda");
        }),
        throwsStateError,
      );
      expect(await db.select(db.transactions).get(), isEmpty);
      expect(await outbox(), isEmpty);
    },
  );

  test(
    "byudjet sinxrongacha yo'q — aniq xato; yopilgan oy — months jadvalidan",
    () async {
      final other = localDomainDeps(db, householdId: 'missing', clock: clock);
      await expectLater(other.households.current(), throwsStateError);
      expect(await deps.households.isMonthClosed(MonthKey(2026, 9)), isFalse);
      await db
          .into(db.months)
          .insert(
            MonthsCompanion.insert(
              householdId: 'h',
              month: '2026-09-01',
              closedAt: Value(DateTime.utc(2026, 10, 2)),
            ),
          );
      expect(await deps.households.isMonthClosed(MonthKey(2026, 9)), isTrue);
      expect(
        (await deps.households.current()).personalFund.percentBasisPoints,
        1000,
      );
    },
  );

  test('tez tugma — hisob valyutasida; mavjud emas — null', () async {
    await db
        .into(db.quickActions)
        .insert(
          const QuickAction(
            id: 'taxi',
            householdId: 'h',
            name: 'Taksi',
            amount: Money(2000000),
            categoryId: 'food',
            accountId: 'cash',
          ).toCompanion(),
        );
    final tx = ok(await QuickAdd(deps)('taxi'));
    expect(tx.source, TransactionSource.quickAction);
    expect(await deps.quickActions.byId('none'), isNull);
    expect(await deps.accounts.byId('none'), isNull);
    expect(await deps.categories.byId('none'), isNull);
    expect(await deps.transactions.byId('none'), isNull);
    expect(await deps.plans.byId('none'), isNull);
  });

  test(
    'BR-002: bugun — byudjet vaqt zonasida (UTC 19:05 = Toshkent 00:05)',
    () {
      final evening = TzClock(
        'Asia/Tashkent',
        utcNow: () => DateTime.utc(2026, 10, 31, 19, 5),
      );
      expect(evening.today(), LocalDate(2026, 11, 1));
      expect(evening.now(), DateTime.utc(2026, 10, 31, 19, 5));
      final london = TzClock(
        'Europe/London',
        utcNow: () => DateTime.utc(2026, 10, 31, 19, 5),
      );
      expect(london.today(), LocalDate(2026, 10, 31));
      expect(TzClock('Asia/Tashkent').now().isUtc, isTrue);
    },
  );

  test("UUIDv7 — noyob va vaqt bo'yicha tartiblangan", () async {
    const ids = UuidV7Ids();
    final first = ids.newId();
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final second = ids.newId();
    expect(first, isNot(second));
    expect(first.compareTo(second), lessThan(0));
    expect(first[14], '7');
  });
}
