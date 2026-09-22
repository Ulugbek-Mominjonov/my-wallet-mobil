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

  /// Server hisoblaydigan, klient yozmaydigan maydonlar (contracts/api.md —
  /// "Server hisoblaydigan maydonlar"). Lokal nusxa darhol ko'rsatish uchun
  /// yangilanadi, lekin yuborilmaydi — server qiymati sinxronda keladi.
  /// Faqat shular o'zgargan yozuv mutatsiya yaratmaydi: bog'langan amal
  /// trigger'i serverda `row_version`ni oshiradi va bunday mutatsiya har
  /// safar conflict bo'lardi (E20-T04 e2e topdi).
  static const _derivedFields = {
    'planned_items': {'paid_amount', 'settled_at'},
  };

  /// Push JSON'ida vaqtlar ISO matn (server `timestamptz`).
  static const _serializer = ValueSerializer.defaults(
    serializeDateTimeValuesAsString: true,
  );

  /// [row] — yozilgan qatorning to'liq lokal holati (`toJson` bilan).
  /// [before] — yozuvdan oldingi holat (yangi qatorda null).
  Future<void> enqueue({
    required String table,
    required String householdId,
    required DataClass row,
    DataClass? before,
  }) async {
    final json = row.toJson(serializer: _serializer);
    final recordId = json['id']! as String;
    final version = json['row_version']! as int;
    final derived = _derivedFields[table] ?? const <String>{};
    final data = {
      for (final MapEntry(:key, :value) in json.entries)
        if (!_serverFields.contains(key) && !derived.contains(key)) key: value,
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
    if (before != null && _sameData(before, data)) return;
    // Qaytarish nuqtasi — tasdiqlanmagan birinchi o'zgarishdan oldingi holat:
    // yuborilayotgan mutatsiya bo'lsa uniki, aks holda yozuvdan oldingisi.
    final sending =
        await (_db.select(_db.outbox)
              ..where(
                (o) =>
                    o.targetTable.equals(table) &
                    o.recordId.equals(recordId) &
                    o.status.equals('sending'),
              )
              ..orderBy([(o) => OrderingTerm.asc(o.id)])
              ..limit(1))
            .getSingleOrNull();
    final baseRow = sending != null
        ? sending.baseRow
        : before == null
        ? null
        : jsonEncode(before.toJson(serializer: _serializer));
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
            baseRow: Value(baseRow),
            createdAt: now(),
          ),
        );
  }

  /// Yuboriladigan maydonlarning birortasi ham o'zgarmagan (masalan faqat
  /// server hisoblaydigan maydonlar).
  static bool _sameData(DataClass before, Map<String, Object?> data) {
    final previous = before.toJson(serializer: _serializer);
    return data.entries.every((e) => previous[e.key] == e.value);
  }
}
