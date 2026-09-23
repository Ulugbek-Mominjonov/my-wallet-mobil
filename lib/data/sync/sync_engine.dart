import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:my_wallet/data/remote/remote_api.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/sync/sync_tables.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Bitta sinxron sikli natijasi (SyncStatus ekrani uchun).
@immutable
final class SyncReport {
  const new({
    this.pushed = 0,
    this.conflicts = 0,
    this.rejected = 0,
    this.pulled = 0,
    this.failure,
  });

  final int pushed;
  final int conflicts;
  final int rejected;
  final int pulled;

  /// Sikl to'xtagan sabab (tarmoq, sessiya, server) — bo'lmasa muvaffaqiyat.
  final Failure? failure;

  bool get ok => failure == null;

  SyncReport _with({
    int pushed = 0,
    int conflicts = 0,
    int rejected = 0,
    int pulled = 0,
    Failure? failure,
  }) => SyncReport(
    pushed: this.pushed + pushed,
    conflicts: this.conflicts + conflicts,
    rejected: this.rejected + rejected,
    pulled: this.pulled + pulled,
    failure: failure ?? this.failure,
  );
}

/// ARXITEKTURA 5: outbox → `sync_push`, keyin `sync_pull` → lokal jadvallar.
/// Bir vaqtda bitta sikl; ishlayotganida kelgan chaqiruv — tugagach yana bir
/// marta (so'ngi o'zgarishlar ham ketadi).
final class SyncEngine {
  new(this._db, this._api, {required this.deviceId, required this.now})
    : _tables = SyncTables(_db);

  /// `sync_push` paketi chegarasi (serverdagi `sync_push_max`).
  static const pushBatch = 100;

  final AppDatabase _db;
  final RemoteApi _api;
  final SyncTables _tables;

  /// Qurilma ID si (`sync_mutations.device_id`).
  final String deviceId;
  final DateTime Function() now;

  Future<SyncReport>? _running;
  var _again = false;

  Future<SyncReport> sync(String householdId) {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final run = _runCycle(householdId);
    _running = run;
    unawaited(
      run.whenComplete(() {
        _running = null;
        if (_again) {
          _again = false;
          unawaited(sync(householdId));
        }
      }),
    );
    return run;
  }

  Future<SyncReport> _runCycle(String householdId) async {
    final pushed = await push(householdId);
    if (!pushed.ok) return pushed;
    final pulled = await pull(householdId);
    if (pulled.ok) await pullRates();
    return pushed._with(pulled: pulled.pulled, failure: pulled.failure);
  }

  /// E29 (BR-191): valyuta kurslari — lokal nusxa. Har sinxronda faqat
  /// oxirgi olingan sanadan keyingilari (sikl xatosi bo'lsa — jimgina
  /// o'tkazib yuboriladi: kurslar sinxronni to'xtatmaydi).
  Future<void> pullRates() async {
    final last =
        await (_db.selectOnly(_db.exchangeRates)
              ..addColumns([_db.exchangeRates.rateDate.max()]))
            .map((row) => row.read(_db.exchangeRates.rateDate.max()))
            .getSingleOrNull();
    // Birinchi marta — o'tgan yildan (CBU kunlik kurslari; ~250 qator).
    final since = last == null
        ? LocalDate.fromDateTime(now()).addDays(-_ratesHistoryDays)
        : LocalDate.parse(last);
    final result = await _api.fxRates(since);
    if (result case Err(:final failure)) {
      AppLog.info('Kurslar olinmadi: $failure');
      return;
    }
    final rows = (result as Ok<List<FxRateRow>>).value;
    if (rows.isEmpty) return;
    await _db.batch(
      (batch) => batch.insertAllOnConflictUpdate(_db.exchangeRates, [
        for (final row in rows)
          ExchangeRatesCompanion.insert(
            currency: row.currency.code,
            rateDate: row.date.toString(),
            rateToBase: row.rate.toString(),
          ),
      ]),
    );
  }

  /// Birinchi yuklashda olinadigan tarix (kun).
  static const _ratesHistoryDays = 366;

  // ─── Push ────────────────────────────────────────────────────────────────

  Future<SyncReport> push(String householdId) async {
    var report = const SyncReport();
    for (;;) {
      final batch = await _takeBatch(householdId);
      if (batch.isEmpty) return report;
      final result = await _api.syncPush(householdId, deviceId, [
        for (final m in batch)
          SyncMutation(
            mutationId: m.mutationId,
            table: m.targetTable,
            op: m.op,
            id: m.recordId,
            baseVersion: m.baseVersion,
            data: asObject(jsonDecode(m.data)),
          ),
      ]);
      switch (result) {
        case Err(:final failure):
          await _recordPushFailure(householdId, batch, failure);
          return report._with(failure: failure);
        case Ok(value: final results) when results.length != batch.length:
          // Har mutatsiyaga bitta javob — shartnoma; aks holda sikl to'xtaydi.
          const failure = RejectedFailure('invalid_response');
          await _recordPushFailure(householdId, batch, failure);
          return report._with(failure: failure);
        case Ok(value: final results):
          report = report._with(
            pushed: results.length,
            conflicts: results
                .where((r) => r.status == SyncPushStatus.conflict)
                .length,
            rejected: results
                .where((r) => r.status == SyncPushStatus.rejected)
                .length,
          );
          await _applyResults(householdId, batch, results);
      }
    }
  }

