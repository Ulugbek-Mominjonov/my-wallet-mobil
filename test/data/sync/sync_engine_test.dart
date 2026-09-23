import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'fake_remote.dart';

T ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('Ok kutilgan, $failure keldi'),
};

void main() {
  late AppDatabase db;
  late FakeRemote remote;
  late SyncEngine engine;
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
        ..insert(
          db.categories,
          const Category(
            id: 'food',
            householdId: 'h',
            kind: CategoryKind.expense,
            name: 'Oziq-ovqat',
            rowVersion: 1,
          ).toCompanion(),
        );
    });
    remote = FakeRemote();
    engine = SyncEngine(db, remote, deviceId: 'phone-1', now: clock.now);
    deps = localDomainDeps(db, householdId: 'h', clock: clock);
  });
  tearDown(() => db.close());

  Future<Transaction> addExpense({int amount = 50000}) async => ok<Transaction>(
    await AddTransaction(deps)(
      TransactionInput(
        kind: TransactionKind.expense,
        accountId: 'card',
        amount: Money(amount),
        categoryId: 'food',
      ),
    ),
  );

  Future<TransactionRow?> localTx(String id) => (db.select(
    db.transactions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<List<OutboxRow>> outbox() =>
      (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.id)])).get();

  group('push', () {
    test(
      "ok — kanonik qator (server hisoblagan maydonlar), navbat bo'shaydi",
      () async {
        final tx = await addExpense();
        remote.onPush = (mutations) async => Ok([
          FakeRemote.okResult(
            mutations.single,
            version: 10,
            overrides: {
              'budget_month': '2026-09-01',
              'budget_month_source': 'manual',
            },
          ),
        ]);
        final report = await engine.push('h');
        expect((report.pushed, report.ok), (1, true));
        final pushed = remote.pushes.single.single;
        expect(
          (pushed.table, pushed.op, pushed.id, pushed.baseVersion),
          ('transactions', 'upsert', tx.id, null),
        );
        final row = (await localTx(tx.id))!;
        expect((row.rowVersion, row.budgetMonth), (10, '2026-09-01'));
        expect(row.createdAt, isNotNull);
        expect(await outbox(), isEmpty);
        final state = await db.select(db.syncState).getSingle();
        expect(state.lastPushAt, isNotNull);
      },
    );

    test("oflayn — o'sha mutatsiya o'sha ID bilan qayta yuboriladi", () async {
      await addExpense();
      remote.onPush = (_) async => const Err(OfflineFailure());
      final failed = await engine.push('h');
      expect(failed.failure, isA<OfflineFailure>());
      final waiting = (await outbox()).single;
      expect((waiting.status, waiting.attempts), ('sending', 1));
      expect(waiting.lastError, 'OfflineFailure');

      remote.onPush = null;
      expect((await engine.push('h')).ok, isTrue);
      expect(
        remote.pushes[0].single.mutationId,
        remote.pushes[1].single.mutationId,
      );
      expect(await outbox(), isEmpty);
    });

    test(
      'yuborish paytidagi yangi tahrir — keyingi paketda yangi versiya bilan',
      () async {
        final tx = await addExpense();
        var call = 0;
        remote.onPush = (mutations) async {
          call++;
          if (call == 1) {
            // Javob kelguncha foydalanuvchi yana tahrirladi.
            ok(
              await EditTransaction(deps)(
                tx.id,
                (t) => t.copyWith(note: 'yangi'),
              ),
            );
            return Ok([FakeRemote.okResult(mutations.single, version: 10)]);
          }
          return Ok([FakeRemote.okResult(mutations.single, version: 11)]);
        };
        final report = await engine.push('h');
        expect(report.pushed, 2);
        expect(remote.pushes[1].single.baseVersion, 10);
        expect(remote.pushes[1].single.data['note'], 'yangi');
        final row = (await localTx(tx.id))!;
        expect((row.rowVersion, row.note), (11, 'yangi'));
        expect(await outbox(), isEmpty);
      },
    );

    test(
      'BR-006: conflict — server qatori, navbat tozalanadi, muammo yoziladi',
      () async {
        final tx = await addExpense();
        ok(
          await EditTransaction(deps)(tx.id, (t) => t.copyWith(note: 'mening')),
        );
        await db
            .update(db.outbox)
            .write(const OutboxCompanion(status: Value('sending')));
        ok(await EditTransaction(deps)(tx.id, (t) => t.copyWith(note: 'yana')));
        remote.onPush = (mutations) async => Ok([
          SyncPushResult.fromJson({
            'mutation_id': mutations.single.mutationId,
            'status': 'conflict',
            'row': {
              ...mutations.single.data,
              'id': tx.id,
              'household_id': 'h',
              'note': 'boshqa qurilma',
              'row_version': 20,
            },
          }),
        ]);
        final report = await engine.push('h');
        expect((report.conflicts, report.ok), (1, true));
        expect((await localTx(tx.id))!.note, 'boshqa qurilma');
        expect(await outbox(), isEmpty);
        final issue = await db.select(db.syncIssues).getSingle();
        expect((issue.status, issue.recordId), ('conflict', tx.id));
        expect(
          jsonDecode(issue.serverRow!),
          containsPair('note', 'boshqa qurilma'),
        );
        expect(jsonDecode(issue.localData), containsPair('note', 'yana'));
      },
    );

    test(
      "rejected — mavjud qator avvalgi holatga, yangi qator o'chadi",
      () async {
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
          rowVersion: 7,
        );
        await db.into(db.transactions).insert(server.toCompanion());
        ok(
          await EditTransaction(deps)(
            'srv',
            (t) => t.copyWith(amount: const Money(99999)),
          ),
        );
        final fresh = await addExpense();
        remote.onPush = (mutations) async => Ok([
          for (final m in mutations)
            SyncPushResult.fromJson({
              'mutation_id': m.mutationId,
              'status': 'rejected',
              'code': 'month_closed',
              'message': 'oy yopilgan',
            }),
        ]);
        final report = await engine.push('h');
        expect(report.rejected, 2);
        final restored = (await localTx('srv'))!;
        expect((restored.amount, restored.rowVersion), (1000, 7));
        expect(await localTx(fresh.id), isNull);
        expect(await outbox(), isEmpty);
        final issues = await db.select(db.syncIssues).get();
        expect({for (final i in issues) i.code}, {'month_closed'});
      },
    );

    test(
      "rejected reja to'lovi — rejaning lokal to'lov holati ham qaytadi",
      () async {
        await db
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
                plannedAmount: const Money(300000),
                rowVersion: 3,
              ).toCompanion(),
            );
        ok(await PayPlanned(deps)('rent'));
        expect((await deps.plans.byId('rent'))!.settledAt, isNotNull);
        remote.onPush = (mutations) async => Ok([
          for (final m in mutations)
            SyncPushResult.fromJson({
              'mutation_id': m.mutationId,
              'status': 'rejected',
              'code': 'month_closed',
              'message': 'oy yopilgan',
            }),
        ]);

        final report = await engine.push('h');

        // Faqat amal yuborilgan (reja hosilasi navbatda yo'q).
        expect(remote.pushes.single.single.table, 'transactions');
        expect(report.rejected, 1);
        final plan = (await deps.plans.byId('rent'))!;
        expect(plan.paidAmount.isZero, isTrue);
        expect(plan.settledAt, isNull);
        expect(plan.rowVersion, 3);
      },
    );

    test('paketlar: ≤ 100 mutatsiya, hammasi yuboriladi', () async {
      for (var i = 0; i < 150; i++) {
        await addExpense(amount: 1000 + i);
      }
      final report = await engine.push('h');
      expect([for (final p in remote.pushes) p.length], [100, 50]);
      expect(report.pushed, 150);
      expect(await outbox(), isEmpty);
    });

    test("javoblar soni mos emas — to'xtaydi (cheksiz sikl yo'q)", () async {
      await addExpense();
      await addExpense();
      remote.onPush = (mutations) async =>
          Ok([FakeRemote.okResult(mutations.first, version: 9)]);
      final report = await engine.push('h');
      expect(report.failure, const RejectedFailure('invalid_response'));
      expect(remote.pushes, hasLength(1));
      expect(await outbox(), hasLength(2));
    });

    test("sessiya eskirgan — to'xtaydi, pull chaqirilmaydi", () async {
      await addExpense();
      remote.onPush = (_) async => const Err(UnauthorizedFailure());
      final report = await engine.sync('h');
      expect(report.failure, isA<UnauthorizedFailure>());
      expect(remote.pulls, isEmpty);
    });
  });

  group('pull', () {
    Map<String, Object?> serverTx(
      String id, {
      int version = 50,
      String? note,
      String? deletedAt,
    }) => {
      'id': id,
      'household_id': 'h',
      'kind': 'expense',
      'account_id': 'card',
      'to_account_id': null,
      'amount': 1000,
      'to_amount': null,
      'amount_base': 1000,
      'fx_rate': null,
      'category_id': 'food',
      'payee': null,
      'occurred_on': '2026-10-01',
      'budget_month': '2026-10-01',
      'budget_month_source': 'auto',
      'planned_item_id': null,
      'debt_id': null,
      'note': note,
      'source': 'manual',
      'created_by': null,
      'created_at': '2026-10-01T05:00:00+00:00',
      'updated_at': '2026-10-01T05:00:00+00:00',
      'deleted_at': deletedAt,
      'row_version': version,
    };

    test('sahifalab, kursor saqlanadi; tombstone, oy va byudjet ham', () async {
      remote.pages
        ..add(
          Ok(
            FakeRemote.page(
              [
                ('transactions', serverTx('a', version: 51)),
                (
                  'households',
                  {
                    'id': 'h',
                    'name': 'Oila',
                    'base_currency': 'UZS',
                    'timezone': 'Asia/Tashkent',
                    'personal_fund_mode': 'percent',
                    'personal_fund_percent': 10,
                    'personal_fund_fixed_amount': 0,
                    'personal_fund_day': 5,
                    'personal_fund_source_account_id': null,
                    'auto_open_month': true,
                    'strict_month_lock': false,
                    'onboarded_at': null,
                    'row_version': 52,
                  },
                ),
              ],
              cursor: 52,
              hasMore: true,
            ),
          ),
        )
        ..add(
          Ok(
            FakeRemote.page([
              (
                'transactions',
                serverTx(
                  'a',
                  version: 53,
                  deletedAt: '2026-10-02T00:00:00+00:00',
                ),
              ),
              (
                'months',
                {
                  'household_id': 'h',
                  'month': '2026-10-01',
                  'opened_at': '2026-10-01T00:05:00+00:00',
                  'closed_at': null,
                  'closed_by': null,
                  'row_version': 54,
                },
              ),
              ('future_table', {'id': 'x'}),
            ], cursor: 54),
          ),
        );
      final report = await engine.pull('h');
      expect((report.pulled, report.ok), (5, true));
      expect(remote.pulls, [0, 52]);
      expect((await localTx('a'))!.deletedAt, isNotNull);
      expect((await db.select(db.households).getSingle()).name, 'Oila');
      expect(await db.select(db.months).get(), hasLength(1));
      final state = await db.select(db.syncState).getSingle();
      expect((state.cursor, state.lastPullAt != null), (54, true));

      await engine.pull('h');
      expect(remote.pulls.last, 54);
    });

    test(
      'NULL ga qaytgan maydon ham yangilanadi (tiklangan tombstone)',
      () async {
        remote.pages
          ..add(
            Ok(
              FakeRemote.page([
                (
                  'transactions',
                  serverTx(
                    'a',
                    note: 'eslatma',
                    deletedAt: '2026-10-02T00:00:00+00:00',
                  ),
                ),
              ], cursor: 51),
            ),
          )
          ..add(
            Ok(
              FakeRemote.page([
                ('transactions', serverTx('a', version: 52)),
              ], cursor: 52),
            ),
          );
        await engine.pull('h');
        expect((await localTx('a'))!.deletedAt, isNotNull);
        await engine.pull('h');
        final row = (await localTx('a'))!;
        expect((row.deletedAt, row.note, row.rowVersion), (null, null, 52));
      },
    );

    test("yuborilmagan lokal o'zgarish ustiga yozilmaydi", () async {
      final tx = await addExpense();
      remote.pages.add(
        Ok(
          FakeRemote.page([
            ('transactions', serverTx(tx.id, note: 'server')),
          ], cursor: 60),
        ),
      );
      await engine.pull('h');
      expect((await localTx(tx.id))!.note, isNull);
    });

    test(
      'resync_required — tozalanib qayta yuklanadi, yuborilmaganlar qoladi',
      () async {
        final mine = await addExpense();
        await db
            .into(db.transactions)
            .insert(TransactionRow.fromJson(serverTx('old')));
        await db
            .into(db.syncState)
            .insert(
              SyncStateCompanion.insert(
                householdId: 'h',
                cursor: const Value(40),
              ),
            );
        remote.pages
          ..add(Ok(FakeRemote.page(const [], cursor: 0, resync: true)))
          ..add(
            Ok(
              FakeRemote.page([('transactions', serverTx('new'))], cursor: 70),
            ),
          );
        await engine.pull('h');
        expect(remote.pulls, [40, 0]);
        expect(await localTx('old'), isNull);
        expect(await localTx('new'), isNotNull);
        expect(await localTx(mine.id), isNotNull);
        expect((await db.select(db.syncState).getSingle()).cursor, 70);
      },
    );

    test("pull xatosi — kursor o'zgarmaydi, xato saqlanadi", () async {
      remote.pages.add(const Err(OfflineFailure()));
      final report = await engine.pull('h');
      expect(report.failure, isA<OfflineFailure>());
      final state = await db.select(db.syncState).getSingle();
      expect((state.cursor, state.lastError), (0, 'OfflineFailure'));
    });
  });

  test(
    'E29 (BR-191): sinxrondan keyin kurslar lokal jadvalga tushadi',
    () async {
      remote.rates = [
        (
          currency: Currency.usd,
          date: LocalDate(2026, 10, 1),
          rate: FxRate.tryParse('12600')!,
        ),
      ];
      await engine.sync('h');

      final rows = await db.select(db.exchangeRates).get();
      expect(
        [for (final row in rows) (row.currency, row.rateDate, row.rateToBase)],
        [('USD', '2026-10-01', '12600')],
      );
      // Birinchi marta — bir yillik tarix so'raladi.
      expect(remote.rateRequests.single.year, 2025);

      // Ikkinchi sikl — faqat oxirgi sanadan keyingilari.
      await engine.sync('h');
      expect(remote.rateRequests.last, LocalDate(2026, 10, 1));
    },
  );

  test(
    'sync: push, keyin pull; bir vaqtda bitta sikl, keyingisi navbatga',
    () async {
      await addExpense();
      final first = engine.sync('h');
      final second = engine.sync('h');
      expect(identical(first, second), isTrue);
      final report = await first;
      expect((report.pushed, report.ok), (1, true));
      // Kelib qolgan ikkinchi chaqiruv — birinchisidan keyin yana bir sikl.
      await pumpEventQueue();
      expect(remote.pulls, hasLength(2));
    },
  );
}
