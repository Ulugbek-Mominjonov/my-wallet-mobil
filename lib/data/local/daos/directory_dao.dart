import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/local/tables/sync_tables.dart';
import 'package:wallet_domain/wallet_domain.dart';

part 'directory_dao.g.dart';

/// Spravochnik ro'yxatlari (hisoblar, kategoriyalar) — ekranlar uchun
/// jonli oqim. O'chirilganlar (tombstone) chiqmaydi; tartib — serverdagi
/// `sort_order`, keyin nom.
@DriftAccessor(tables: [Accounts, Categories, Transactions, Tags, Debts])
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

  /// BR-140: oxirgi ishlatilgan kategoriyalar (to'rda oldinda turadi).
  Future<List<String>> recentCategoryIds(
    String householdId, {
    required CategoryKind kind,
    int limit = 8,
  }) async {
    final rows = await customSelect(
      '''
      SELECT t.category_id AS id, MAX(t.occurred_on || t.id) AS last_key
        FROM transactions t
        JOIN categories c ON c.id = t.category_id
       WHERE t.household_id = ?1 AND t.deleted_at IS NULL
         AND t.category_id IS NOT NULL AND c.kind = ?2
       GROUP BY t.category_id
       ORDER BY last_key DESC
       LIMIT ?3''',
      variables: [
        Variable.withString(householdId),
        Variable.withString(kind.wire),
        Variable.withInt(limit),
      ],
      readsFrom: {transactions, categories},
    ).get();
    return [for (final row in rows) row.read<String>('id')];
  }

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

  Stream<List<Tag>> watchTags(String householdId) =>
      (select(tags)
            ..where(
              (t) => t.householdId.equals(householdId) & t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .map((row) => row.toDomain())
          .watch();

  /// Faol qarzlar (arxivlanmagan) — amalni qarzga bog'lash uchun.
  Stream<List<Debt>> watchDebts(String householdId) =>
      (select(debts)
            ..where(
              (d) =>
                  d.householdId.equals(householdId) &
                  d.deletedAt.isNull() &
                  d.archivedAt.isNull(),
            )
            ..orderBy([(d) => OrderingTerm.asc(d.name)]))
          .map((row) => row.toDomain())
          .watch();
}
