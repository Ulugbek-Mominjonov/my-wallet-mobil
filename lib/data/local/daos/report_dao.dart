import 'package:drift/drift.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/local/tables/sync_tables.dart';
import 'package:wallet_domain/wallet_domain.dart';

part 'report_dao.g.dart';

/// Kategoriya bo'yicha oy (serverdagi `report_month.by_category`): reja va
/// fakt (BR-090 qatorlari; ajratma — "O'zim uchun" kategoriyasida).
typedef CategoryLine = ({
  String categoryId,
  String name,
  String? parentId,
  Money planned,

  /// Kategoriyaning o'zi.
  Money actual,

  /// Subkategoriyalari bilan — limit shu bo'yicha (BR-131).
  Money actualTotal,
  Money? limit,
});

/// Daromad turi bo'yicha oy (`report_month.by_type`, BR-022 karta/naqd).
typedef IncomeTypeLine = ({
  String categoryId,
  String name,
  Money card,
  Money cash,
});

/// Oy holati: ochilgan (rejalar yaratilgan) va yopilgan (BR-150).
typedef MonthState = ({bool opened, bool closed});

/// Dashboard va hisobotlar uchun agregatlar — serverdagi `report_month` bilan
/// bir xil ma'no (asosiy valyutada, `amount_base`). Oy filtri —
/// `transactions_month` / `planned_items_month` indekslari.
@DriftAccessor(
  tables: [
    Transactions,
    Accounts,
    Categories,
    PlannedItems,
    CategoryLimits,
    Months,
  ],
)
class ReportDao extends DatabaseAccessor<AppDatabase> with _$ReportDaoMixin {
  new(super.attachedDatabase);

  /// Birinchi yozuv oyi (amal yoki reja) — prognoz va jamg'arma tarixi uchun.
  Future<MonthKey?> firstRecordMonth(String householdId) async {
    final row = await customSelect(
      '''
      SELECT MIN(month) AS month FROM (
        SELECT MIN(budget_month) AS month FROM transactions
         WHERE household_id = ?1 AND deleted_at IS NULL
        UNION ALL
        SELECT MIN(budget_month) FROM planned_items
         WHERE household_id = ?1 AND deleted_at IS NULL AND skipped_at IS NULL
      )''',
      variables: [Variable.withString(householdId)],
      readsFrom: {transactions, plannedItems},
    ).getSingle();
    final month = row.read<String?>('month');
    return month == null ? null : MonthKey.parse(month);
  }

  /// BR-090, BR-131 (serverdagi `report_month.by_category`): xarajat va
  /// ajratma kategoriya bo'yicha, rejalar va limitlar bilan. Qator — rejasi,
  /// fakti (subkategoriyalar bilan) yoki limiti bor kategoriyalar.
  Future<List<CategoryLine>> byCategory(
    String householdId,
    MonthKey month, {
    Currency base = Currency.uzs,
  }) async {
    final args = [
      Variable.withString(householdId),
      Variable.withString(month.toIsoDate()),
    ];
    Future<Map<String, int>> sums(String sql) async => {
      for (final row in await customSelect(
        sql,
        variables: args,
        readsFrom: {transactions, accounts, categories, plannedItems},
      ).get())
        ?row.read<String?>('category_id'): row.read<int>('amount'),
    };

    final actual = await sums(_actualByCategorySql);
    final planned = await sums(_plannedByCategorySql);
    final expense =
        await (select(categories)
              ..where(
                (c) =>
                    c.householdId.equals(householdId) &
                    c.kind.equals(CategoryKind.expense.wire) &
                    c.deletedAt.isNull(),
              )
              ..orderBy([
                (c) => OrderingTerm.asc(c.sortOrder),
                (c) => OrderingTerm.asc(c.name),
              ]))
            .get();
    final limits = {
      for (final l
          in await (select(categoryLimits)..where(
                (l) => l.householdId.equals(householdId) & l.deletedAt.isNull(),
              ))
              .get())
        l.categoryId: l.amount,
    };
    final children = <String, List<String>>{};
    for (final category in expense) {
      if (category.parentId case final parent?) {
        (children[parent] ??= []).add(category.id);
      }
    }

    final lines = <CategoryLine>[];
    for (final category in expense) {
      final own = actual[category.id] ?? 0;
      var total = own;
      for (final child in children[category.id] ?? const <String>[]) {
        total += actual[child] ?? 0;
      }
      final plan = planned[category.id] ?? 0;
      final limit = limits[category.id];
      if (plan == 0 && total == 0 && limit == null) continue;
      lines.add((
        categoryId: category.id,
        name: category.name,
        parentId: category.parentId,
        planned: Money(plan, base),
        actual: Money(own, base),
        actualTotal: Money(total, base),
        limit: limit == null ? null : Money(limit, base),
      ));
    }
    return lines;
  }

