import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';

/// Lokal o'zgarishni `sync_push` navbatiga yozadi (ARXITEKTURA 5). Chaqiruvchi
/// — repository, qator yozuvi bilan **bitta tranzaksiyada**.
///
/// Birlashtirish: bir qatorning hali yuborilmagan (`pending`) mutatsiyasi
/// bo'lsa — yangi holat unga yoziladi (bitta mutatsiya, birinchi
/// `base_version` saqlanadi). Yuborilgan (`sending`) mutatsiyaga tegilmaydi:
/// javob yo'qolgan bo'lsa server shu `mutation_id` bo'yicha eski natijani
/// qaytaradi — keyingi o'zgarish yo'qolmasligi uchun u alohida mutatsiya.
final class OutboxWriter {
  const new(this._db, {required this.newId, required this.now});

  final AppDatabase _db;
  final String Function() newId;
  final DateTime Function() now;

  /// Server yozmaydigan (yoki mutatsiya boshqa joyda beradigan) maydonlar.
  static const _serverFields = {
    'id',
    'household_id',
    'row_version',
    'created_by',
    'created_at',
    'updated_at',
  };

  /// Push JSON'ida vaqtlar ISO matn (server `timestamptz`).
  static const _serializer = ValueSerializer.defaults(
    serializeDateTimeValuesAsString: true,
  );

  /// [row] — yozilgan qatorning to'liq lokal holati (`toJson` bilan).
  Future<void> enqueue({
    required String table,
    required String householdId,
    required DataClass row,
  }) async {
    final json = row.toJson(serializer: _serializer);
    final recordId = json['id']! as String;
    final version = json['row_version']! as int;
    final data = {
      for (final MapEntry(:key, :value) in json.entries)
        if (!_serverFields.contains(key)) key: value,
    };
    final pending =
        await (_db.select(_db.outbox)..where(
              (o) =>
                  o.targetTable.equals(table) &
                  o.recordId.equals(recordId) &
                  o.status.equals('pending'),
            ))
            .getSingleOrNull();

    // Serverga hech yetmagan yangi qator o'chirildi — yuboradigan narsa yo'q.
    final deleted = data['deleted_at'] != null;
    if (pending != null && pending.baseVersion == null && deleted) {
      await (_db.delete(
        _db.outbox,
      )..where((o) => o.id.equals(pending.id))).go();
      return;
    }
    if (pending != null) {
      await (_db.update(_db.outbox)..where((o) => o.id.equals(pending.id)))
          .write(OutboxCompanion(data: Value(jsonEncode(data))));
      return;
    }
    if (version == 0 && deleted) return;
    await _db
        .into(_db.outbox)
        .insert(
          OutboxCompanion.insert(
            mutationId: newId(),
            householdId: householdId,
            targetTable: table,
            recordId: recordId,
            op: 'upsert',
            baseVersion: Value(version == 0 ? null : version),
            data: Value(jsonEncode(data)),
            createdAt: now(),
          ),
        );
  }
}
