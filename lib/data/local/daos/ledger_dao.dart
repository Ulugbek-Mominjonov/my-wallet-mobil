import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:my_wallet/data/local/tables/sync_tables.dart';
import 'package:wallet_domain/wallet_domain.dart';

part 'ledger_dao.g.dart';

/// Ro'yxat kursori (keyset): oxirgi ko'rsatilgan amalning sanasi va ID si.
typedef TransactionCursor = ({String occurredOn, String id});

/// BR-112, BR-113: qarz bo'yicha lokal yig'indilar (domen `DebtProgress`
/// kirishi).
typedef DebtActivity = ({
  Money paidInApp,
  int paymentCount,
  Money pendingAmount,
  int pendingCount,
});

/// BR-202: amallar ro'yxati filtri (bo'sh maydon — cheklov yo'q).
@immutable
final class TransactionFilter {
  const new({
    this.month,
    this.kind,
    this.categoryId,
    this.accountId,
    this.tagId,
    this.search = '',
  });

  /// Tegishli oy (`budget_month`, BR-040) — hisobotlar bilan bir xil.
  final MonthKey? month;
  final TransactionKind? kind;
  final String? categoryId;

  /// Manba yoki manzil hisob (o'tkazma ikkala tomonda ko'rinadi).
  final String? accountId;
  final String? tagId;

  /// Joy nomi yoki izoh ichida; raqam bo'lsa — summa (asosiy birlikda) ham.
  final String search;

  bool get isEmpty =>
      kind == null &&
      categoryId == null &&
      accountId == null &&
      tagId == null &&
      search.trim().isEmpty;

  TransactionFilter copyWith({
    MonthKey? month,
    TransactionKind? kind,
    String? categoryId,
    String? accountId,
    String? tagId,
    String? search,
    bool clearKind = false,
    bool clearCategory = false,
    bool clearAccount = false,
    bool clearTag = false,
  }) => TransactionFilter(
    month: month ?? this.month,
    kind: clearKind ? null : (kind ?? this.kind),
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    accountId: clearAccount ? null : (accountId ?? this.accountId),
    tagId: clearTag ? null : (tagId ?? this.tagId),
    search: search ?? this.search,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.month == month &&
      other.kind == kind &&
      other.categoryId == categoryId &&
      other.accountId == accountId &&
      other.tagId == tagId &&
      other.search == search;

  @override
  int get hashCode =>
      Object.hash(month, kind, categoryId, accountId, tagId, search);
}

/// BR-056: joy nomi — oxirgi ishlatilgan kategoriya va hisob bilan.
typedef PayeeSuggestion = ({
  String payee,
  String? categoryId,
  String accountId,
  String lastUsedOn,
});

/// Hisob-kitob uchun agregat so'rovlar — serverdagi hisobot SQL'i bilan bir
/// xil ma'no (ARXITEKTURA 6: agregat SQLite'da, formulalar `wallet_domain`
/// da). O'chirilganlar (tombstone) hech qayerda qatnashmaydi.
@DriftAccessor(tables: [Transactions, Accounts, PlannedItems, Debts])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  new(super.attachedDatabase);

  /// Ro'yxat sahifasi hajmi.
  static const pageSize = 50;

  /// BR-022, BR-061..063, BR-090 (serverdagi `private.budget_lines`): amal →
  /// byudjet qatori. Byudjet hisoblari orasidagi o'tkazma — qator emas.
  static const _linesSql = '''
    SELECT t.budget_month AS month,
           CASE WHEN t.kind = 'income' THEN 'income'
                WHEN t.kind = 'transfer' THEN 'allocation'
                WHEN a.type = 'personal_fund' THEN 'fund_spent'
                ELSE 'expense' END AS line,
           CASE WHEN t.kind = 'expense' AND a.type = 'personal_fund' THEN NULL
                WHEN (CASE WHEN t.kind = 'transfer' AND a.type = 'personal_fund'
                           THEN ta.type ELSE a.type END) = 'cash' THEN 'cash'
                ELSE 'card' END AS method,
           CASE WHEN t.kind = 'transfer' AND a.type = 'personal_fund'
                THEN -t.amount_base ELSE t.amount_base END AS amount
      FROM transactions t
      JOIN accounts a ON a.id = t.account_id
      LEFT JOIN accounts ta ON ta.id = t.to_account_id
     WHERE t.household_id = ?1 AND t.budget_month BETWEEN ?2 AND ?3
       AND t.deleted_at IS NULL
       AND (t.kind <> 'transfer'
            OR (a.type = 'personal_fund') <> (ta.type = 'personal_fund'))''';

