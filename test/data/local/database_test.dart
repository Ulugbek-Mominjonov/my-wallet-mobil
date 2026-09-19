import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';

/// `sync_pull` qatori — serverdagi `to_jsonb(transactions)` ko'rinishida.
final Map<String, Object?> serverTransaction = {
  'id': '01990000-0000-7000-8000-000000000001',
  'household_id': '01990000-0000-7000-8000-0000000000aa',
  'kind': 'expense',
  'account_id': '01990000-0000-7000-8000-0000000000b1',
  'to_account_id': null,
  'amount': 15000000,
  'to_amount': null,
  'amount_base': 15000000,
  'fx_rate': null,
  'category_id': '01990000-0000-7000-8000-0000000000c1',
  'payee': 'Korzinka',
  'occurred_on': '2026-09-18',
  'budget_month': '2026-09-01',
  'budget_month_source': 'auto',
  'planned_item_id': null,
  'debt_id': null,
  'note': null,
  'source': 'manual',
  'created_by': '01990000-0000-7000-8000-0000000000ff',
  'created_at': '2026-09-18T07:30:00.123456+00:00',
  'updated_at': '2026-09-18T07:30:00.123456+00:00',
  'deleted_at': null,
  'row_version': 1042,
};

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('server qatori (snake_case JSON) jadvalga va qaytib', () async {
    final row = TransactionRow.fromJson(serverTransaction);
    await db.into(db.transactions).insert(row);
    final stored = await db.select(db.transactions).getSingle();
    expect(stored, row);
    expect(stored.amount, 15000000);
    expect(stored.budgetMonth, '2026-09-01');
    expect(stored.rowVersion, 1042);
    expect(
      stored.createdAt!.toUtc(),
      DateTime.utc(2026, 9, 18, 7, 30, 0, 123, 456),
    );
    expect(stored.toJson()['budget_month_source'], 'auto');
  });

  test("byudjet qatori (qo'shimcha server maydonlari e'tiborsiz)", () async {
    final row = HouseholdRow.fromJson({
      'id': 'h',
      'name': 'Uy',
      'base_currency': 'UZS',
      'timezone': 'Asia/Tashkent',
      'personal_fund_mode': 'percent',
      'personal_fund_percent': 12.5,
      'personal_fund_fixed_amount': 0,
      'personal_fund_day': 5,
      'personal_fund_source_account_id': null,
      'auto_open_month': true,
      'strict_month_lock': false,
      'onboarded_at': null,
      'row_version': 7,
      'purged_version': 0,
      'last_sweep_on': '2026-09-18',
    });
    await db.into(db.households).insert(row);
    final stored = await db.select(db.households).getSingle();
    expect(stored.personalFundPercent, 12.5);
    expect(stored.strictMonthLock, isFalse);
  });

  test('oy — (byudjet, oy) kaliti bilan', () async {
    final month = MonthRow.fromJson({
      'household_id': 'h',
      'month': '2026-09-01',
      'opened_at': '2026-09-01T00:05:00+00:00',
      'closed_at': null,
      'closed_by': null,
      'row_version': 3,
    });
    await db.into(db.months).insertOnConflictUpdate(month);
    await db
        .into(db.months)
        .insertOnConflictUpdate(month.copyWith(rowVersion: 4));
    final rows = await db.select(db.months).get();
    expect(rows.single.rowVersion, 4);
  });

  test('indekslar mavjud', () async {
    final names =
        (await db
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'index'",
                )
                .get())
            .map((row) => row.read<String>('name'))
            .toSet();
    expect(
      names,
      containsAll([
        'transactions_month',
        'transactions_list',
        'transactions_planned',
        'transactions_debt',
        'planned_items_month',
        'planned_items_debt',
        'outbox_pending_record',
        'outbox_order',
      ]),
    );
  });

  test("oy yig'indisi so'rovi indeks bilan (SEARCH, SCAN emas)", () async {
    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN SELECT kind, SUM(amount_base) FROM transactions '
          "WHERE household_id = 'h' AND budget_month = '2026-09-01' "
          'AND deleted_at IS NULL GROUP BY kind',
        )
        .get();
    final detail = plan.map((row) => row.read<String>('detail')).join('\n');
    expect(
      detail,
      contains('SEARCH transactions USING INDEX transactions_month'),
    );
  });

  test(
    'outbox: bir qatorga bitta yuborilmagan mutatsiya (birlashtirish kafolati)',
    () async {
      OutboxCompanion entry(String mutationId, String status) =>
          OutboxCompanion.insert(
            mutationId: mutationId,
            householdId: 'h',
            targetTable: 'transactions',
            recordId: 'r1',
            op: 'upsert',
            status: Value(status),
            createdAt: DateTime.utc(2026, 9, 18),
          );
      await db.into(db.outbox).insert(entry('m1', 'sending'));
      await db.into(db.outbox).insert(entry('m2', 'pending'));
      await expectLater(
        db.into(db.outbox).insert(entry('m3', 'pending')),
        throwsA(isA<SqliteException>()),
      );
    },
  );
}
