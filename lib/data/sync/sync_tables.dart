import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/remote/json_read.dart';

/// Sinxron jadvallar — server nomi → lokal yozuv (pull qatori, kanonik
/// qator, qaytarish). Ro'yxat yopiq: jadval nomi SQL'ga faqat shu yerdan.
final class SyncTables {
  new(this._db)
    : _upserts = {
        'households': (json) => _db
            .into(_db.households)
            .insertOnConflictUpdate(
              HouseholdRow.fromJson(json).toCompanion(false),
            ),
        'accounts': (json) => _db
            .into(_db.accounts)
            .insertOnConflictUpdate(
              AccountRow.fromJson(json).toCompanion(false),
            ),
        'categories': (json) => _db
            .into(_db.categories)
            .insertOnConflictUpdate(
              CategoryRow.fromJson(json).toCompanion(false),
            ),
        'recurring_rules': (json) => _db
            .into(_db.recurringRules)
            .insertOnConflictUpdate(
              RecurringRuleRow.fromJson(json).toCompanion(false),
            ),
        'category_limits': (json) => _db
            .into(_db.categoryLimits)
            .insertOnConflictUpdate(
              CategoryLimitRow.fromJson(json).toCompanion(false),
            ),
        'quick_actions': (json) => _db
            .into(_db.quickActions)
            .insertOnConflictUpdate(
              QuickActionRow.fromJson(json).toCompanion(false),
            ),
        'tags': (json) => _db
            .into(_db.tags)
            .insertOnConflictUpdate(TagRow.fromJson(json).toCompanion(false)),
        'debts': (json) => _db
            .into(_db.debts)
            .insertOnConflictUpdate(DebtRow.fromJson(json).toCompanion(false)),
        'goals': (json) => _db
            .into(_db.goals)
            .insertOnConflictUpdate(GoalRow.fromJson(json).toCompanion(false)),
        'months': (json) => _db
            .into(_db.months)
            .insertOnConflictUpdate(MonthRow.fromJson(json).toCompanion(false)),
        'planned_items': (json) => _db
            .into(_db.plannedItems)
            .insertOnConflictUpdate(
              PlannedItemRow.fromJson(json).toCompanion(false),
            ),
        'transactions': (json) => _db
            .into(_db.transactions)
            .insertOnConflictUpdate(
              TransactionRow.fromJson(json).toCompanion(false),
            ),
        'transaction_tags': (json) => _db
            .into(_db.transactionTags)
            .insertOnConflictUpdate(
              TransactionTagRow.fromJson(json).toCompanion(false),
            ),
        'attachments': (json) => _db
            .into(_db.attachments)
            .insertOnConflictUpdate(
              AttachmentRow.fromJson(json).toCompanion(false),
            ),
      };

  final AppDatabase _db;
  final Map<String, Future<void> Function(Json row)> _upserts;

  /// `id` va `household_id` li jadvallar (byudjet va oylardan tashqari).
  static const _householdScoped = [
    'accounts',
    'categories',
    'recurring_rules',
    'category_limits',
    'quick_actions',
    'tags',
    'debts',
    'goals',
    'planned_items',
    'transactions',
    'transaction_tags',
    'attachments',
  ];

  bool isKnown(String table) => _upserts.containsKey(table);

  /// Server qatorini lokal jadvalga yozadi (bor bo'lsa — ustiga). Companion
  /// `nullToAbsent: false` bilan: NULL ga qaytgan maydon (tiklangan tombstone,
  /// o'chirilgan izoh) ham yangilanadi — data class insert'i NULL'ni tashlab
  /// yuborardi.
  Future<void> upsert(String table, Json row) {
    final upsert = _upserts[table];
    if (upsert == null) throw ArgumentError.value(table, 'table');
    return upsert(row);
  }

  /// Serverda yo'q (rad etilgan yangi) qatorni o'chiradi.
  Future<void> deleteRow(String table, String id) => _db.customUpdate(
    'DELETE FROM ${_checked(table)} WHERE id = ?',
    variables: [Variable.withString(id)],
    updates: {_db.allTables.firstWhere((t) => t.actualTableName == table)},
    updateKind: UpdateKind.delete,
  );

  /// Faqat versiyani yangilaydi (lokal yangiroq o'zgarish ustiga yozmasdan).
  Future<void> setRowVersion(String table, String id, int version) =>
      _db.customUpdate(
        'UPDATE ${_checked(table)} SET row_version = ? WHERE id = ?',
        variables: [Variable.withInt(version), Variable.withString(id)],
        updates: {_db.allTables.firstWhere((t) => t.actualTableName == table)},
      );

  /// `resync_required`: byudjetning lokal nusxasi tozalanadi — yuborilmagan
  /// o'zgarishli qatorlardan tashqari (ular push bilan serverga boradi).
  Future<void> clearHousehold(String householdId) async {
    for (final table in _householdScoped) {
      await _db.customUpdate(
        'DELETE FROM $table WHERE household_id = ? AND id NOT IN '
        '(SELECT record_id FROM outbox WHERE target_table = ?)',
        variables: [
          Variable.withString(householdId),
          Variable.withString(table),
        ],
        updates: {_db.allTables.firstWhere((t) => t.actualTableName == table)},
        updateKind: UpdateKind.delete,
      );
    }
    await (_db.delete(
      _db.months,
    )..where((m) => m.householdId.equals(householdId))).go();
  }

  String _checked(String table) {
    if (!_householdScoped.contains(table)) {
      throw ArgumentError.value(table, 'table');
    }
    return table;
  }
}