  static const _factsSql =
      '''
    WITH lines AS ($_linesSql)
    SELECT month,
           SUM(CASE WHEN line = 'income' THEN amount ELSE 0 END) AS income,
           SUM(CASE WHEN line = 'income' AND method = 'card' THEN amount ELSE 0 END) AS income_card,
           SUM(CASE WHEN line = 'income' AND method = 'cash' THEN amount ELSE 0 END) AS income_cash,
           SUM(CASE WHEN line IN ('expense', 'allocation') THEN amount ELSE 0 END) AS expense,
           SUM(CASE WHEN line IN ('expense', 'allocation') AND method = 'card' THEN amount ELSE 0 END) AS expense_card,
           SUM(CASE WHEN line IN ('expense', 'allocation') AND method = 'cash' THEN amount ELSE 0 END) AS expense_cash,
           SUM(CASE WHEN line = 'allocation' THEN amount ELSE 0 END) AS allocated,
           SUM(CASE WHEN line = 'fund_spent' THEN amount ELSE 0 END) AS fund_spent
      FROM lines
     GROUP BY month''';

  /// BR-076, BR-090: xarajat va ajratma rejalari (daromad, o'tkazilgan,
  /// o'chirilgan — yo'q).
  static const _plansSql = '''
    SELECT budget_month AS month,
           COALESCE(SUM(COALESCE(planned_amount, 0)), 0) AS planned,
           COALESCE(SUM(CASE WHEN settled_at IS NULL
                             THEN planned_amount - paid_amount END), 0) AS unpaid,
           SUM(CASE WHEN settled_at IS NULL AND planned_amount IS NULL
                    THEN 1 ELSE 0 END) AS unknown_count
      FROM planned_items
     WHERE household_id = ?1 AND budget_month BETWEEN ?2 AND ?3
       AND deleted_at IS NULL AND skipped_at IS NULL AND kind <> 'income'
     GROUP BY budget_month''';

  /// BR-090: [from]..[to] oylari (bo'sh oylar ham — nol bilan), serverdagi
  /// `private.month_facts` bilan bir xil.
  Future<List<MonthFacts>> monthFacts(
    String householdId,
    MonthKey from,
    MonthKey to, {
    Currency base = Currency.uzs,
  }) async {
    final args = [
      Variable.withString(householdId),
      Variable.withString(from.toIsoDate()),
      Variable.withString(to.toIsoDate()),
    ];
    final facts = {
      for (final row in await customSelect(_factsSql, variables: args).get())
        row.read<String>('month'): row,
    };
    final plans = {
      for (final row in await customSelect(_plansSql, variables: args).get())
        row.read<String>('month'): row,
    };
    Money money(QueryRow? row, String column) =>
        Money(row?.read<int>(column) ?? 0, base);
    return [
      for (var month = from; !month.isAfter(to); month = month.shift(1))
        if ((facts[month.toIsoDate()], plans[month.toIsoDate()]) case (
          final fact,
          final plan,
        ))
          MonthFacts(
            month: month,
            income: money(fact, 'income'),
            incomeCard: money(fact, 'income_card'),
            incomeCash: money(fact, 'income_cash'),
            expense: money(fact, 'expense'),
            expenseCard: money(fact, 'expense_card'),
            expenseCash: money(fact, 'expense_cash'),
            allocated: money(fact, 'allocated'),
            fundSpent: money(fact, 'fund_spent'),
            planned: money(plan, 'planned'),
            unpaid: money(plan, 'unpaid'),
            unknownCount: plan?.read<int>('unknown_count') ?? 0,
            hasRecords: fact != null || plan != null,
          ),
    ];
  }

