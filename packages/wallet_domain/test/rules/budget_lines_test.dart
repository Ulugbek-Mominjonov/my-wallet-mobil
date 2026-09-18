import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

Transaction _tx(
  TransactionKind kind,
  int amount, {
  String? toAccountId,
  String? categoryId,
  DateTime? deletedAt,
}) => Transaction(
  id: 't',
  householdId: 'h',
  kind: kind,
  accountId: 'a',
  toAccountId: toAccountId,
  amount: Money(amount),
  amountBase: Money(amount),
  categoryId: categoryId,
  occurredOn: LocalDate(2026, 8, 8),
  budgetMonth: MonthKey(2026, 8),
  deletedAt: deletedAt,
);

BudgetLine? _line(Transaction tx, AccountType from, [AccountType? to]) =>
    BudgetLine.of(
      tx,
      accountType: from,
      toAccountType: to,
      allocationCategoryId: 'self',
    );

void main() {
  group('BR-022, BR-061..063: amalning byudjet qatori', () {
    test('BR-022: naqd — cash, qolgan hisoblar — card', () {
      final cash = _line(
        _tx(TransactionKind.income, 5, categoryId: 'c'),
        AccountType.cash,
      )!;
      final ewallet = _line(
        _tx(TransactionKind.expense, 5, categoryId: 'c'),
        AccountType.ewallet,
      )!;
      expect(cash.method, PaymentMethod.cash);
      expect(cash.kind, BudgetLineKind.income);
      expect(ewallet.method, PaymentMethod.card);
      expect(ewallet.isSpending, isTrue);
    });

    test("BR-061: fondga o'tkazma — ajratma (+), qaytish — manfiy", () {
      final toFund = _line(
        _tx(TransactionKind.transfer, 100, toAccountId: 'f'),
        AccountType.cash,
        AccountType.personalFund,
      )!;
      expect(toFund.kind, BudgetLineKind.allocation);
      expect(toFund.amount, const Money(100));
      expect(toFund.method, PaymentMethod.cash);
      expect(toFund.categoryId, 'self');

      final back = _line(
        _tx(TransactionKind.transfer, 40, toAccountId: 'k'),
        AccountType.personalFund,
        AccountType.card,
      )!;
      expect(back.amount, const Money(-40));
      expect(back.method, PaymentMethod.card);
    });

    test("BR-062: fonddan xarajat — byudjetga ta'sir qilmaydi", () {
      final line = _line(
        _tx(TransactionKind.expense, 45, categoryId: 'self'),
        AccountType.personalFund,
      )!;
      expect(line.kind, BudgetLineKind.fundSpent);
      expect(line.method, isNull);
      expect(line.isSpending, isFalse);
    });

    test(
      "BR-023: byudjet hisoblari orasidagi o'tkazma, o'chirilgan — yo'q",
      () {
        expect(
          _line(
            _tx(TransactionKind.transfer, 100, toAccountId: 'd'),
            AccountType.card,
            AccountType.deposit,
          ),
          isNull,
        );
        expect(
          _line(
            _tx(TransactionKind.expense, 1, deletedAt: DateTime.utc(2026)),
            AccountType.card,
          ),
          isNull,
        );
      },
    );
  });

  test(
    "BR-090: oy yig'indilari — rejalar bilan (o'tkazilgan, daromad — yo'q)",
    () {
      final lines = [
        _line(
          _tx(TransactionKind.income, 1000, categoryId: 'c'),
          AccountType.card,
        )!,
        _line(
          _tx(TransactionKind.expense, 300, categoryId: 'c'),
          AccountType.cash,
        )!,
        _line(
          _tx(TransactionKind.transfer, 100, toAccountId: 'f'),
          AccountType.cash,
          AccountType.personalFund,
        )!,
        _line(_tx(TransactionKind.expense, 45), AccountType.personalFund)!,
      ];
      PlannedItem plan(
        String name, {
        int? planned,
        int paid = 0,
        PlanKind kind = PlanKind.expense,
        DateTime? settledAt,
        DateTime? skippedAt,
      }) => PlannedItem(
        id: name,
        householdId: 'h',
        kind: kind,
        name: name,
        dueDate: LocalDate(2026, 8, 10),
        budgetMonth: MonthKey(2026, 8),
        plannedAmount: planned == null ? null : Money(planned),
        paidAmount: Money(paid),
        settledAt: settledAt,
        skippedAt: skippedAt,
      );
      final facts = monthFactsOf(MonthKey(2026, 8), lines, [
        plan('Ijara', planned: 500, paid: 200),
        plan('Suv'),
        plan('Gaz', planned: 100, paid: 100, settledAt: DateTime.utc(2026)),
        plan('Oylik', planned: 9999, kind: PlanKind.income),
        plan('Kurs', planned: 777, skippedAt: DateTime.utc(2026)),
      ]);
      expect(facts.income, const Money(1000));
      expect(facts.incomeCard, const Money(1000));
      expect(facts.expense, const Money(400));
      expect(facts.expenseCash, const Money(400));
      expect(facts.allocated, const Money(100));
      expect(facts.fundSpent, const Money(45));
      expect(facts.planned, const Money(600));
      expect(facts.unpaid, const Money(300));
      expect(facts.unknownCount, 1);
      expect(facts.hasRecords, isTrue);
      expect(
        monthFactsOf(MonthKey(2026, 9), lines, const []).hasRecords,
        isFalse,
      );
    },
  );
}