  /// Navbat boshidan ≤ 100 mutatsiya, har qatordan bittasi (keyingisi oldingi
  /// tasdiqlangach — yangi `base_version` bilan). Tanlanganlar `sending`.
  /// Navbat bo'shaguncha takrorlanadi (yuborish paytidagi yangi yozuvlar ham).
  Future<List<OutboxRow>> _takeBatch(String householdId) =>
      _db.transaction(() async {
        final rows =
            await (_db.select(_db.outbox)
                  ..where((o) => o.householdId.equals(householdId))
                  ..orderBy([(o) => OrderingTerm.asc(o.id)]))
                .get();
        final seen = <(String, String)>{};
        final batch = <OutboxRow>[];
        for (final row in rows) {
          if (batch.length == pushBatch) break;
          if (seen.add((row.targetTable, row.recordId))) batch.add(row);
        }
        await (_db.update(_db.outbox)..where(
              (o) =>
                  o.id.isIn([for (final m in batch) m.id]) &
                  o.status.equals('pending'),
            ))
            .write(const OutboxCompanion(status: Value('sending')));
        return batch;
      });

  Future<void> _recordPushFailure(
    String householdId,
    List<OutboxRow> batch,
    Failure failure,
  ) => _db.transaction(() async {
    // Tarmoq xatosi — o'sha mutatsiyalar (o'sha ID bilan) keyin qayta
    // yuboriladi; server natijasini idempotent qaytaradi.
    await _db.customUpdate(
      'UPDATE outbox SET attempts = attempts + 1, last_error = ? '
      'WHERE id IN (${List.filled(batch.length, '?').join(', ')})',
      variables: [
        Variable.withString('$failure'),
        for (final m in batch) Variable.withInt(m.id),
      ],
      updates: {_db.outbox},
    );
    await _saveState(householdId, lastError: Value('$failure'));
  });

  Future<void> _applyResults(
    String householdId,
    List<OutboxRow> batch,
    List<SyncPushResult> results,
  ) => _db.transaction(() async {
    final byMutation = {for (final m in batch) m.mutationId: m};
    for (final result in results) {
      final mutation = byMutation[result.mutationId];
      if (mutation == null) {
        throw StateError("Server noma'lum mutatsiyaga javob berdi");
      }
      final later =
          await (_db.select(_db.outbox)
                ..where(
                  (o) =>
                      o.targetTable.equals(mutation.targetTable) &
                      o.recordId.equals(mutation.recordId) &
                      o.id.isNotValue(mutation.id),
                )
                ..orderBy([(o) => OrderingTerm.asc(o.id)]))
              .get();
      switch (result.status) {
        case SyncPushStatus.ok:
          await _applyOk(mutation, result.row, later);
        case SyncPushStatus.conflict:
          await _applyConflict(householdId, mutation, result, later);
        case SyncPushStatus.rejected:
          await _applyRejected(householdId, mutation, result, later);
      }
    }
    await _saveState(
      householdId,
      lastPushAt: Value(now()),
      lastError: const Value(null),
    );
  });

  /// `ok`: kanonik qator (server hisoblagan maydonlar bilan). Keyinroq lokal
  /// o'zgarish kutayotgan bo'lsa — faqat versiya: u yangi versiyaga
  /// asoslanadi, qatorning lokal holati saqlanadi.
  Future<void> _applyOk(
    OutboxRow mutation,
    Json? row,
    List<OutboxRow> later,
  ) async {
    await _deleteMutations([mutation]);
    if (row == null) return;
    if (later.isEmpty) {
      await _tables.upsert(mutation.targetTable, row);
      return;
    }
    final version = read<int>(row, 'row_version');
    await _tables.setRowVersion(
      mutation.targetTable,
      mutation.recordId,
      version,
    );
    await (_db.update(
      _db.outbox,
    )..where((o) => o.id.equals(later.first.id))).write(
      OutboxCompanion(
        baseVersion: Value(version),
        baseRow: Value(jsonEncode(row)),
      ),
    );
  }

  /// BR-006: `conflict` — boshqa qurilma o'zgartirgan: server qatori yoziladi,
  /// shu qatorning navbatdagi o'zgarishlari to'xtatiladi, foydalanuvchiga
  /// muammo ko'rsatiladi (lokal holati bilan).
  Future<void> _applyConflict(
    String householdId,
    OutboxRow mutation,
    SyncPushResult result,
    List<OutboxRow> later,
  ) async {
    final row = result.row;
    if (row != null) await _tables.upsert(mutation.targetTable, row);
    await _deleteMutations([mutation, ...later]);
    await _addIssue(
      householdId,
      mutation,
      later,
      status: 'conflict',
      serverRow: row == null ? null : jsonEncode(row),
    );
  }