  /// BR-021 (serverdagi `private.account_balance`): boshlang'ich + daromad −
  /// xarajat ± o'tkazmalar, hisob valyutasida. Kalit — hisob ID si.
  Future<Map<String, Money>> accountBalances(String householdId) async {
    final rows = await customSelect(
      '''
      SELECT a.id, a.currency,
             a.opening_balance
             + COALESCE((SELECT SUM(CASE WHEN t.kind = 'income' THEN t.amount ELSE -t.amount END)
                           FROM transactions t
                          WHERE t.account_id = a.id AND t.deleted_at IS NULL), 0)
             + COALESCE((SELECT SUM(t.to_amount)
                           FROM transactions t
                          WHERE t.to_account_id = a.id AND t.deleted_at IS NULL), 0) AS balance
        FROM accounts a
       WHERE a.household_id = ?1 AND a.deleted_at IS NULL''',
      variables: [Variable.withString(householdId)],
      readsFrom: {accounts, transactions},
    ).get();
    return {
      for (final row in rows)
        row.read<String>('id'): Money(
          row.read<int>('balance'),
          currencyOfCode(row.read<String>('currency')),
        ),
    };
  }

  /// BR-112, BR-113 (serverdagi `debt_balances`): bog'langan amallar va
  /// to'lanmagan rejalar. Kalit — qarz ID si; summalar qarz valyutasida.
  Future<Map<String, DebtActivity>> debtActivity(String householdId) async {
    final rows = await customSelect(
      '''
      SELECT d.id, d.currency,
             (SELECT COALESCE(SUM(t.amount), 0) FROM transactions t
               WHERE t.debt_id = d.id AND t.deleted_at IS NULL) AS paid,
             (SELECT COUNT(*) FROM transactions t
               WHERE t.debt_id = d.id AND t.deleted_at IS NULL) AS payments,
             (SELECT COALESCE(SUM(MAX(0, p.planned_amount - p.paid_amount)), 0)
                FROM planned_items p
               WHERE p.debt_id = d.id AND p.deleted_at IS NULL
                 AND p.settled_at IS NULL AND p.skipped_at IS NULL) AS pending,
             (SELECT COUNT(*) FROM planned_items p
               WHERE p.debt_id = d.id AND p.deleted_at IS NULL
                 AND p.settled_at IS NULL AND p.skipped_at IS NULL) AS pending_count
        FROM debts d
       WHERE d.household_id = ?1 AND d.deleted_at IS NULL''',
      variables: [Variable.withString(householdId)],
      readsFrom: {debts, transactions, plannedItems},
    ).get();
    return {
      for (final row in rows)
        row.read<String>('id'): (
          paidInApp: Money(
            row.read<int>('paid'),
            currencyOfCode(row.read<String>('currency')),
          ),
          paymentCount: row.read<int>('payments'),
          pendingAmount: Money(
            row.read<int>('pending'),
            currencyOfCode(row.read<String>('currency')),
          ),
          pendingCount: row.read<int>('pending_count'),
        ),
    };
  }

  /// BR-114: shu oyda qarzga bog'langan amallar (asosiy valyutada).
  Future<Money> debtPaymentsIn(
    String householdId,
    MonthKey month, {
    Currency base = Currency.uzs,
  }) async {
    final amount = transactions.amountBase.sum();
    final query = selectOnly(transactions)
      ..addColumns([amount])
      ..where(
        transactions.householdId.equals(householdId) &
            transactions.budgetMonth.equals(month.toIsoDate()) &
            transactions.debtId.isNotNull() &
            transactions.deletedAt.isNull(),
      );
    return Money((await query.getSingle()).read(amount) ?? 0, base);
  }

