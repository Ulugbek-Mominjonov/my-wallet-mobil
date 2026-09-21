import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'fakes.dart';

void main() {
  late FakeStore store;
  setUp(() => store = FakeStore());

  group('BR-110: qarz', () {
    DebtInput input({
      String name = 'Mashina',
      int total = 1000000000,
      int? paidBefore,
      int? monthly,
      DebtDirection direction = DebtDirection.iOwe,
      String? note,
    }) => DebtInput(
      name: name,
      direction: direction,
      total: Money(total),
      paidBefore: paidBefore == null ? null : Money(paidBefore),
      monthlyPayment: monthly == null ? null : Money(monthly),
      note: note,
    );

    test("qo'shiladi: nom tozalanadi, oldin to'langan standart 0", () async {
      final debt = ok(
        await SaveDebt(store.deps)(input(name: '  Mashina ', note: ' ')),
      );
      expect(debt.name, 'Mashina');
      expect(debt.paidBefore, Money.zero);
      expect(debt.note, isNull);
      expect(store.debts[debt.id], debt);
      expect(store.transactorRuns, 1);
    });

    test("tahrirda yo'nalish o'zgarmaydi; nom registrsiz yagona", () async {
      final debt = ok(await SaveDebt(store.deps)(input()));
      final edited = ok(
        await SaveDebt(store.deps)(
          input(direction: DebtDirection.owedToMe, monthly: 100000000),
          id: debt.id,
        ),
      );
      expect(edited.direction, DebtDirection.iOwe);
      expect(edited.monthlyPayment, const Money(100000000));
      expect(
        err(await SaveDebt(store.deps)(input(name: 'MASHINA'))),
        const ValidationFailure('name', 'duplicate_name'),
      );
    });

    test("noto'g'ri qiymatlar — server cheklovlari bilan bir xil", () async {
      Future<Failure> fail(DebtInput value) async =>
          err(await SaveDebt(store.deps)(value));
      expect(
        await fail(input(name: '')),
        const ValidationFailure('name', 'invalid_name'),
      );
      expect(
        await fail(input(name: 'x' * 61)),
        const ValidationFailure('name', 'invalid_name'),
      );
      expect(
        await fail(input(total: 0)),
        const ValidationFailure('total', 'invalid_amount'),
      );
      expect(
        await fail(input(paidBefore: 1000000001)),
        const ValidationFailure('paid_before', 'invalid_amount'),
      );
      expect(
        await fail(input(monthly: 0)),
        const ValidationFailure('monthly_payment', 'invalid_amount'),
      );
      expect(
        await fail(input(note: 'x' * 1001)),
        const ValidationFailure('note', 'invalid_note'),
      );
      expect(
        err(await SaveDebt(store.deps)(input(), id: 'x')),
        const ValidationFailure('debt', 'debt_not_found'),
      );
    });

    test('arxivlanadi va qaytariladi', () async {
      final debt = ok(await SaveDebt(store.deps)(input()));
      final archived = ok(
        await SetDebtArchived(store.deps)(debt.id, archived: true),
      );
      expect(archived.archivedAt, store.now);
      final restored = ok(
        await SetDebtArchived(store.deps)(debt.id, archived: false),
      );
      expect(restored.archivedAt, isNull);
    });
  });

  group('BR-120, BR-122: maqsad', () {
    test("qo'lda yig'ilgan; hisobga bog'lash — valyuta bir xil", () async {
      final goal = ok(
        await SaveGoal(store.deps)(
          GoalInput(
            name: "Ta'til",
            target: const Money(1000000000),
            savedManual: const Money(300000000),
            deadline: MonthKey(2027, 10),
          ),
        ),
      );
      expect(goal.savedManual, const Money(300000000));
      expect(goal.deadline, MonthKey(2027, 10));

      final linked = ok(
        await SaveGoal(store.deps)(
          const GoalInput(
            name: "Ta'til",
            target: Money(1000000000),
            accountId: 'card',
          ),
          id: goal.id,
        ),
      );
      expect(linked.accountId, 'card');
      expect(
        err(
          await SaveGoal(store.deps)(
            const GoalInput(
              name: 'USD',
              target: Money(1000000000),
              accountId: 'usd',
            ),
          ),
        ),
        const ValidationFailure('account', 'currency_mismatch'),
      );
    });

    test("noto'g'ri qiymatlar va takror nom", () async {
      ok(
        await SaveGoal(store.deps)(
          const GoalInput(name: 'Noutbuk', target: Money(100)),
        ),
      );
      Future<Failure> fail(GoalInput value) async =>
          err(await SaveGoal(store.deps)(value));
      expect(
        await fail(const GoalInput(name: 'noutbuk ', target: Money(100))),
        const ValidationFailure('name', 'duplicate_name'),
      );
      expect(
        await fail(const GoalInput(name: 'A', target: Money.zero)),
        const ValidationFailure('target', 'invalid_amount'),
      );
      expect(
        await fail(
          const GoalInput(name: 'A', target: Money(1), savedManual: Money(-1)),
        ),
        const ValidationFailure('saved', 'invalid_amount'),
      );
      expect(
        await fail(
          const GoalInput(
            name: 'A',
            target: Money(1),
            monthlyContribution: Money.zero,
          ),
        ),
        const ValidationFailure('monthly', 'invalid_amount'),
      );
      expect(
        await fail(
          const GoalInput(name: 'A', target: Money(1), accountId: 'x'),
        ),
        const ValidationFailure('account', 'account_not_found'),
      );
    });

    test("BR-123: yig'ildi — bir marta; o'chirish", () async {
      final goal = ok(
        await SaveGoal(store.deps)(
          const GoalInput(name: 'Karta', target: Money(100)),
        ),
      );
      final achieved = ok(await MarkGoalAchieved(store.deps)(goal.id));
      expect(achieved.achievedAt, store.now);
      final runs = store.transactorRuns;
      ok(await MarkGoalAchieved(store.deps)(goal.id));
      expect(store.transactorRuns, runs);

      final deleted = ok(await DeleteGoal(store.deps)(goal.id));
      expect(deleted.deletedAt, store.now);
      expect(
        err(await DeleteGoal(store.deps)(goal.id)),
        const ValidationFailure('goal', 'goal_not_found'),
      );
    });
  });

  group('BR-130: kategoriya limiti', () {
    test("qo'yiladi, o'zgaradi (o'sha yozuv), olib tashlanadi", () async {
      final limit = ok(
        await SetCategoryLimit(store.deps)('food', amount: const Money(100)),
      );
      final changed = ok(
        await SetCategoryLimit(store.deps)('food', amount: const Money(200)),
      );
      expect(changed?.id, limit?.id);
      expect(changed?.amount, const Money(200));
      expect(
        ok(await SetCategoryLimit(store.deps)('food', amount: null)),
        isNull,
      );
      expect(store.limits[limit!.id]!.deletedAt, store.now);
      // Qayta qo'yilsa — yangi yozuv (serverdagi qisman yagona indeks).
      final again = ok(
        await SetCategoryLimit(store.deps)('food', amount: const Money(300)),
      );
      expect(again?.id, isNot(limit.id));
    });

    test('faqat xarajat kategoriyasiga, musbat summa', () async {
      expect(
        err(
          await SetCategoryLimit(store.deps)('avans', amount: const Money(1)),
        ),
        const ValidationFailure('category', 'category_kind_mismatch'),
      );
      expect(
        err(await SetCategoryLimit(store.deps)('food', amount: Money.zero)),
        const ValidationFailure('amount', 'invalid_amount'),
      );
      expect(
        err(await SetCategoryLimit(store.deps)('x', amount: const Money(1))),
        const ValidationFailure('category', 'category_not_found'),
      );
    });
  });
}
