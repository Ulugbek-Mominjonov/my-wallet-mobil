import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/sync/background_sync.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:my_wallet/data/sync/sync_issue_actions.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/data/sync/sync_scheduler.dart';
import 'package:my_wallet/data/sync/sync_status.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'fake_remote.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 10, 5, 4);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.households)
        .insert(
          const Household(
            id: 'h',
            name: 'Uy',
            personalFund: PersonalFundRule(),
          ).toRow(),
        );
  });
  tearDown(() => db.close());

  final serverRow = {
    'id': 't1',
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
    'note': 'server',
    'source': 'manual',
    'created_by': null,
    'created_at': '2026-10-01T05:00:00+00:00',
    'updated_at': '2026-10-01T05:00:00+00:00',
    'deleted_at': null,
    'row_version': 20,
  };

  Future<SyncIssueRow> conflictIssue() async {
    await db.into(db.transactions).insert(TransactionRow.fromJson(serverRow));
    final id = await db
        .into(db.syncIssues)
        .insert(
          SyncIssuesCompanion.insert(
            householdId: 'h',
            mutationId: 'm1',
            targetTable: 'transactions',
            recordId: 't1',
            status: 'conflict',
            serverRow: Value(jsonEncode(serverRow)),
            localData: jsonEncode({'note': 'mening', 'amount': 2000}),
            createdAt: now,
          ),
        );
    return await (db.select(
      db.syncIssues,
    )..where((i) => i.id.equals(id))).getSingle();
  }

  group('muammo amallari (BR-006)', () {
    SyncIssueActions actions() =>
        SyncIssueActions(db, newId: () => 'm2', now: () => now);

    test(
      '"Mening versiyam" — lokal holat server ustiga, yangi versiya',
      () async {
        final issue = await conflictIssue();
        await actions().keepMine(issue);
        final row = await db.select(db.transactions).getSingle();
        expect((row.note, row.amount, row.rowVersion), ('mening', 2000, 20));
        final mutation = await db.select(db.outbox).getSingle();
        expect((mutation.mutationId, mutation.baseVersion), ('m2', 20));
        expect(jsonDecode(mutation.data), {'note': 'mening', 'amount': 2000});
        expect(jsonDecode(mutation.baseRow!), containsPair('note', 'server'));
        expect((await db.select(db.syncIssues).getSingle()).resolvedAt, now);
      },
    );

    test(
      "keyinroq yangi o'zgarish bo'lsa — u ustun, muammo yopiladi",
      () async {
        final issue = await conflictIssue();
        await db
            .into(db.outbox)
            .insert(
              OutboxCompanion.insert(
                mutationId: 'newer',
                householdId: 'h',
                targetTable: 'transactions',
                recordId: 't1',
                op: 'upsert',
                createdAt: now,
              ),
            );
        await actions().keepMine(issue);
        expect((await db.select(db.transactions).getSingle()).note, 'server');
        expect(await db.select(db.outbox).get(), hasLength(1));
        expect(
          (await db.select(db.syncIssues).getSingle()).resolvedAt,
          isNotNull,
        );
      },
    );

    test('rad etishda "mening versiyam" yo\'q; "tushunarli" yopadi', () async {
      final id = await db
          .into(db.syncIssues)
          .insert(
            SyncIssuesCompanion.insert(
              householdId: 'h',
              mutationId: 'm1',
              targetTable: 'transactions',
              recordId: 't1',
              status: 'rejected',
              code: const Value('month_closed'),
              localData: '{}',
              createdAt: now,
            ),
          );
      final issue = await (db.select(
        db.syncIssues,
      )..where((i) => i.id.equals(id))).getSingle();
      await expectLater(actions().keepMine(issue), throwsArgumentError);
      await actions().dismiss(issue);
      expect((await db.select(db.syncIssues).getSingle()).resolvedAt, now);
    });

    test(
      "to'liq qayta yuklash — kursor nolga, lokal nusxa tozalanadi",
      () async {
        await db
            .into(db.transactions)
            .insert(TransactionRow.fromJson(serverRow));
        await db
            .into(db.syncState)
            .insert(
              SyncStateCompanion.insert(
                householdId: 'h',
                cursor: const Value(99),
              ),
            );
        await actions().resetHousehold('h');
        expect(await db.select(db.transactions).get(), isEmpty);
        expect((await db.select(db.syncState).getSingle()).cursor, 0);
      },
    );
  });

  group('fon sinxroni', () {
    test('har byudjet sinxronlanadi; tarmoq xatosi — qayta urinish', () async {
      final remote = FakeRemote();
      final engine = SyncEngine(db, remote, deviceId: 'd', now: () => now);
      expect(await runBackgroundSync(db, engine), isTrue);
      expect(remote.pulls, [0]);

      remote.pages.add(const Err(OfflineFailure()));
      expect(await runBackgroundSync(db, engine), isFalse);
    });

    test("sessiya yo'q — qayta urinish befoyda", () async {
      final remote = FakeRemote()..pages.add(const Err(UnauthorizedFailure()));
      final engine = SyncEngine(db, remote, deviceId: 'd', now: () => now);
      expect(await runBackgroundSync(db, engine), isTrue);
    });

    test('qurilma ID si — bir marta yaratiladi', () async {
      var n = 0;
      String newId() => 'device-${n++}';
      expect(await db.deviceId(newId: newId), 'device-0');
      expect(await db.deviceId(newId: newId), 'device-0');
    });
  });

  group('holat', () {
    test('ustuvorlik: muammo > sessiya > jarayon > oflayn > navbat', () {
      final issue = SyncIssueRow(
        id: 1,
        householdId: 'h',
        mutationId: 'm',
        targetTable: 'transactions',
        recordId: 'r',
        status: 'conflict',
        localData: '{}',
        createdAt: now,
      );
      expect(
        SyncStatus(issues: [issue], running: true).phase,
        SyncPhase.issues,
      );
      expect(
        const SyncStatus(
          running: true,
          lastFailure: UnauthorizedFailure(),
        ).phase,
        SyncPhase.signedOut,
      );
      expect(
        const SyncStatus(running: true, pendingCount: 3).phase,
        SyncPhase.syncing,
      );
      expect(
        const SyncStatus(pendingCount: 3, lastFailure: OfflineFailure()).phase,
        SyncPhase.offline,
      );
      expect(const SyncStatus(pendingCount: 3).phase, SyncPhase.pending);
      expect(const SyncStatus().phase, SyncPhase.synced);
    });

    test("oxirgi sinxron — pull va push'ning keyingisi", () {
      final early = DateTime.utc(2026, 10, 2);
      final late = DateTime.utc(2026, 10, 3);
      expect(const SyncStatus().lastSyncAt, isNull);
      expect(SyncStatus(lastPullAt: early).lastSyncAt, early);
      expect(SyncStatus(lastPushAt: late).lastSyncAt, late);
      expect(SyncStatus(lastPullAt: late, lastPushAt: early).lastSyncAt, late);
      expect(SyncStatus(lastPullAt: early, lastPushAt: late).lastSyncAt, late);
    });

    test('jonli oqim: navbat, muammolar va rejalashtiruvchi holati', () async {
      final scheduler = SyncScheduler(
        () async => const SyncReport(failure: OfflineFailure()),
      );
      final statuses = <SyncStatus>[];
      final subscription = watchSyncStatus(
        db,
        'h',
        scheduler,
      ).listen(statuses.add);
      await pumpEventQueue();
      await db
          .into(db.outbox)
          .insert(
            OutboxCompanion.insert(
              mutationId: 'm',
              householdId: 'h',
              targetTable: 'transactions',
              recordId: 'r',
              op: 'upsert',
              createdAt: now,
            ),
          );
      await scheduler.refresh();
      await pumpEventQueue();
      expect(statuses.last.pendingCount, 1);
      expect(statuses.last.phase, SyncPhase.offline);
      expect(statuses.any((s) => s.running), isTrue);
      await subscription.cancel();
      scheduler.dispose();
    });
  });
}
