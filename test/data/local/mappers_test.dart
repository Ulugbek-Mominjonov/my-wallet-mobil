import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Entity → lokal qator → entity: hech narsa yo'qolmaydi (T04 repository'lari
/// shunga tayanadi).
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final at = DateTime.utc(2026, 9, 18, 7, 30);

  Future<R> roundTrip<T extends Table, R>(
    TableInfo<T, R> table,
    Insertable<R> row,
  ) async {
    await db.into(table).insert(row);
    return await db.select(table).getSingle();
  }

  test('byudjet: fond foizi bazis punktda (12.5% → 1250)', () async {
    const household = Household(
      id: 'h',
      name: 'Uy',
      personalFund: PersonalFundRule(
        mode: PersonalFundMode.fixed,
        percentBasisPoints: 1250,
        fixedAmount: Money(50000000),
        day: 10,
        sourceAccountId: 'cash',
      ),
      strictMonthLock: true,
      rowVersion: 7,
    );
    final row = await roundTrip(db.households, household.toRow());
    expect(row.personalFundPercent, 12.5);
    expect(row.toDomain(), household);
  });

  test('hisob va kategoriya', () async {
    final account = Account(
      id: 'a',
      householdId: 'h',
      name: 'Dollar',
      type: AccountType.card,
      openingBalance: const Money(12345, Currency.usd),
      openingDate: LocalDate(2026, 9, 1),
      icon: 'bank',
      color: '#4F46E5',
      sortOrder: 2,
      archivedAt: at,
      rowVersion: 3,
    );
    expect(
      (await roundTrip(db.accounts, account.toCompanion())).toDomain(),
      account,
    );

    final category = Category(
      id: 'c',
      householdId: 'h',
      kind: CategoryKind.income,
      name: 'Oylik',
      monthShift: -1,
      parentId: 'p',
      systemCode: SystemCode.personalAllocation,
      deletedAt: at,
    );
    expect(
      (await roundTrip(db.categories, category.toCompanion())).toDomain(),
      category,
    );
  });

  test(
    "reja va amal (asosiy valyuta, noma'lum summa, qo'lda oy, kurs)",
    () async {
      final plan = PlannedItem(
        id: 'p',
        householdId: 'h',
        kind: PlanKind.allocation,
        name: "O'zim uchun",
        dueDate: LocalDate(2026, 9, 5),
        budgetMonth: MonthKey(2026, 9),
        accountId: 'cash',
        paidAmount: const Money(1000),
        autoPay: true,
        debtId: 'd',
        recurringRuleId: 'r',
        systemCode: SystemCode.personalAllocation,
        note: 'izoh',
        settledAt: at,
        closedAt: at,
        skippedAt: at,
      );
      expect(
        (await roundTrip(
          db.plannedItems,
          plan.toCompanion(),
        )).toDomain(Currency.uzs),
        plan,
      );

      final tx = Transaction(
        id: 't',
        householdId: 'h',
        kind: TransactionKind.transfer,
        accountId: 'usd',
        toAccountId: 'card',
        amount: const Money(10000, Currency.usd),
        amountBase: const Money(126505500),
        toAmount: const Money(126505500),
        fxRate: '12650.55',
        occurredOn: LocalDate(2026, 9, 18),
        budgetMonth: MonthKey(2026, 8),
        budgetMonthSource: BudgetMonthSource.manual,
        source: TransactionSource.telegram,
        createdBy: 'u',
        rowVersion: 1042,
      );
      final row = await roundTrip(db.transactions, tx.toCompanion());
      expect(row.budgetMonth, '2026-08-01');
      expect(
        row.toDomain(
          accountCurrency: Currency.usd,
          base: Currency.uzs,
          toCurrency: Currency.uzs,
        ),
        tx,
      );
    },
  );

  test('qarz, maqsad, limit, tez tugma, teg, doimiy reja', () async {
    final debt = Debt(
      id: 'd',
      householdId: 'h',
      name: 'Mashina',
      direction: DebtDirection.owedToMe,
      total: const Money(100, Currency.usd),
      paidBefore: const Money(10, Currency.usd),
      monthlyPayment: const Money(5, Currency.usd),
      dueDate: LocalDate(2027, 1, 1),
      note: 'n',
      archivedAt: at,
    );
    expect((await roundTrip(db.debts, debt.toCompanion())).toDomain(), debt);

    final goal = Goal(
      id: 'g',
      householdId: 'h',
      name: "Ta'til",
      target: const Money(5000000),
      savedManual: const Money(100),
      monthlyContribution: const Money(10),
      deadline: MonthKey(2027, 6),
      accountId: 'a',
      sortOrder: 1,
      achievedAt: at,
    );
    expect((await roundTrip(db.goals, goal.toCompanion())).toDomain(), goal);

    const limit = CategoryLimit(
      id: 'l',
      householdId: 'h',
      categoryId: 'c',
      amount: Money(1000000),
      alert80: false,
    );
    expect(
      (await roundTrip(
        db.categoryLimits,
        limit.toCompanion(),
      )).toDomain(Currency.uzs),
      limit,
    );

    const action = QuickAction(
      id: 'q',
      householdId: 'h',
      name: 'Taksi',
      amount: Money(2000000),
      categoryId: 'c',
      accountId: 'cash',
      payee: 'Yandex',
      sortOrder: 3,
    );
    expect(
      (await roundTrip(
        db.quickActions,
        action.toCompanion(),
      )).toDomain(Currency.uzs),
      action,
    );

    const tag = Tag(id: 't', householdId: 'h', name: 'safar', color: '#FF0000');
    expect((await roundTrip(db.tags, tag.toCompanion())).toDomain(), tag);

    final rule = RecurringRule(
      id: 'r',
      householdId: 'h',
      kind: PlanKind.expense,
      name: 'Ijara',
      dayOfMonth: 31,
      categoryId: 'c',
      accountId: 'card',
      amount: const Money(300000000),
      autoPay: true,
      active: false,
      debtId: 'd',
      startMonth: MonthKey(2026, 1),
      endMonth: MonthKey(2026, 12),
      sortOrder: 4,
    );
    expect(
      (await roundTrip(
        db.recurringRules,
        rule.toCompanion(),
      )).toDomain(Currency.uzs),
      rule,
    );
  });

  test("valyuta kodi: ma'lumlari — o'z sozlamasi bilan", () {
    expect(currencyOfCode('UZS').allocationUnit, 100000);
    expect(currencyOfCode('EUR'), Currency.eur);
    expect(currencyOfCode('RUB'), Currency.rub);
    expect(currencyOfCode('GBP'), const Currency('GBP'));
    expect(currencyOf('USD'), Currency.usd);
  });
}
