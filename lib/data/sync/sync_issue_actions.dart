import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/json_read.dart';
import 'package:my_wallet/data/sync/sync_tables.dart';

/// "Sinxron holati" ekranidagi amallar (BR-006).
final class SyncIssueActions {
  new(this._db, {required this.newId, required this.now})
    : _tables = SyncTables(_db);

  final AppDatabase _db;
  final SyncTables _tables;
  final String Function() newId;
  final DateTime Function() now;

  /// To'qnashuvda "Mening versiyam": lokal o'zgarish server versiyasi ustiga
  /// qo'yiladi va qayta yuboriladi (yangi `base_version` bilan). Shu qatorda
  /// keyinroq yangi o'zgarish bo'lsa — u ustun, muammo shunchaki yopiladi.
  Future<void> keepMine(SyncIssueRow issue) => _db.transaction(() async {
    final serverRow = issue.serverRow;
    if (issue.status != 'conflict' || serverRow == null) {
      throw ArgumentError.value(issue.status, 'issue', 'faqat conflict');
    }
    final newer =
        await (_db.select(_db.outbox)..where(
              (o) =>
                  o.targetTable.equals(issue.targetTable) &
                  o.recordId.equals(issue.recordId),
            ))
            .get();
    if (newer.isEmpty) {
      final server = asObject(jsonDecode(serverRow));
      final local = asObject(jsonDecode(issue.localData));
      await _tables.upsert(issue.targetTable, {...server, ...local});
      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              mutationId: newId(),
              householdId: issue.householdId,
              targetTable: issue.targetTable,
              recordId: issue.recordId,
              op: 'upsert',
              baseVersion: Value(read<int>(server, 'row_version')),
              data: Value(issue.localData),
              baseRow: Value(serverRow),
              createdAt: now(),
            ),
          );
    }
    await _resolve(issue);
  });

  /// Muammoni ko'rildi deb yopish (server holati qoladi).
  Future<void> dismiss(SyncIssueRow issue) => _resolve(issue);

  /// "To'liq qayta yuklash": byudjetning lokal nusxasi tozalanadi (yuborilmagan
  /// o'zgarishlardan tashqari), keyingi sinxron noldan yuklaydi.
  Future<void> resetHousehold(String householdId) => _db.transaction(() async {
    await _tables.clearHousehold(householdId);
    await (_db.update(_db.syncState)
          ..where((s) => s.householdId.equals(householdId)))
        .write(const SyncStateCompanion(cursor: Value(0)));
  });

  Future<void> _resolve(SyncIssueRow issue) =>
      (_db.update(_db.syncIssues)..where((i) => i.id.equals(issue.id))).write(
        SyncIssuesCompanion(resolvedAt: Value(now())),
      );
}
