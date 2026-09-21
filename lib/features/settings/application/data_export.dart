import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';

/// E19-T04: byudjetning qurilmadagi nusxasi JSON faylga (ulashish uchun).
/// Jadvallar bo'lak-bo'lak o'qiladi va faylga oqim bilan yoziladi — katta
/// tarix ham xotiraga to'liq yuklanmaydi.
final class DataExport {
  const new(this._db);

  final AppDatabase _db;

  /// Bir so'rovda o'qiladigan qatorlar.
  static const int chunkSize = 500;
  static const String format = 'my-wallet-export';
  static const int version = 1;

  /// `household_id` li jadvallar — eksport tarkibi (sinxron bilan bir xil).
  static const List<String> tables = [
    'accounts',
    'categories',
    'category_limits',
    'recurring_rules',
    'quick_actions',
    'tags',
    'debts',
    'goals',
    'months',
    'planned_items',
    'transactions',
    'transaction_tags',
    'attachments',
  ];

  Future<File> write(
    String householdId, {
    required Directory directory,
    required DateTime now,
  }) async {
    final file = File(
      '${directory.path}/my-wallet-${now.toIso8601String().substring(0, 10)}.json',
    );
    final sink = file.openWrite();
    try {
      sink.write(
        '{"format":${jsonEncode(format)},"version":$version,'
        '"exported_at":${jsonEncode(now.toUtc().toIso8601String())},'
        '"household":${jsonEncode(await _household(householdId))},'
        '"tables":{',
      );
      for (final (index, table) in tables.indexed) {
        if (index > 0) sink.write(',');
        sink.write('${jsonEncode(table)}:[');
        var first = true;
        await for (final row in _rows(table, householdId)) {
          if (!first) sink.write(',');
          sink.write(jsonEncode(row));
          first = false;
        }
        sink.write(']');
      }
      sink.write('}}');
    } finally {
      await sink.close();
    }
    return file;
  }

  Future<Map<String, Object?>?> _household(String householdId) async {
    final row = await (_db.select(
      _db.households,
    )..where((h) => h.id.equals(householdId))).getSingleOrNull();
    return row?.toJson();
  }

  /// Jadval qatorlari — `rowid` bo'yicha keyset bo'laklari; ustunlar aniq
  /// sanab o'tiladi (jadval ta'rifidan).
  Stream<Map<String, Object?>> _rows(String table, String householdId) async* {
    final info = _db.allTables.firstWhere((t) => t.actualTableName == table);
    final columns = [for (final c in info.$columns) c.name].join(', ');
    var after = 0;
    while (true) {
      final rows = await _db
          .customSelect(
            'SELECT rowid AS _rowid, $columns FROM $table '
            'WHERE household_id = ? AND rowid > ? ORDER BY rowid LIMIT ?',
            variables: [
              Variable.withString(householdId),
              Variable.withInt(after),
              Variable.withInt(chunkSize),
            ],
            readsFrom: {info},
          )
          .get();
      for (final row in rows) {
        yield {
          for (final MapEntry(:key, :value) in row.data.entries)
            if (key != '_rowid') key: value,
        };
      }
      if (rows.length < chunkSize) return;
      after = rows.last.read<int>('_rowid');
    }
  }
}
