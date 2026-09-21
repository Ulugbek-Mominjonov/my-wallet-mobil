import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'fakes.dart';

/// Natija `Ok` bo'lishi shart — qiymatini qaytaradi.
T ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('Ok kutilgan, $failure keldi'),
};

/// Natija `Err` bo'lishi shart — sababini qaytaradi.
Failure err<T>(Result<T> result) => switch (result) {
  Ok(:final value) => fail('Err kutilgan, $value keldi'),
  Err(:final failure) => failure,
};

PlannedItem _plan(
  String id, {
  PlanKind kind = PlanKind.expense,
  int? planned = 1000000,
  String? accountId = 'card',
  String? categoryId = 'food',
  String? debtId,
  MonthKey? month,
}) => PlannedItem(
  id: id,
  householdId: 'h',
  kind: kind,
  name: id,
  dueDate: LocalDate(2026, 10, 10),
  budgetMonth: month ?? MonthKey(2026, 10),
  plannedAmount: planned == null ? null : Money(planned),
  accountId: accountId,
  categoryId: kind == PlanKind.allocation ? null : categoryId,
  debtId: debtId,
);

void main() {
  late FakeStore store;
  setUp(() => store = FakeStore());

  TransactionInput input({
    TransactionKind kind = TransactionKind.expense,
    String accountId = 'card',
    int amount = 50000,
    String? categoryId = 'food',
    LocalDate? occurredOn,
    MonthKey? manualMonth,
    String? payee,
  }) => TransactionInput(
    kind: kind,
    accountId: accountId,
    amount: Money(amount),
    categoryId: categoryId,
    occurredOn: occurredOn,
    manualMonth: manualMonth,
    payee: payee,
  );

  group('AddTransaction (BR-050, BR-051)', () {
    test(
      'BR-040: 02.10 dagi Oylik (−1) sentabrga; bitta tranzaksiyada saqlanadi',
      () async {
        final tx = ok(
          await AddTransaction(store.deps)(
            input(
              kind: TransactionKind.income,
              categoryId: 'oylik',
              amount: 800000000,
              occurredOn: LocalDate(2026, 10, 2),
            ),
          ),
        );
        expect(tx.budgetMonth, MonthKey(2026, 9));
        expect(tx.budgetMonthSource, BudgetMonthSource.auto);
        expect(tx.amountBase, const Money(800000000));
        expect(tx.householdId, 'h');
        expect(store.transactions[tx.id], tx);
        expect(store.transactorRuns, 1);
      },
    );

    test("standart sana — bugun; qo'lda oy saqlanadi (BR-041)", () async {
      final today = ok(await AddTransaction(store.deps)(input()));
      expect(today.occurredOn, store.today);
      final manual = ok(
        await AddTransaction(store.deps)(input(manualMonth: MonthKey(2026, 9))),
      );
      expect(manual.budgetMonth, MonthKey(2026, 9));
      expect(manual.budgetMonthSource, BudgetMonthSource.manual);
    });

    test('joy nomi tozalanadi; 60 belgidan uzun — invalid_name', () async {
      final tx = ok(
        await AddTransaction(store.deps)(input(payee: '  Korzinka  ')),
      );
      expect(tx.payee, 'Korzinka');
      final blank = ok(await AddTransaction(store.deps)(input(payee: '   ')));
      expect(blank.payee, isNull);
      expect(
        err(await AddTransaction(store.deps)(input(payee: 'x' * 61))),
        const ValidationFailure('payee', 'invalid_name'),
      );
    });

    final invalidCases =
        <String, (TransactionInput Function(), ValidationFailure)>{
          'summa 0': (
            () => input(amount: 0),
            const ValidationFailure('amount', 'invalid_amount'),
          ),
          "hisob yo'q": (
            () => input(accountId: 'x'),
            const ValidationFailure('account', 'account_not_found'),
          ),
          'boshqa valyuta (E29)': (
            () => input(accountId: 'usd'),
            const ValidationFailure('amount', 'fx_rate_missing'),
          ),
          'BR-063: fondga daromad': (
            () => input(
              kind: TransactionKind.income,
              accountId: 'fund',
              categoryId: 'avans',
            ),
            const ValidationFailure('account', 'invalid_account'),
          ),
          'kategoriyasiz xarajat': (
            () => input(categoryId: null),
            const ValidationFailure('category', 'category_required'),
          ),
          "kategoriya yo'q": (
            () => input(categoryId: 'x'),
            const ValidationFailure('category', 'category_not_found'),
          ),
          'tur mos emas': (
            () => input(categoryId: 'oylik'),
            const ValidationFailure('category', 'category_kind_mismatch'),
          ),
        };
    for (final MapEntry(key: name, value: (build, failure))
        in invalidCases.entries) {
      test('$name — ${failure.code}', () async {
        expect(err(await AddTransaction(store.deps)(build())), failure);
        expect(store.transactions, isEmpty);
      });
    }

    test("o'chirilgan hisob va kategoriya", () async {
      store.accounts['card'] = store.accounts['card']!.copyWith(
        deletedAt: store.now,
      );
      expect(
        err(await AddTransaction(store.deps)(input())),
        const ValidationFailure('account', 'account_deleted'),
      );
      store.categories['food'] = store.categories['food']!.copyWith(
        deletedAt: store.now,
      );
      expect(
        err(await AddTransaction(store.deps)(input(accountId: 'cash'))),
        const ValidationFailure('category', 'category_deleted'),
      );
    });

    test("o'tkazma bu use-case orqali emas", () {
      expect(
        () => AddTransaction(store.deps)(input(kind: TransactionKind.transfer)),
        throwsArgumentError,
      );
    });
  });

  group('BR-055: yopilgan oy', () {
    test('qulfsiz — ogohlantirish, tasdiq bilan yoziladi', () async {
      store.closedMonths.add(MonthKey(2026, 10));
      final warning = err(await AddTransaction(store.deps)(input()));
      expect(
        warning,
        isA<MonthClosedWarning>().having(
          (w) => w.blocking,
          'blocking',
          isFalse,
        ),
      );
      expect(store.transactions, isEmpty);
      ok(await AddTransaction(store.deps)(input(), confirmClosedMonth: true));
      expect(store.transactions, hasLength(1));
    });

    test('qattiq qulf — tasdiq bilan ham taqiq', () async {
      store
        ..closedMonths.add(MonthKey(2026, 10))
        ..household = store.household.copyWith(strictMonthLock: true);
      final warning = err(
        await AddTransaction(store.deps)(input(), confirmClosedMonth: true),
      );
      expect(
        warning,
        isA<MonthClosedWarning>().having((w) => w.blocking, 'blocking', isTrue),
      );
    });
  });

  group("BR-053: o'tkazma", () {
    TransferInput transfer({
      String to = 'cash',
      int amount = 100000,
      int? toAmount,
    }) => TransferInput(
      fromAccountId: 'card',
      toAccountId: to,
      amount: Money(amount),
      toAmount: toAmount == null ? null : Money(toAmount, Currency.usd),
      occurredOn: LocalDate(2026, 10, 3),
    );

    test(
      'bir valyutada — manzil summasi = summa; oy — sana oyi (BR-046)',
      () async {
        final tx = ok(await AddTransfer(store.deps)(transfer()));
        expect(tx.kind, TransactionKind.transfer);
        expect(tx.toAmount, const Money(100000));
        expect(tx.categoryId, isNull);
        expect(tx.budgetMonth, MonthKey(2026, 10));
      },
    );

    test('BR-193: boshqa valyutaga — manzil summasi majburiy', () async {
      expect(
        err(await AddTransfer(store.deps)(transfer(to: 'usd'))),
        const ValidationFailure('to_amount', 'to_amount_required'),
      );
      expect(
        err(await AddTransfer(store.deps)(transfer(to: 'usd', toAmount: 0))),
        const ValidationFailure('to_amount', 'invalid_amount'),
      );
      final tx = ok(
        await AddTransfer(store.deps)(transfer(to: 'usd', toAmount: 790)),
      );
      expect(tx.toAmount, const Money(790, Currency.usd));
    });

    test("manba = manzil yoki manzil yo'q — xato", () async {
      expect(
        err(await AddTransfer(store.deps)(transfer(to: 'card'))),
        const ValidationFailure('to_account', 'invalid_target'),
      );
      expect(
        err(await AddTransfer(store.deps)(transfer(to: 'x'))),
        const ValidationFailure('to_account', 'account_not_found'),
      );
      store.accounts['cash'] = store.accounts['cash']!.copyWith(
        deletedAt: store.now,
      );
      expect(
        err(await AddTransfer(store.deps)(transfer())),
        const ValidationFailure('to_account', 'account_deleted'),
      );
    });
  });

  test(
    "BR-062: fonddan sarf — kategoriya ko'rsatilmasa \"O'zim uchun\"",
    () async {
      final tx = ok(
        await AddPersonalSpend(store.deps)(
          amount: const Money(45000000),
          payee: 'Kitob',
        ),
      );
      expect(tx.accountId, 'fund');
      expect(tx.categoryId, 'self');
      expect(tx.kind, TransactionKind.expense);
    },
  );

  group('BR-141: tez tugma', () {
    test('bugungi sana bilan darhol xarajat', () async {
      store.quickActions['taxi'] = const QuickAction(
        id: 'taxi',
        householdId: 'h',
        name: 'Taksi',
        amount: Money(2000000),
        categoryId: 'food',
        accountId: 'cash',
        payee: 'Yandex',
      );
      final tx = ok(await QuickAdd(store.deps)('taxi'));
      expect(tx.source, TransactionSource.quickAction);
      expect(tx.occurredOn, store.today);
      expect(tx.amount, const Money(2000000));
      expect(tx.payee, 'Yandex');
    });

    test("yo'q yoki o'chirilgan tugma", () async {
      expect(
        err(await QuickAdd(store.deps)('x')),
        const ValidationFailure('quick_action', 'not_found'),
      );
    });
  });

  group("BR-073: rejani to'lash", () {
    test("standart summa — qolgan; to'liq to'lov rejani yopadi", () async {
      store.plans['rent'] = _plan('rent');
      final tx = ok(await PayPlanned(store.deps)('rent'));
      expect(tx.amount, const Money(1000000));
      expect(tx.plannedItemId, 'rent');
      expect(tx.categoryId, 'food');
      expect(store.plans['rent']!.paidAmount, const Money(1000000));
      expect(store.plans['rent']!.settledAt, isNotNull);
      expect(store.transactorRuns, 1);
      expect(
        err(await PayPlanned(store.deps)('rent')),
        const ValidationFailure('plan', 'planned_already_paid'),
      );
    });

    test("qisman to'lov — partial; settle bilan yopiladi", () async {
      store.plans['gas'] = _plan('gas');
      ok(await PayPlanned(store.deps)('gas', amount: const Money(400000)));
      final partial = store.plans['gas']!;
      expect(PlannedStatus.of(partial, store.today), PlannedStatus.partial);
      ok(
        await PayPlanned(store.deps)(
          'gas',
          amount: const Money(100000),
          settle: true,
        ),
      );
      expect(store.plans['gas']!.closedAt, store.now);
      expect(store.plans['gas']!.settledAt, isNotNull);
    });

    test("BR-044: to'lov reja oyiga — keyingi oyda to'lansa ham", () async {
      store.plans['net'] = _plan('net', month: MonthKey(2026, 9));
      final tx = ok(
        await PayPlanned(store.deps)('net', date: LocalDate(2026, 10, 2)),
      );
      expect(tx.budgetMonth, MonthKey(2026, 9));
    });

    test("summasi noma'lum reja — summa majburiy; hisob majburiy", () async {
      store
        ..plans['svet'] = _plan('svet', planned: null)
        ..plans['nowhere'] = _plan('nowhere', accountId: null);
      expect(
        err(await PayPlanned(store.deps)('svet')),
        const ValidationFailure('amount', 'amount_required'),
      );
      expect(
        err(await PayPlanned(store.deps)('nowhere')),
        const ValidationFailure('account', 'account_required'),
      );
      ok(await PayPlanned(store.deps)('svet', amount: const Money(300000)));
      // Summasiz rejaga to'lov — to'landi.
      expect(store.plans['svet']!.settledAt, isNotNull);
    });

    test('boshqa valyutadagi hisob — summa standart emas', () async {
      store.plans['p'] = _plan('p', accountId: 'usd');
      expect(
        err(await PayPlanned(store.deps)('p')),
        const ValidationFailure('amount', 'amount_required'),
      );
    });

    test(
      "BR-061: ajratma rejasi — byudjet hisobidan fondga o'tkazma",
      () async {
        store.plans['fund'] = _plan(
          'fund',
          kind: PlanKind.allocation,
          accountId: 'cash',
        );
        final tx = ok(await PayPlanned(store.deps)('fund'));
        expect(tx.kind, TransactionKind.transfer);
        expect(tx.toAccountId, 'fund');
        expect(tx.categoryId, isNull);
        store.plans['fund2'] = _plan(
          'fund2',
          kind: PlanKind.allocation,
          accountId: 'fund',
        );
        expect(
          err(await PayPlanned(store.deps)('fund2')),
          const ValidationFailure('account', 'invalid_account'),
        );
      },
    );

    test(
      "BR-062: fond hisobidan reja to'lanmaydi; qarz bog'lanishi o'tadi",
      () async {
        store.plans['p'] = _plan('p', accountId: 'fund', debtId: 'car');
        expect(
          err(await PayPlanned(store.deps)('p')),
          const ValidationFailure('account', 'invalid_account'),
        );
        final tx = ok(await PayPlanned(store.deps)('p', accountId: 'card'));
        expect(tx.debtId, 'car');
      },
    );

    test('daromad rejasi — daromad amali', () async {
      store.plans['salary'] = _plan(
        'salary',
        kind: PlanKind.income,
        categoryId: 'avans',
      );
      final tx = ok(await PayPlanned(store.deps)('salary'));
      expect(tx.kind, TransactionKind.income);
    });

    test("yo'q, o'chirilgan va o'tkazilgan reja", () async {
      store
        ..plans['del'] = _plan('del').copyWith(deletedAt: store.now)
        ..plans['skip'] = _plan('skip').copyWith(skippedAt: store.now);
      expect(
        err(await PayPlanned(store.deps)('x')),
        const ValidationFailure('plan', 'planned_not_found'),
      );
      expect(
        err(await PayPlanned(store.deps)('del')),
        const ValidationFailure('plan', 'planned_not_found'),
      );
      expect(
        err(await PayPlanned(store.deps)('skip')),
        const ValidationFailure('plan', 'planned_skipped'),
      );
    });

    test("hisob topilmadi; yopilgan oy — to'lov yozilmaydi", () async {
      store.plans['p'] = _plan('p');
      expect(
        err(await PayPlanned(store.deps)('p', accountId: 'x')),
        const ValidationFailure('account', 'account_not_found'),
      );
      store.closedMonths.add(MonthKey(2026, 10));
      expect(err(await PayPlanned(store.deps)('p')), isA<MonthClosedWarning>());
      expect(store.plans['p']!.paidAmount, Money.zero);
    });
  });

  group("BR-071: o'tkazib yuborish", () {
    test('belgilanadi va qaytariladi', () async {
      store.plans['p'] = _plan('p');
      final skipped = ok(await SkipPlanned(store.deps)('p'));
      expect(skipped.skippedAt, store.now);
      expect(PlannedStatus.of(skipped, store.today), PlannedStatus.skipped);
      final restored = ok(await SkipPlanned(store.deps)('p', skipped: false));
      expect(restored.skippedAt, isNull);
      expect(
        err(await SkipPlanned(store.deps)('x')),
        const ValidationFailure('plan', 'planned_not_found'),
      );
    });
  });

  group('BR-073: yopish va BR-083: shu oy summasi', () {
    test("qisman to'langan reja yopiladi va qayta ochiladi", () async {
      store.plans['p'] = _plan('p');
      ok(await PayPlanned(store.deps)('p', amount: const Money(400000)));
      final closed = ok(await ClosePlan(store.deps)('p'));
      expect(closed.closedAt, store.now);
      expect(PlannedStatus.of(closed, store.today), PlannedStatus.paid);
      final reopened = ok(await ClosePlan(store.deps)('p', closed: false));
      expect(reopened.closedAt, isNull);
      expect(PlannedStatus.of(reopened, store.today), PlannedStatus.partial);
    });

    test("o'tkazilgan reja yopilmaydi", () async {
      store.plans['p'] = _plan('p').copyWith(skippedAt: store.now);
      expect(
        err(await ClosePlan(store.deps)('p')),
        const ValidationFailure('plan', 'planned_skipped'),
      );
    });

    test("summa o'zgaradi; to'langandan kam bo'lsa — to'landi", () async {
      store.plans['p'] = _plan('p');
      ok(await PayPlanned(store.deps)('p', amount: const Money(400000)));
      final edited = ok(
        await EditPlan(store.deps)(
          'p',
          plannedAmount: const Money(300000),
          dueDate: LocalDate(2026, 10, 20),
        ),
      );
      expect(edited.dueDate, LocalDate(2026, 10, 20));
      expect(PlannedStatus.of(edited, store.today), PlannedStatus.paid);
      final unknown = ok(await EditPlan(store.deps)('p', plannedAmount: null));
      expect(unknown.plannedAmount, isNull);
      expect(unknown.remaining, isNull);
    });

    test("noto'g'ri summa; avto to'lov summasiz bo'lmaydi", () async {
      store.plans['auto'] = _plan('auto').copyWith(autoPay: true);
      expect(
        err(await EditPlan(store.deps)('auto', plannedAmount: Money.zero)),
        const ValidationFailure('amount', 'invalid_amount'),
      );
      expect(
        err(await EditPlan(store.deps)('auto', plannedAmount: null)),
        const ValidationFailure('amount', 'amount_required'),
      );
      expect(
        err(await EditPlan(store.deps)('x', plannedAmount: null)),
        const ValidationFailure('plan', 'planned_not_found'),
      );
    });

    test("BR-055: yopilgan oy — tasdiq bilan; qat'iy qulfda taqiq", () async {
      store
        ..plans['p'] = _plan('p')
        ..closedMonths.add(MonthKey(2026, 10));
      expect(
        err(await SkipPlanned(store.deps)('p')),
        isA<MonthClosedWarning>().having((w) => w.blocking, 'blocking', false),
      );
      expect(store.plans['p']!.skippedAt, isNull);
      ok(await SkipPlanned(store.deps)('p', confirmClosedMonth: true));
      store.household = store.household.copyWith(strictMonthLock: true);
      expect(
        err(await ClosePlan(store.deps)('p', confirmClosedMonth: true)),
        isA<MonthClosedWarning>().having((w) => w.blocking, 'blocking', true),
      );
    });
  });

  group('tahrirlash', () {
    test("summa o'zgarsa — reja to'lovi ham (qayta ochiladi)", () async {
      store.plans['rent'] = _plan('rent');
      final paid = ok(await PayPlanned(store.deps)('rent'));
      final edited = ok(
        await EditTransaction(store.deps)(
          paid.id,
          (tx) => tx.copyWith(amount: const Money(600000)),
        ),
      );
      expect(edited.amountBase, const Money(600000));
      expect(store.plans['rent']!.paidAmount, const Money(600000));
      expect(store.plans['rent']!.settledAt, isNull);
    });

    test(
      'BR-043: izoh tahriri oyni qayta hisoblamaydi, sana — hisoblaydi',
      () async {
        final tx = ok(
          await AddTransaction(store.deps)(
            input(
              kind: TransactionKind.income,
              categoryId: 'oylik',
              occurredOn: LocalDate(2026, 10, 2),
            ),
          ),
        );
        // Kategoriya siljishi keyin o'zgargan (qayta joylash — alohida RPC).
        store.categories['oylik'] = store.categories['oylik']!.copyWith(
          monthShift: 0,
        );
        final noted = ok(
          await EditTransaction(store.deps)(
            tx.id,
            (t) => t.copyWith(note: 'bonus bilan'),
          ),
        );
        expect(noted.budgetMonth, MonthKey(2026, 9));
        final moved = ok(
          await EditTransaction(store.deps)(
            tx.id,
            (t) => t.copyWith(occurredOn: LocalDate(2026, 10, 3)),
          ),
        );
        expect(moved.budgetMonth, MonthKey(2026, 10));
      },
    );

    test("tur o'zgarmaydi; yo'q amal — not_found; eski oy yopilgan", () async {
      final tx = ok(await AddTransaction(store.deps)(input()));
      expect(
        () => EditTransaction(store.deps)(
          tx.id,
          (t) => t.copyWith(kind: TransactionKind.income),
        ),
        throwsArgumentError,
      );
      expect(
        err(await EditTransaction(store.deps)('x', (t) => t)),
        const ValidationFailure('id', 'not_found'),
      );
      store.closedMonths.add(MonthKey(2026, 10));
      expect(
        err(
          await EditTransaction(store.deps)(
            tx.id,
            (t) => t.copyWith(note: 'x'),
          ),
        ),
        isA<MonthClosedWarning>(),
      );
    });

    test("noto'g'ri tahrir saqlanmaydi", () async {
      final tx = ok(await AddTransaction(store.deps)(input()));
      expect(
        err(
          await EditTransaction(store.deps)(
            tx.id,
            (t) => t.copyWith(amount: Money.zero),
          ),
        ),
        const ValidationFailure('amount', 'invalid_amount'),
      );
      expect(store.transactions[tx.id], tx);
    });
  });

  group("BR-009: o'chirish va qaytarish", () {
    test(
      "o'chirilganda reja to'lovi kamayadi, qaytarilganda tiklanadi",
      () async {
        store.plans['rent'] = _plan('rent');
        final paid = ok(await PayPlanned(store.deps)('rent'));
        final snapshot = ok(await DeleteTransaction(store.deps)(paid.id));
        expect(snapshot, paid);
        expect(store.transactions[paid.id]!.deletedAt, store.now);
        expect(store.plans['rent']!.paidAmount, Money.zero);
        expect(store.plans['rent']!.settledAt, isNull);

        final restored = ok(await UndoDeleteTransaction(store.deps)(snapshot));
        expect(restored.isDeleted, isFalse);
        expect(store.plans['rent']!.settledAt, isNotNull);
        // Takror qaytarish — o'zgarishsiz.
        expect(ok(await UndoDeleteTransaction(store.deps)(snapshot)), restored);
      },
    );

    test(
      "ikki marta o'chirib bo'lmaydi; yopilgan oy — ogohlantirish",
      () async {
        final tx = ok(await AddTransaction(store.deps)(input()));
        ok(await DeleteTransaction(store.deps)(tx.id));
        expect(
          err(await DeleteTransaction(store.deps)(tx.id)),
          const ValidationFailure('id', 'not_found'),
        );
        expect(
          err(await UndoDeleteTransaction(store.deps)(tx.copyWith(id: 'x'))),
          const ValidationFailure('id', 'not_found'),
        );
        final other = ok(await AddTransaction(store.deps)(input()));
        store.closedMonths.add(MonthKey(2026, 10));
        expect(
          err(await DeleteTransaction(store.deps)(other.id)),
          isA<MonthClosedWarning>(),
        );
      },
    );

    test("reja lokal bazada bo'lmasa — xato yashirilmaydi", () async {
      final orphan = Transaction(
        id: 't',
        householdId: 'h',
        kind: TransactionKind.expense,
        accountId: 'card',
        amount: const Money(1),
        amountBase: const Money(1),
        occurredOn: store.today,
        budgetMonth: store.today.monthKey,
        plannedItemId: 'missing',
      );
      store.transactions['t'] = orphan;
      expect(() => DeleteTransaction(store.deps)('t'), throwsStateError);
    });
  });
}
