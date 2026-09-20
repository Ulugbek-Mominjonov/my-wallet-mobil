import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/local/tables/sync_tables.dart';
import 'package:wallet_domain/wallet_domain.dart';

part 'directory_dao.g.dart';

/// Spravochnik ro'yxatlari (hisoblar, kategoriyalar) — ekranlar uchun
/// jonli oqim. O'chirilganlar (tombstone) chiqmaydi; tartib — serverdagi
/// `sort_order`, keyin nom.
@DriftAccessor(tables: [Accounts, Categories])
class DirectoryDao extends DatabaseAccessor<AppDatabase>
    with _$DirectoryDaoMixin {
  new(super.attachedDatabase);

  Stream<List<Account>> watchAccounts(String householdId) =>
      (select(accounts)
            ..where(
              (a) => a.householdId.equals(householdId) & a.deletedAt.isNull(),
            )
            ..orderBy([
              (a) => OrderingTerm.asc(a.sortOrder),
              (a) => OrderingTerm.asc(a.name),
            ]))
          .map((row) => row.toDomain())
          .watch();

  Stream<List<Category>> watchCategories(
    String householdId, {
    required CategoryKind kind,
  }) =>
      (select(categories)
            ..where(
              (c) =>
                  c.householdId.equals(householdId) &
                  c.kind.equals(kind.wire) &
                  c.deletedAt.isNull(),
            )
            ..orderBy([
              (c) => OrderingTerm.asc(c.sortOrder),
              (c) => OrderingTerm.asc(c.name),
            ]))
          .map((row) => row.toDomain())
          .watch();
}
