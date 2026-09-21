import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/local/mappers.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.batch((batch) {
      batch
        ..insert(
          db.households,
          const Household(
            id: 'h1',
            name: 'Uy',
            personalFund: PersonalFundRule(),
          ).toRow(),
        )
        ..insertAll(db.accounts, [
          for (final (id, name, type, order) in const [
            ('a1', 'Naqd', AccountType.cash, 1),
            ('a2', 'Karta', AccountType.card, 2),
            ('a3', 'Shaxsiy fond', AccountType.personalFund, 3),
          ])
            Account(
              id: id,
              householdId: 'h1',
              name: name,
              type: type,
              openingBalance: Money.zero,
              sortOrder: order,
              rowVersion: 1,
            ).toCompanion(),
        ])
        ..insertAll(db.tags, [
          const Tag(id: 't1', householdId: 'h1', name: 'Safar').toCompanion(),
          const Tag(id: 't2', householdId: 'h1', name: 'Bola').toCompanion(),
        ])
        ..insertAll(db.debts, [
          const Debt(
            id: 'd1',
            householdId: 'h1',
            name: 'Aka',
            direction: DebtDirection.iOwe,
            total: Money(100000000),
            paidBefore: Money.zero,
          ).toCompanion(),
        ])
        ..insertAll(db.categories, [
          const Category(
            id: 'c1',
            householdId: 'h1',
            kind: CategoryKind.expense,
            name: 'Oziq-ovqat',
          ).toCompanion(),
          const Category(
            id: 'c2',
            householdId: 'h1',
            kind: CategoryKind.income,
            name: 'Oylik',
            monthShift: -1,
          ).toCompanion(),
        ]);
    });
  });
  tearDown(() => db.close());

  Future<void> openSheet(WidgetTester tester) async {
    await pumpApp(tester, database: db);
    await tester.tap(find.byTooltip("Amal qo'shish"));
    await tester.pumpAndSettle();
  }

  /// Maydonlar ro'yxatda — kerak bo'lsa ko'rinadigan joyga suriladi.
  Future<void> tapChip(
    WidgetTester tester,
    String label, {
    bool last = false,
  }) async {
    final chips = find.widgetWithText(ChoiceChip, label);
    final chip = last ? chips.last : chips.first;
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  Future<void> enterField(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    final field = find.widgetWithText(TextField, label);
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  Future<void> tapKeys(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await tester.tap(find.widgetWithText(TextButton, key));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('summa klaviaturasi: raqamlar, 000 va jonli format', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text('Xarajat'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saqlash'))
          .onPressed,
      isNull,
      reason: 'summa kiritilmagan',
    );

    await tapKeys(tester, ['1', '2', '000']);
    expect(find.text("12 000 so'm"), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saqlash'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('oddiy hisob: 12 000 + 3 000 = 15 000', (tester) async {
    await openSheet(tester);
    await tapKeys(tester, ['1', '2', '000', '+']);
    expect(find.textContaining('+'), findsWidgets);
    await tapKeys(tester, ['3', '000', '=']);
    expect(find.text("15 000 so'm"), findsOneWidget);
  });

  testWidgets('xarajat saqlanadi: hisob, kategoriya, joy nomi va izoh', (
    tester,
  ) async {
    await openSheet(tester);
    await tapKeys(tester, ['4', '5', '000']);

    await tapChip(tester, 'Karta');
    await tapChip(tester, 'Oziq-ovqat');
    await enterField(tester, 'Joy / kimga', 'Korzinka');
    await enterField(tester, 'Izoh', 'kechki');

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final saved = await db.select(db.transactions).getSingle();
    expect(
      (saved.kind, saved.amount, saved.accountId, saved.categoryId),
      ('expense', 4500000, 'a2', 'c1'),
    );
    expect((saved.payee, saved.note), ('Korzinka', 'kechki'));
    // Yozuv navbatga tushdi (oflaynda ham ishlaydi).
    expect(await db.select(db.outbox).get(), hasLength(1));
    expect(find.text('Saqlandi'), findsOneWidget);
  });

  testWidgets("o'tkazma: manzil hisob tanlanmaguncha saqlab bo'lmaydi", (
    tester,
  ) async {
    await openSheet(tester);
    await tapKeys(tester, ['1', '000']);
    await tester.tap(find.text("O'tkazma"));
    await tester.pumpAndSettle();
    expect(find.text('Qayerga'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saqlash'))
          .onPressed,
      isNull,
    );

    // Manba — Naqd (standart), manzil ro'yxatida u yo'q.
    expect(find.widgetWithText(ChoiceChip, 'Karta'), findsNWidgets(2));
    await tapChip(tester, 'Karta', last: true);
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final saved = await db.select(db.transactions).getSingle();
    expect(
      (saved.kind, saved.accountId, saved.toAccountId),
      ('transfer', 'a1', 'a2'),
    );
  });

  testWidgets('BR-035: joyida yangi kategoriya — yaratiladi va tanlanadi', (
    tester,
  ) async {
    await openSheet(tester);
    await tapKeys(tester, ['9', '000']);
    final add = find.widgetWithText(ActionChip, 'Yangi kategoriya');
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '  Sport ');
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash').last);
    await tester.pumpAndSettle();

    final created = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Sport'))).getSingle();
    expect(created.kind, 'expense');
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Sport'))
          .selected,
      isTrue,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    final saved = await db.select(db.transactions).getSingle();
    expect(saved.categoryId, created.id);
    // Kategoriya ham, amal ham navbatda.
    final queued = await db.select(db.outbox).get();
    expect(
      {for (final m in queued) m.targetTable},
      {'categories', 'transactions'},
    );
  });

  testWidgets('teglar va qarz: amal bilan birga saqlanadi', (tester) async {
    await openSheet(tester);
    await tapKeys(tester, ['2', '000']);
    await tapChip(tester, 'Oziq-ovqat');
    await tapChip(tester, 'Aka');
    final tag = find.widgetWithText(FilterChip, 'Safar');
    await tester.ensureVisible(tag);
    await tester.tap(tag);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final saved = await db.select(db.transactions).getSingle();
    expect(saved.debtId, 'd1');
    final links = await db.select(db.transactionTags).get();
    expect(
      [for (final l in links) (l.transactionId, l.tagId)],
      [(saved.id, 't1')],
    );
    final queued = await db.select(db.outbox).get();
    expect([for (final m in queued) m.targetTable]..sort(), [
      'transaction_tags',
      'transactions',
    ]);
  });

  testWidgets('kategoriyasiz xarajat — aniq xabar', (tester) async {
    await openSheet(tester);
    await tapKeys(tester, ['1', '000']);
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.text('Kategoriyani tanlang'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  testWidgets('⌫ va tur almashtirish', (tester) async {
    await openSheet(tester);
    await tapKeys(tester, ['5', '000']);
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    expect(find.text("500 so'm"), findsOneWidget);

    await tester.tap(find.text('Daromad'));
    await tester.pumpAndSettle();
    // Tur o'zgarsa ham summa qoladi.
    expect(find.text("500 so'm"), findsOneWidget);
  });
}
