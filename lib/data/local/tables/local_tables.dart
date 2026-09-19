// Deklarativ sxema: getter'larni faqat drift generatori o'qiydi (ish
// vaqtida chaqirilmaydi) — qoplama hisobidan tashqari; sxema
// database_test'da tekshiriladi.
// coverage:ignore-file
import 'package:drift/drift.dart';

// Faqat qurilmadagi jadvallar: yuborilmagan o'zgarishlar navbati, sinxron
// kursori va foydalanuvchiga ko'rsatiladigan muammolar (ARXITEKTURA 5).

/// Yuborilmagan o'zgarishlar (`sync_push` mutatsiyalari). Bir qatorning
/// yuborilmagan (`pending`) o'zgarishlari birlashtiriladi — bitta mutatsiya.
@DataClassName('OutboxRow')
@TableIndex.sql(
  'CREATE UNIQUE INDEX outbox_pending_record ON outbox '
  "(target_table, record_id) WHERE status = 'pending'",
)
@TableIndex(name: 'outbox_order', columns: {#householdId, #id})
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Idempotentlik kaliti (UUIDv7) — qayta yuborilsa server aynan shu
  /// natijani qaytaradi.
  TextColumn get mutationId => text().unique()();
  TextColumn get householdId => text()();

  /// Serverdagi jadval nomi (`transactions`, …).
  TextColumn get targetTable => text().named('target_table')();
  TextColumn get recordId => text()();

  /// `upsert` | `delete`.
  TextColumn get op => text()();

  /// Birinchi yuborilmagan o'zgarish paytidagi server versiyasi (NULL — yangi
  /// qator).
  IntColumn get baseVersion => integer().nullable()();

  /// Yoziladigan maydonlar (JSON, snake_case).
  TextColumn get data => text().withDefault(const Constant('{}'))();

  /// `pending` | `sending`.
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Byudjet bo'yicha pull kursori.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get householdId => text()();
  IntColumn get cursor => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPullAt => dateTime().nullable()();
  DateTimeColumn get lastPushAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {householdId};
}

/// BR-006: to'qnashuv va rad etilgan o'zgarishlar — "Sinxron holati" ekrani.
@DataClassName('SyncIssueRow')
@TableIndex(name: 'sync_issues_open', columns: {#householdId, #resolvedAt})
class SyncIssues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get householdId => text()();
  TextColumn get mutationId => text()();
  TextColumn get targetTable => text().named('target_table')();
  TextColumn get recordId => text()();

  /// `conflict` | `rejected`.
  TextColumn get status => text()();

  /// Rad etish kodi (biznes kod yoki SQLSTATE — contracts/api.md).
  TextColumn get code => text().nullable()();
  TextColumn get message => text().nullable()();

  /// Serverdagi kanonik qator (conflict) va yuborilgan o'zgarish (JSON).
  TextColumn get serverRow => text().nullable()();
  TextColumn get localData => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}
