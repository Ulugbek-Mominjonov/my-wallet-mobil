import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  group('enum wire qiymatlari (contracts/api.md)', () {
    test('har enum — server qiymatiga va qaytib', () {
      final all = <List<Enum>, String Function(Enum)>{
        MemberRole.values: (v) => (v as MemberRole).wire,
        AccountType.values: (v) => (v as AccountType).wire,
        CategoryKind.values: (v) => (v as CategoryKind).wire,
        PlanKind.values: (v) => (v as PlanKind).wire,
        TransactionKind.values: (v) => (v as TransactionKind).wire,
        BudgetMonthSource.values: (v) => (v as BudgetMonthSource).wire,
        TransactionSource.values: (v) => (v as TransactionSource).wire,
        DebtDirection.values: (v) => (v as DebtDirection).wire,
        PersonalFundMode.values: (v) => (v as PersonalFundMode).wire,
        SystemCode.values: (v) => (v as SystemCode).wire,
      };
      final parsers = <List<Enum>, Enum Function(String)>{
        MemberRole.values: MemberRole.fromWire,
        AccountType.values: AccountType.fromWire,
        CategoryKind.values: CategoryKind.fromWire,
        PlanKind.values: PlanKind.fromWire,
        TransactionKind.values: TransactionKind.fromWire,
        BudgetMonthSource.values: BudgetMonthSource.fromWire,
        TransactionSource.values: TransactionSource.fromWire,
        DebtDirection.values: DebtDirection.fromWire,
        PersonalFundMode.values: PersonalFundMode.fromWire,
        SystemCode.values: SystemCode.fromWire,
      };
      for (final MapEntry(key: values, value: wireOf) in all.entries) {
        for (final value in values) {
          expect(parsers[values]!(wireOf(value)), value);
        }
      }
    });

    test('snake_case qiymatlar', () {
      expect(AccountType.personalFund.wire, 'personal_fund');
      expect(DebtDirection.owedToMe.wire, 'owed_to_me');
      expect(TransactionSource.quickAction.wire, 'quick_action');
      expect(
        SystemCode.fromWire('personal_allocation'),
        SystemCode.personalAllocation,
      );
    });

    test("noma'lum qiymat — FormatException", () {
      expect(() => AccountType.fromWire('crypto'), throwsFormatException);
    });

    test('rol huquqlari (BR-011)', () {
      expect(MemberRole.viewer.canWrite, isFalse);
      expect(MemberRole.member.canWrite, isTrue);
      expect(MemberRole.member.canManage, isFalse);
      expect(MemberRole.admin.canManage, isTrue);
      expect(MemberRole.owner.canManage, isTrue);
      expect(AccountType.cash.isCash, isTrue);
      expect(AccountType.ewallet.isCash, isFalse);
    });
  });

  group('entity yordamchilari', () {
    test('Account: valyuta, fond, faollik', () {
      const account = Account(
        id: 'a',
        householdId: 'h',
        name: 'Dollar',
        type: AccountType.card,
        openingBalance: Money(0, Currency.usd),
      );
      expect(account.currency, Currency.usd);
      expect(account.isPersonalFund, isFalse);
      expect(account.isActive, isTrue);
      expect(
        account.copyWith(archivedAt: DateTime.utc(2026)).isActive,
        isFalse,
      );
      expect(
        account.copyWith(type: AccountType.personalFund).isPersonalFund,
        isTrue,
      );
    });

    test('Category: tizim va faollik', () {
      const category = Category(
        id: 'c',
        householdId: 'h',
        kind: CategoryKind.expense,
        name: "O'zim uchun",
        systemCode: SystemCode.personalAllocation,
      );
      expect(category.isSystem, isTrue);
      expect(category.isActive, isTrue);
      expect(
        category.copyWith(deletedAt: DateTime.utc(2026)).isActive,
        isFalse,
      );
      expect(category.copyWith(systemCode: null).isSystem, isFalse);
    });

    test('RecurringRule: amal qilish davri', () {
      final rule = RecurringRule(
        id: 'r',
        householdId: 'h',
        kind: PlanKind.expense,
        name: 'Kurs',
        dayOfMonth: 20,
        startMonth: MonthKey(2026, 9),
        endMonth: MonthKey(2026, 12),
      );
      expect(rule.appliesTo(MonthKey(2026, 8)), isFalse);
      expect(rule.appliesTo(MonthKey(2026, 9)), isTrue);
      expect(rule.appliesTo(MonthKey(2026, 12)), isTrue);
      expect(rule.appliesTo(MonthKey(2027, 1)), isFalse);
      expect(
        rule.copyWith(active: false).appliesTo(MonthKey(2026, 10)),
        isFalse,
      );
      expect(
        rule
            .copyWith(deletedAt: DateTime.utc(2026))
            .appliesTo(MonthKey(2026, 10)),
        isFalse,
      );
      expect(
        rule
            .copyWith(startMonth: null, endMonth: null)
            .appliesTo(MonthKey(2020, 1)),
        isTrue,
      );
    });

    test('PlannedItem: qolgan summa va fond rejasi', () {
      final plan = PlannedItem(
        id: 'p',
        householdId: 'h',
        kind: PlanKind.expense,
        name: 'Gaz',
        dueDate: LocalDate(2026, 11, 3),
        budgetMonth: MonthKey(2026, 11),
        plannedAmount: const Money(10000000),
        paidAmount: const Money(4000000),
      );
      expect(plan.remaining, const Money(6000000));
      expect(
        plan.copyWith(paidAmount: const Money(12000000)).remaining,
        Money.zero,
      );
      expect(plan.copyWith(plannedAmount: null).remaining, isNull);
      expect(plan.isFundAllocation, isFalse);
      expect(
        plan
            .copyWith(systemCode: SystemCode.personalAllocation)
            .isFundAllocation,
        isTrue,
      );
    });

    test('Transaction: qiymat bo‘yicha tenglik va o‘chirilgan', () {
      final tx = Transaction(
        id: 't',
        householdId: 'h',
        kind: TransactionKind.expense,
        accountId: 'a',
        amount: const Money(1000),
        amountBase: const Money(1000),
        occurredOn: LocalDate(2026, 9, 18),
        budgetMonth: MonthKey(2026, 9),
      );
      expect(tx, tx.copyWith());
      expect(tx.isDeleted, isFalse);
      expect(tx.copyWith(deletedAt: DateTime.utc(2026)).isDeleted, isTrue);
      expect(tx.budgetMonthSource, BudgetMonthSource.auto);
      expect(tx.source, TransactionSource.manual);
    });

    test('standart qiymatlar (server bilan bir xil)', () {
      const household = Household(
        id: 'h',
        name: 'Uy',
        personalFund: PersonalFundRule(),
      );
      expect(household.baseCurrency, Currency.uzs);
      expect(household.timezone, 'Asia/Tashkent');
      expect(household.personalFund.percentBasisPoints, 1000);
      expect(household.personalFund.day, 5);
      expect(household.autoOpenMonth, isTrue);
      const limit = CategoryLimit(
        id: 'l',
        householdId: 'h',
        categoryId: 'c',
        amount: Money(1),
      );
      expect(limit.alert80 && limit.alert100, isTrue);
      const member = Member(
        householdId: 'h',
        userId: 'u',
        role: MemberRole.member,
      );
      expect(member.role.canWrite, isTrue);
    });
  });

  group('Failure', () {
    test('ValidationFailure — qiymat bo‘yicha', () {
      expect(
        const ValidationFailure('amount', 'amount_required'),
        const ValidationFailure('amount', 'amount_required'),
      );
      expect(
        const ValidationFailure('amount', 'x').hashCode,
        const ValidationFailure('amount', 'x').hashCode,
      );
      expect(
        const ValidationFailure('name', 'invalid_name').toString(),
        'ValidationFailure(name: invalid_name)',
      );
    });

    test('sealed — barcha holatlar ko‘rib chiqiladi', () {
      String describe(Failure failure) => switch (failure) {
        ValidationFailure(:final code) => code,
        ConflictFailure(:final recordId) => 'conflict:$recordId',
        MonthClosedWarning(:final month, :final blocking) =>
          'closed:$month:$blocking',
      };
      expect(describe(const ConflictFailure('t1')), 'conflict:t1');
      expect(
        describe(MonthClosedWarning(MonthKey(2026, 9), blocking: true)),
        'closed:2026-09:true',
      );
      expect(const ConflictFailure('t1').toString(), 'ConflictFailure(t1)');
      expect(
        MonthClosedWarning(MonthKey(2026, 9), blocking: false).toString(),
        'MonthClosedWarning(2026-09, blocking: false)',
      );
    });
  });
}
