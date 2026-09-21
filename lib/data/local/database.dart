import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:my_wallet/data/local/daos/directory_dao.dart';
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/tables/local_tables.dart';
import 'package:my_wallet/data/local/tables/sync_tables.dart';

part 'database.g.dart';

/// Lokal SQLite (offline-first, ARXITEKTURA 1–2). Sxema o'zgarsa —
/// `schemaVersion` +1, migratsiya qadami va snapshot
/// (`dart run drift_dev make-migrations`).
@DriftDatabase(
  tables: [
    Households,
    Accounts,
    Categories,
    RecurringRules,
    CategoryLimits,
    QuickActions,
    Tags,
    Debts,
    Goals,
    Months,
    PlannedItems,
    Transactions,
    TransactionTags,
    Attachments,
    Outbox,
    SyncState,
    SyncIssues,
    AppSettings,
    PendingUploads,
  ],
  daos: [LedgerDao, DirectoryDao],
)
class AppDatabase extends _$AppDatabase {
  new(super.e);

  /// Ilova bazasi (qurilma xotirasida, WAL rejimida).
  factory open() => AppDatabase(driftDatabase(name: 'my_wallet'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // v2 (E15-T07): chek rasmlari navbati (jadval va indeksi).
      if (from < 2) {
        await migrator.createTable(pendingUploads);
        await migrator.createIndex(pendingUploadsHousehold);
      }
    },
  );

  static const _deviceIdKey = 'device_id';
  static const _ownerKey = 'owner_user_id';

  Future<String?> setting(String key) async => (await (select(
    appSettings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));

  /// Lokal ma'lumot egasini belgilaydi: boshqa foydalanuvchi kirgan bo'lsa,
  /// oldingisining ma'lumoti tozalanadi (bir qurilmada aralashmasin).
  Future<void> claimForUser(String userId) => transaction(() async {
    if (await setting(_ownerKey) == userId) return;
    await clearUserData();
    await setSetting(_ownerKey, userId);
  });

  /// Ilova o'rnatilishining doimiy ID si (`sync_push` `device_id`) —
  /// birinchi chaqiruvda yaratiladi.
  Future<String> deviceId({required String Function() newId}) =>
      transaction(() async {
        final existing = await (select(
          appSettings,
        )..where((s) => s.key.equals(_deviceIdKey))).getSingleOrNull();
        if (existing != null) return existing.value;
        final id = newId();
        await into(appSettings)
            .insert(AppSettingsCompanion.insert(key: _deviceIdKey, value: id));
        return id;
      });

  /// Chiqishda: foydalanuvchi ma'lumoti (sinxron nusxa, navbat, muammolar)
  /// o'chiriladi — keyingi akkaunt ko'rmasin; qurilma sozlamalari qoladi.
  Future<void> clearUserData() => transaction(() async {
    for (final table in allTables) {
      if (table == appSettings) continue;
      await delete(table).go();
    }
    // Qurilma ID sidan boshqa sozlamalar foydalanuvchiga tegishli.
    await (delete(
      appSettings,
    )..where((s) => s.key.equals(_deviceIdKey).not())).go();
  });
}