  /// `rejected`: lokal o'zgarish qaytariladi (serverdagi holatga yoki — yangi
  /// qator bo'lsa — o'chiriladi), sabab foydalanuvchiga ko'rsatiladi.
  Future<void> _applyRejected(
    String householdId,
    OutboxRow mutation,
    SyncPushResult result,
    List<OutboxRow> later,
  ) async {
    final baseRow = mutation.baseRow;
    final restored = baseRow == null ? null : asObject(jsonDecode(baseRow));
    if (restored == null) {
      await _tables.deleteRow(mutation.targetTable, mutation.recordId);
    } else {
      await _tables.upsert(mutation.targetTable, restored);
    }
    await _deleteMutations([mutation, ...later]);
    if (mutation.targetTable == 'transactions') {
      // Amal rejaga bog'langan bo'lsa — rejaning lokal to'lov holati ham
      // qaytadi (u navbatga yozilmagan, serverdagisi o'zgarmagan).
      final plans = [
        for (final data in [
          restored,
          for (final m in [mutation, ...later]) asObject(jsonDecode(m.data)),
        ])
          if (data?['planned_item_id'] case final String id) id,
      ];
      await recomputeLocalPlanPayments(_db, householdId, plans, now: now());
    }
    await _addIssue(
      householdId,
      mutation,
      later,
      status: 'rejected',
      code: result.code,
      message: result.message,
    );
  }

  Future<void> _addIssue(
    String householdId,
    OutboxRow mutation,
    List<OutboxRow> later, {
    required String status,
    String? serverRow,
    String? code,
    String? message,
  }) => _db
      .into(_db.syncIssues)
      .insert(
        SyncIssuesCompanion.insert(
          householdId: householdId,
          mutationId: mutation.mutationId,
          targetTable: mutation.targetTable,
          recordId: mutation.recordId,
          status: status,
          code: Value(code),
          message: Value(message),
          serverRow: Value(serverRow),
          // Foydalanuvchi ko'rgan oxirgi lokal holat.
          localData: later.isEmpty ? mutation.data : later.last.data,
          createdAt: now(),
        ),
      );

  Future<void> _deleteMutations(List<OutboxRow> mutations) => (_db.delete(
    _db.outbox,
  )..where((o) => o.id.isIn([for (final m in mutations) m.id]))).go();

  // ─── Pull ────────────────────────────────────────────────────────────────

  Future<SyncReport> pull(String householdId) async {
    var pulled = 0;
    var cursor = await _cursor(householdId);
    for (;;) {
      final result = await _api.syncPull(householdId, cursor);
      if (result case Err(:final failure)) {
        await _saveState(householdId, lastError: Value('$failure'));
        return SyncReport(pulled: pulled, failure: failure);
      }
      final page = (result as Ok<SyncPullPage>).value;
      if (page.resyncRequired) {
        await _db.transaction(() async {
          await _tables.clearHousehold(householdId);
          await _saveState(householdId, cursor: const Value(0));
        });
        cursor = 0;
        continue;
      }
      await _db.transaction(() async {
        final protected = {
          for (final m in await (_db.select(
            _db.outbox,
          )..where((o) => o.householdId.equals(householdId))).get())
            (m.targetTable, m.recordId),
        };
        for (final change in page.changes) {
          if (!_tables.isKnown(change.table)) {
            // Yangi server jadvali (ilova eski) — keyingi versiyada.
            AppLog.info("Noma'lum sinxron jadvali: ${change.table}");
            continue;
          }
          final id = change.row['id'];
          if (id is String && protected.contains((change.table, id))) continue;
          await _tables.upsert(change.table, change.row);
        }
        await _saveState(
          householdId,
          cursor: Value(page.nextCursor),
          lastPullAt: Value(now()),
          lastError: const Value(null),
        );
      });
      pulled += page.changes.length;
      cursor = page.nextCursor;
      if (!page.hasMore) return SyncReport(pulled: pulled);
    }
  }

  Future<int> _cursor(String householdId) async =>
      (await (_db.select(
            _db.syncState,
          )..where((s) => s.householdId.equals(householdId))).getSingleOrNull())
          ?.cursor ??
      0;

  Future<void> _saveState(
    String householdId, {
    Value<int> cursor = const Value.absent(),
    Value<DateTime?> lastPullAt = const Value.absent(),
    Value<DateTime?> lastPushAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => _db
      .into(_db.syncState)
      .insert(
        SyncStateCompanion.insert(
          householdId: householdId,
          cursor: cursor,
          lastPullAt: lastPullAt,
          lastPushAt: lastPushAt,
          lastError: lastError,
        ),
        onConflict: DoUpdate(
          (_) => SyncStateCompanion(
            cursor: cursor,
            lastPullAt: lastPullAt,
            lastPushAt: lastPushAt,
            lastError: lastError,
          ),
        ),
      );
}
