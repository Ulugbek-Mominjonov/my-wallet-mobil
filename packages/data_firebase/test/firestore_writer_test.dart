import 'package:data_firebase/data_firebase.dart';
import 'package:domain/domain.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const personal = "o'zim uchun";
  const uid = 'u1';
  late FakeFirebaseFirestore db;
  late FirestoreRefs refs;
  late FirestoreBudgetWriter writer;

  setUp(() {
    db = FakeFirebaseFirestore();
    refs = FirestoreRefs(db: db, uid: uid);
    writer = FirestoreBudgetWriter(refs: refs, awaitServer: true);
  });

  Expense expense({
    String id = 'e1',
    String category = 'Oziq-ovqat',
    int? planned = 500000,
    int? actual,
    String monthKey = '2026-09',
    String? debtId,
  }) =>
      Expense(
        id: id,
        name: 'Test',
        category: category,
        method: PaymentMethod.cash,
        planned: planned == null ? null : Money(planned),
        actual: actual == null ? null : Money(actual),
        dueDate: DateTime(2026, 9, 15),
        monthKey: MonthKey(monthKey),
        debtId: debtId,
      );

  Future<Map<String, dynamic>> monthDoc(String key) async =>
      (await refs.month(MonthKey(key)).get()).data() ?? <String, dynamic>{};

  group('delta yozuvi', () {
    test("agregat hujjati o'zi yaratiladi va increment bilan to'ladi",
        () async {
      final item = expense(actual: 400000);
      await writer.commit(
        WriteCommand(
          mutations: <DocMutation>[UpsertExpense(item)],
          delta: AggregateDelta.forExpense(
            personalCategoryKey: personal,
            after: item,
          ),
        ),
      );

      final month = await monthDoc('2026-09');
      expect(month['expense'], 400000);
      expect(month['expenseCash'], 400000);
      expect(month['planned'], 500000);
      expect(month['monthKey'], '2026-09');
      final categories = month['byCategory'] as Map<String, dynamic>;
      expect(
        categories['Oziq-ovqat'],
        <String, dynamic>{'planned': 500000, 'actual': 400000},
      );

      final totals = (await refs.totals.get()).data()!;
      expect(totals['expense'], 400000);
    });

    test("ketma-ket yozuvlar qiymatni ustiga qo'shadi", () async {
      for (var i = 0; i < 3; i++) {
        final item = expense(id: 'e$i', actual: 100000, planned: 100000);
        await writer.commit(
          WriteCommand(
            mutations: <DocMutation>[UpsertExpense(item)],
            delta: AggregateDelta.forExpense(
              personalCategoryKey: personal,
              after: item,
            ),
          ),
        );
      }
      final month = await monthDoc('2026-09');
      expect(month['expense'], 300000);
      expect(
        (month['byCategory'] as Map<String, dynamic>)['Oziq-ovqat'],
        <String, dynamic>{'planned': 300000, 'actual': 300000},
      );
    });

    test("oy ko'chirilsa ikkala hujjat bitta batchda to'g'rilanadi",
        () async {
      final before = expense(actual: 500000);
      await writer.commit(
        WriteCommand(
          mutations: <DocMutation>[UpsertExpense(before)],
          delta: AggregateDelta.forExpense(
            personalCategoryKey: personal,
            after: before,
          ),
        ),
      );
      final after = before.copyWith(
        monthKey: const MonthKey('2026-10'),
        monthKeySource: MonthKeySource.manual,
      );
      await writer.commit(
        WriteCommand(
          mutations: <DocMutation>[UpsertExpense(after)],
          delta: AggregateDelta.forExpense(
            personalCategoryKey: personal,
            before: before,
            after: after,
          ),
        ),
      );

      expect((await monthDoc('2026-09'))['expense'], 0);
      expect((await monthDoc('2026-10'))['expense'], 500000);
      final totals = (await refs.totals.get()).data()!;
      expect(totals['expense'], 500000, reason: "umumiy jami o'zgarmaydi");
    });

    test('qarz hisoblagichi faqat fakt kiritilganda oshadi', () async {
      final unpaid = expense(debtId: 'd1', planned: 5300000);
      await writer.commit(
        WriteCommand(
          mutations: <DocMutation>[UpsertExpense(unpaid)],
          delta: AggregateDelta.forExpense(
            personalCategoryKey: personal,
            after: unpaid,
          ),
        ),
      );
      var debt = (await refs.debt('d1').get()).data()!;
      expect(debt['pendingFromApp'], 5300000);
      expect(debt['paidFromExpenses'], isNull);

      final paid = unpaid.copyWith(actual: const Money(5300000));
      await writer.commit(
        WriteCommand(
          mutations: <DocMutation>[UpsertExpense(paid)],
          delta: AggregateDelta.forExpense(
            personalCategoryKey: personal,
            before: unpaid,
            after: paid,
          ),
        ),
      );
      debt = (await refs.debt('d1').get()).data()!;
      expect(debt['paidFromExpenses'], 5300000);
      expect(debt['pendingFromApp'], 0);
    });

    test("nuqtali kategoriya nomi ham to'g'ri yoziladi", () async {
      final item = expense(category: 'Uy.kommunal', actual: 100);
      await writer.commit(
        WriteCommand(
          delta: AggregateDelta.forExpense(
            personalCategoryKey: personal,
            after: item,
          ),
        ),
      );
      final categories =
          (await monthDoc('2026-09'))['byCategory'] as Map<String, dynamic>;
      expect(categories.containsKey('Uy.kommunal'), isTrue);
      expect(
        (categories['Uy.kommunal'] as Map<String, dynamic>)['actual'],
        100,
      );
    });

    test("bo'sh buyruq hech narsa yozmaydi", () async {
      await writer.commit(const WriteCommand());
      expect((await refs.totals.get()).exists, isFalse);
    });
  });

  group("hujjat yozish/o'qish", () {
    test("xarajat saqlanadi va qayta o'qiladi", () async {
      final item = expense(actual: 250000, debtId: 'd1');
      await writer.commit(
        WriteCommand(mutations: <DocMutation>[UpsertExpense(item)]),
      );
      final loaded =
          await FirestoreExpenseRepository(refs).fetchById('e1');
      expect(loaded!.name, 'Test');
      expect(loaded.actual, const Money(250000));
      expect(loaded.planned, const Money(500000));
      expect(loaded.monthKey, const MonthKey('2026-09'));
      expect(loaded.debtId, 'd1');
      expect(loaded.method, PaymentMethod.cash);
    });

    test('qarz tahrirlanganda hisoblagichlar saqlanib qoladi', () async {
      await refs.debt('d1').set(<String, Object?>{
        'name': 'Mashina',
        'direction': 'iOwe',
        'total': 1000,
        'paidFromExpenses': 400,
      });
      const debt = Debt(
        id: 'd1',
        name: 'Mashina (yangi nom)',
        direction: DebtDirection.iOwe,
        total: Money(1200),
      );
      await writer.commit(
        const WriteCommand(mutations: <DocMutation>[UpsertDebt(debt)]),
      );
      final stored = (await refs.debt('d1').get()).data()!;
      expect(stored['name'], 'Mashina (yangi nom)');
      expect(stored['total'], 1200);
      expect(stored['paidFromExpenses'], 400, reason: 'hisoblagich tegilmadi');
    });

    test('oy yopiladi va ochiladi', () async {
      await writer.commit(
        const WriteCommand(
          mutations: <DocMutation>[
            SetMonthClosed(monthKey: MonthKey('2026-08'), closed: true),
          ],
        ),
      );
      expect((await monthDoc('2026-08'))['closed'], isTrue);
      expect(
        await FirestoreMonthRepository(refs)
            .isClosed(const MonthKey('2026-08')),
        isTrue,
      );
    });

    test('reconciler mutlaq qiymat bilan ustiga yozadi', () async {
      await refs.month(const MonthKey('2026-09')).set(<String, Object?>{
        'income': 999,
        'expense': 5,
      });
      await writer.commit(
        const WriteCommand(
          mutations: <DocMutation>[
            OverwriteMonthAggregate(
              MonthSummary(
                monthKey: MonthKey('2026-09'),
                income: Money(1000),
              ),
            ),
          ],
        ),
      );
      final month = await monthDoc('2026-09');
      expect(month['income'], 1000);
      expect(month['expense'], 0, reason: "to'liq almashtirildi");
    });
  });

  group("so'rovlar", () {
    test("oy bo'yicha ro'yxat va kursor", () async {
      for (var i = 0; i < 5; i++) {
        await refs.expense('e$i').set(
              ExpenseDto.toFirestore(
                expense(id: 'e$i', actual: 100).copyWith(
                  dueDate: DateTime(2026, 9, i + 1),
                ),
              ),
            );
      }
      final page = await FirestoreExpenseRepository(refs).fetchMonth(
        const MonthKey('2026-09'),
        limit: 3,
      );
      expect(page.items.map((item) => item.id), <String>['e0', 'e1', 'e2']);
      expect(page.hasMore, isTrue);
      expect(page.cursor, isNotNull);
      expect(
        page.cursor,
        '${DateTime(2026, 9, 3).millisecondsSinceEpoch}|e2',
        reason: 'kursor = saralash qiymati + hujjat id',
      );
    });

    test(
      'keyingi sahifa kursordan davom etadi',
      () async {
        for (var i = 0; i < 5; i++) {
          await refs.expense('e$i').set(
                ExpenseDto.toFirestore(
                  expense(id: 'e$i', actual: 100).copyWith(
                    dueDate: DateTime(2026, 9, i + 1),
                  ),
                ),
              );
        }
        final repository = FirestoreExpenseRepository(refs);
        final page = await repository.fetchMonth(
          const MonthKey('2026-09'),
          limit: 3,
        );
        final next = await repository.fetchMonth(
          const MonthKey('2026-09'),
          limit: 3,
          cursor: page.cursor,
        );
        expect(next.items.map((item) => item.id), <String>['e3', 'e4']);
        expect(next.hasMore, isFalse);
      },
      // `fake_cloud_firestore` `orderBy(FieldPath.documentId)` bilan
      // `startAfter` ni qo'llab-quvvatlamaydi. Haqiqiy Firestore'da bu
      // yagona TO'G'RI usul: bir xil sanali yozuvlar o'tkazib
      // yuborilmasligi uchun hujjat id ham saralashga qo'shiladi.
      // Emulyatordagi integratsion test buni qoplaydi.
      skip: 'fake_cloud_firestore cheklovi — emulyatorda tekshiriladi',
    );

    test("to'lanmaganlar status indeksidan olinadi", () async {
      await refs.expense('paid').set(
            ExpenseDto.toFirestore(
              expense(id: 'paid', actual: 100)
                  .copyWith(status: PaymentStatus.paid),
            ),
          );
      await refs.expense('due').set(
            ExpenseDto.toFirestore(
              expense(id: 'due').copyWith(status: PaymentStatus.overdue),
            ),
          );
      final unpaid =
          await FirestoreExpenseRepository(refs).fetchUnpaid();
      expect(unpaid.map((item) => item.id), <String>['due']);
    });

    test("qarz tarixi bitta so'rov bilan olinadi", () async {
      await refs.expense('a').set(
            ExpenseDto.toFirestore(expense(id: 'a', debtId: 'd1')),
          );
      await refs.expense('b').set(
            ExpenseDto.toFirestore(expense(id: 'b', debtId: 'd2')),
          );
      final history =
          await FirestoreExpenseRepository(refs).fetchByDebt('d1');
      expect(history.map((item) => item.id), <String>['a']);
    });

    test("dashboard 2 hujjatdan o'qiydi", () async {
      await refs.month(const MonthKey('2026-09')).set(<String, Object?>{
        'income': 12000000,
        'expense': 9500000,
      });
      await refs.totals.set(<String, Object?>{
        'income': 50000000,
        'expense': 30000000,
      });
      final month = await FirestoreMonthRepository(refs)
          .fetch(const MonthKey('2026-09'));
      final totals = await FirestoreTotalsRepository(refs).fetch();
      expect(month.balance, const Money(2500000));
      expect(totals.savings, const Money(20000000));
    });

    test("sozlamalar standart qiymatlar bilan o'qiladi", () async {
      final settings =
          await FirestoreSettingsRepository(refs).fetch();
      expect(settings.app.personalCategory, "O'zim uchun");
      expect(settings.incomeRules.shiftFor('Oylik'), -1);

      await writer.commit(
        const WriteCommand(
          mutations: <DocMutation>[
            SaveSettings(
              BudgetSettings(
                incomeRules: IncomeRules(<IncomeRule>[
                  IncomeRule(type: 'Oylik', shift: 0),
                ]),
              ),
            ),
          ],
        ),
      );
      final updated =
          await FirestoreSettingsRepository(refs).fetch();
      expect(updated.incomeRules.shiftFor('Oylik'), 0);
    });
  });

  group('DTO himoyasi', () {
    test('buzuq hujjat ilovani yiqitmaydi', () async {
      await refs.expense('bad').set(<String, Object?>{
        'name': 42,
        'planned': "yo'q",
        'monthKey': 'buzuq',
        'dueDate': 'kecha',
        'method': null,
      });
      final loaded =
          await FirestoreExpenseRepository(refs).fetchById('bad');
      expect(loaded!.name, '');
      expect(loaded.planned, isNull);
      expect(loaded.method, PaymentMethod.cash);
      expect(MonthKey.isValid(loaded.monthKey), isTrue);
    });
  });
}
