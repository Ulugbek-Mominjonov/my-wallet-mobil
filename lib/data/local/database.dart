import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  new(super.e);

  /// Ilova bazasi (qurilma xotirasida, WAL rejimida).
  factory open() => AppDatabase(driftDatabase(name: 'my_wallet'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (migrator) => migrator.createAll());
}