  /// Xarajat (fond hisobidan emas) va ajratma — "O'zim uchun"da.
  static const _actualByCategorySql = '''
    SELECT CASE WHEN t.kind = 'transfer'
                THEN (SELECT id FROM categories
                       WHERE household_id = ?1
                         AND system_code = 'personal_allocation')
                ELSE t.category_id END AS category_id,
           SUM(CASE WHEN t.kind = 'transfer' AND a.type = 'personal_fund'
                    THEN -t.amount_base ELSE t.amount_base END) AS amount
      FROM transactions t
      JOIN accounts a ON a.id = t.account_id
      LEFT JOIN accounts ta ON ta.id = t.to_account_id
     WHERE t.household_id = ?1 AND t.budget_month = ?2
       AND t.deleted_at IS NULL
       AND ((t.kind = 'expense' AND a.type <> 'personal_fund')
            OR (t.kind = 'transfer'
                AND (a.type = 'personal_fund') <> (ta.type = 'personal_fund')))
     GROUP BY 1''';

  /// Xarajat va ajratma rejalari (noma'lum summa — 0).
  static const _plannedByCategorySql = '''
    SELECT COALESCE(p.category_id,
                    CASE WHEN p.kind = 'allocation'
                         THEN (SELECT id FROM categories
                                WHERE household_id = ?1
                                  AND system_code = 'personal_allocation')
                    END) AS category_id,
           SUM(COALESCE(p.planned_amount, 0)) AS amount
      FROM planned_items p
     WHERE p.household_id = ?1 AND p.budget_month = ?2
       AND p.deleted_at IS NULL AND p.skipped_at IS NULL
       AND p.kind <> 'income'
     GROUP BY 1''';

  /// BR-022: daromad turlari — karta/naqd (hisob turi bo'yicha).
  Future<List<IncomeTypeLine>> byIncomeType(
    String householdId,
    MonthKey month, {
    Currency base = Currency.uzs,
  }) async {
    final rows = await customSelect(
      '''
      SELECT c.id, c.name,
             SUM(CASE WHEN a.type = 'cash' THEN 0 ELSE t.amount_base END) AS card,
             SUM(CASE WHEN a.type = 'cash' THEN t.amount_base ELSE 0 END) AS cash
        FROM transactions t
        JOIN accounts a ON a.id = t.account_id
        JOIN categories c ON c.id = t.category_id
       WHERE t.household_id = ?1 AND t.budget_month = ?2
         AND t.deleted_at IS NULL AND t.kind = 'income'
       GROUP BY c.id
       ORDER BY c.sort_order, c.name''',
      variables: [
        Variable.withString(householdId),
        Variable.withString(month.toIsoDate()),
      ],
      readsFrom: {transactions, accounts, categories},
    ).get();
    return [
      for (final row in rows)
        (
          categoryId: row.read<String>('id'),
          name: row.read<String>('name'),
          card: Money(row.read<int>('card'), base),
          cash: Money(row.read<int>('cash'), base),
        ),
    ];
  }

  /// To'lanmagan rejalar (o'tkazilmagan, o'chirilmagan) — muddati bo'yicha.
  Future<List<PlannedItem>> openPlans(
    String householdId,
    MonthKey month, {
    Currency base = Currency.uzs,
  }) async {
    final rows =
        await (select(plannedItems)
              ..where(
                (p) =>
                    p.householdId.equals(householdId) &
                    p.budgetMonth.equals(month.toIsoDate()) &
                    p.deletedAt.isNull() &
                    p.skippedAt.isNull() &
                    p.settledAt.isNull(),
              )
              ..orderBy([
                (p) => OrderingTerm.asc(p.dueDate),
                (p) => OrderingTerm.asc(p.name),
              ]))
            .get();
    return [for (final row in rows) row.toDomain(base)];
  }

  /// BR-093: shu oyning daromad rejalari soni va to'lanmagan qoldig'i.
  Future<({int count, Money pending})> incomePlans(
    String householdId,
    MonthKey month, {
    Currency base = Currency.uzs,
  }) async {
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS count,
             COALESCE(SUM(CASE WHEN settled_at IS NULL
                               THEN COALESCE(planned_amount, 0) - paid_amount
                               ELSE 0 END), 0) AS pending
        FROM planned_items
       WHERE household_id = ?1 AND budget_month = ?2 AND kind = 'income'
         AND deleted_at IS NULL AND skipped_at IS NULL''',
      variables: [
        Variable.withString(householdId),
        Variable.withString(month.toIsoDate()),
      ],
      readsFrom: {plannedItems},
    ).getSingle();
    return (
      count: row.read<int>('count'),
      pending: Money(row.read<int>('pending'), base),
    );
  }

  Future<MonthState> monthState(String householdId, MonthKey month) async {
    final row =
        await (select(months)..where(
              (m) =>
                  m.householdId.equals(householdId) &
                  m.month.equals(month.toIsoDate()),
            ))
            .getSingleOrNull();
    return (opened: row?.openedAt != null, closed: row?.closedAt != null);
  }
}