  /// BR-118: qarzga bog'langan to'lovlar — yangidan eskiga
  /// (`transactions_debt` indeksi; ro'yxat uchun [limit] ta).
  Stream<List<TransactionRow>> watchDebtPayments(
    String householdId,
    String debtId, {
    int limit = pageSize,
  }) =>
      (select(transactions)
            ..where(
              (t) =>
                  t.householdId.equals(householdId) &
                  t.debtId.equals(debtId) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.occurredOn),
              (t) => OrderingTerm.desc(t.id),
            ])
            ..limit(limit))
          .watch();

  /// Oy rejalari (o'chirilmaganlar) — "To'lovlar" ro'yxati va kalendari.
  /// `planned_items_month` indeksi; reaktiv (to'lov, sinxron).
  Stream<List<PlannedItemRow>> watchMonthPlans(
    String householdId,
    MonthKey month,
  ) =>
      (select(plannedItems)..where(
            (p) =>
                p.householdId.equals(householdId) &
                p.budgetMonth.equals(month.toIsoDate()) &
                p.deletedAt.isNull(),
          ))
          .watch();

  /// Amallar ro'yxati — yangidan eskiga, keyset sahifalash ([after] —
  /// oldingi sahifaning oxirgi qatori). Reaktiv: yozuv bo'lsa qayta chiqadi.
  Stream<List<TransactionRow>> watchTransactionPage(
    String householdId, {
    TransactionCursor? after,
    int limit = pageSize,
    TransactionFilter filter = const TransactionFilter(),
  }) {
    final query = select(transactions)
      ..where((t) {
        var condition =
            t.householdId.equals(householdId) & t.deletedAt.isNull();
        condition &= _filterCondition(t, filter);
        if (after != null) {
          condition &=
              t.occurredOn.isSmallerThanValue(after.occurredOn) |
              (t.occurredOn.equals(after.occurredOn) &
                  t.id.isSmallerThanValue(after.id));
        }
        return condition;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredOn),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(limit);
    return query.watch();
  }

  /// Filtr sharti; oy — `transactions_month` indeksi, teg — `EXISTS`.
  Expression<bool> _filterCondition(
    $TransactionsTable t,
    TransactionFilter filter,
  ) {
    Expression<bool> condition = const Constant(true);
    if (filter.month case final month?) {
      condition &= t.budgetMonth.equals(month.toIsoDate());
    }
    if (filter.kind case final kind?) {
      condition &= t.kind.equals(kind.wire);
    }
    if (filter.categoryId case final id?) {
      condition &= t.categoryId.equals(id);
    }
    if (filter.accountId case final id?) {
      condition &= t.accountId.equals(id) | t.toAccountId.equals(id);
    }
    if (filter.tagId case final id?) {
      final links = attachedDatabase.transactionTags;
      condition &= existsQuery(
        select(links)..where(
          (l) =>
              l.transactionId.equalsExp(t.id) &
              l.tagId.equals(id) &
              l.deletedAt.isNull(),
        ),
      );
    }
    final search = filter.search.trim();
    if (search.isNotEmpty) {
      final pattern = '%${_escapeLike(search.toLowerCase())}%';
      var match =
          t.payee.lower().like(pattern, escapeChar: r'\') |
          t.note.lower().like(pattern, escapeChar: r'\');
      // Raqam — summa (asosiy birlikda, masalan "45000").
      final major = int.tryParse(search.replaceAll(RegExp(r'[\s,.]'), ''));
      if (major != null) {
        match |= t.amount.equals(major * 100);
      }
      condition &= match;
    }
    return condition;
  }

  /// BR-056: joy nomi avto-to'ldirish — [prefix] bilan boshlanadigan,
  /// oxirgi ishlatilganlar birinchi; har nom uchun oxirgi kategoriya/hisob
  /// (SQLite: yagona MAX() agregatida oddiy ustunlar shu qatordan olinadi).
  Future<List<PayeeSuggestion>> recentPayees(
    String householdId, {
    String prefix = '',
    int limit = 10,
  }) async {
    final rows = await customSelect(
      r'''
      SELECT payee, category_id, account_id, MAX(occurred_on || id) AS last_key,
             occurred_on
        FROM transactions
       WHERE household_id = ?1 AND deleted_at IS NULL AND payee IS NOT NULL
         AND payee LIKE ?2 ESCAPE '\'
       GROUP BY payee
       ORDER BY last_key DESC
       LIMIT ?3''',
      variables: [
        Variable.withString(householdId),
        Variable.withString('${_escapeLike(prefix)}%'),
        Variable.withInt(limit),
      ],
      readsFrom: {transactions},
    ).get();
    return [
      for (final row in rows)
        (
          payee: row.read<String>('payee'),
          categoryId: row.readNullable<String>('category_id'),
          accountId: row.read<String>('account_id'),
          lastUsedOn: row.read<String>('occurred_on'),
        ),
    ];
  }
}

String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
