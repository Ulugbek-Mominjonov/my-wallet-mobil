import 'package:drift/drift.dart' show Value;
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "To'lovlar" testlari: 2026-yil oktabr (bugun — 10-oktabr), har holatdagi
/// rejalar: kechikkan, bugun (avto), yaqin (summasiz), keyinroq, to'langan,
/// o'tkazilgan va kutilayotgan daromad.
PlannedItem _plan(
  String id, {
  required String due,
  int? amount = 50000000,
  PlanKind kind = PlanKind.expense,
  String category = 'rent',
  Money paid = Money.zero,
  DateTime? settledAt,
  DateTime? skippedAt,
  bool autoPay = false,
}) => PlannedItem(
  id: id,
  householdId: 'h1',
  kind: kind,
  name: id,
  dueDate: LocalDate.parse(due),
  budgetMonth: MonthKey(2026, 10),
  categoryId: category,
  accountId: 'card',
  plannedAmount: amount == null ? null : Money(amount),
  paidAmount: paid,
  settledAt: settledAt,
  skippedAt: skippedAt,
  autoPay: autoPay,
  rowVersion: 1,
);

Future<void> seedPayments(AppDatabase db, {bool opened = true}) => db.batch((
  b,
) {
  b
    ..insert(
      db.households,
      const Household(
        id: 'h1',
        name: 'Uy',
        personalFund: PersonalFundRule(),
      ).toRow(),
    )
    ..insertAll(db.accounts, [
      for (final (id, type) in const [
        ('card', AccountType.card),
        ('cash', AccountType.cash),
        ('fund', AccountType.personalFund),
      ])
        Account(
          id: id,
          householdId: 'h1',
          name: id,
          type: type,
          openingBalance: Money.zero,
          rowVersion: 1,
        ).toCompanion(),
    ])
    ..insertAll(db.categories, [
      const Category(
        id: 'rent',
        householdId: 'h1',
        kind: CategoryKind.expense,
        name: 'Uy-joy',
      ).toCompanion(),
      const Category(
        id: 'salary',
        householdId: 'h1',
        kind: CategoryKind.income,
        name: 'Ish haqi',
      ).toCompanion(),
    ])
    ..insertAll(
      db.plannedItems,
      [
        _plan('Ijara', due: '2026-10-05', amount: 300000000),
        _plan('Internet', due: '2026-10-10', amount: 10000000, autoPay: true),
        _plan('Elektr', due: '2026-10-12', amount: null),
        _plan('Kurs', due: '2026-10-25'),
        _plan(
          'Gaz',
          due: '2026-10-02',
          amount: 20000000,
          paid: const Money(20000000),
          settledAt: DateTime.utc(2026, 10, 2),
        ),
        _plan('Sport', due: '2026-10-20', skippedAt: DateTime.utc(2026, 10)),
        _plan(
          'Oylik',
          due: '2026-10-15',
          amount: 1000000000,
          kind: PlanKind.income,
          category: 'salary',
        ),
      ].map((p) => p.toCompanion()),
    );
  if (opened) {
    b.insert(
      db.months,
      MonthsCompanion.insert(
        householdId: 'h1',
        month: '2026-10-01',
        openedAt: Value(DateTime.utc(2026, 10)),
      ),
    );
  }
});
