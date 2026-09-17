import 'package:domain/domain.dart';
import 'package:test/test.dart';

import '../support/builders.dart';

void main() {
  group('copyWith — null qilish va tegmaslik farqi', () {
    test("Expense: berilmagan maydon o'zgarmaydi", () {
      final before = Build.expense(planned: 100, actual: 50, debtId: 'd1');
      final after = before.copyWith(name: 'Yangi');
      expect(after.name, 'Yangi');
      expect(after.planned, const Money(100));
      expect(after.actual, const Money(50));
      expect(after.debtId, 'd1');
    });

    test('Expense: ataylab null berilsa tozalanadi', () {
      final before = Build.expense(planned: 100, actual: 50, debtId: 'd1');
      final after = before.copyWith(
        actual: null,
        planned: null,
        debtId: null,
        recurringId: null,
      );
      expect(after.actual, isNull);
      expect(after.planned, isNull);
      expect(after.debtId, isNull);
      expect(after.isPaid, isFalse);
      expect(after.isUnknownAmount, isTrue);
    });

    test('Income, PersonalSpend, Debt, Goal ham nusxalanadi', () {
      final income = Build.income().copyWith(note: 'izoh', debtId: null);
      expect(income.note, 'izoh');
      expect(income.debtId, isNull);
      expect(income.typeKey, 'oylik');

      final spend = Build.personalSpend().copyWith(purpose: "Sovg'a");
      expect(spend.purpose, "Sovg'a");

      final debt = Build.debt().copyWith(archived: true, dueDate: null);
      expect(debt.archived, isTrue);
      expect(debt.isMine, isTrue);

      final goal = Build.goal().copyWith(monthly: const Money(5), order: 3);
      expect(goal.monthly, const Money(5));
      expect(goal.order, 3);
    });

    test('katalog obyektlari nusxalanadi', () {
      final recurring = Build.recurring().copyWith(
        amount: null,
        debtId: 'd1',
        active: false,
      );
      expect(recurring.amount, isNull);
      expect(recurring.debtId, 'd1');
      expect(recurring.active, isFalse);
      expect(recurring.nameKey, 'internet');

      const limit = CategoryLimit(
        id: 'l1',
        category: 'Oziq-ovqat',
        monthlyLimit: Money(100),
      );
      expect(limit.copyWith(monthlyLimit: const Money(200)).monthlyLimit,
          const Money(200),);
      expect(limit.categoryKey, 'oziq-ovqat');

      const quick = QuickAdd(
        id: 'q1',
        name: 'Taksi',
        amount: Money(20000),
        category: 'Transport',
        method: PaymentMethod.cash,
      );
      expect(quick.copyWith(order: 2).order, 2);
      expect(quick, const QuickAdd(
        id: 'q1',
        name: 'Taksi',
        amount: Money(20000),
        category: 'Transport',
        method: PaymentMethod.cash,
      ),);

      const category = CategoryDef(id: 'c1', name: 'Transport');
      expect(category.copyWith(parentId: 'c0').parentId, 'c0');
      expect(category.copyWith(parentId: null).parentId, isNull);
      expect(category.nameKey, 'transport');
      expect(category.kind, CategoryKind.expense);
    });
  });

  group('tenglik va xesh', () {
    test('bir xil yozuvlar teng', () {
      expect(Build.expense(), Build.expense());
      expect(Build.expense().hashCode, Build.expense().hashCode);
      expect(Build.income(), Build.income());
      expect(Build.income().hashCode, Build.income().hashCode);
      expect(Build.personalSpend(), Build.personalSpend());
      expect(Build.personalSpend().hashCode, Build.personalSpend().hashCode);
      expect(Build.debt(), Build.debt());
      expect(Build.debt().hashCode, Build.debt().hashCode);
      expect(Build.goal(), Build.goal());
      expect(Build.goal().hashCode, Build.goal().hashCode);
      expect(Build.recurring(), Build.recurring());
      expect(Build.recurring().hashCode, Build.recurring().hashCode);
    });

    test('farqli yozuvlar teng emas', () {
      expect(Build.expense() == Build.expense(id: 'boshqa'), isFalse);
      expect(Build.income() == Build.income(amount: 1), isFalse);
      expect(Build.debt() == Build.debt(total: 1), isFalse);
      expect(Build.goal() == Build.goal(target: 1), isFalse);
    });

    test("matn ko'rinishi asosiy maydonlarni ko'rsatadi", () {
      expect(Build.expense().toString(), contains('2026-09'));
      expect(Build.income().toString(), contains('Oylik'));
      expect(Build.personalSpend().toString(), contains('Kitob'));
      expect(Build.debt().toString(), contains('Mashina'));
      expect(Build.goal().toString(), contains('Sayohat'));
      expect(Build.recurring().toString(), contains('Internet'));
    });
  });

  group('sozlamalar', () {
    test('standart qiymatlar', () {
      const settings = BudgetSettings();
      expect(settings.app.personalCategory, "O'zim uchun");
      expect(settings.app.personalCategoryKey, "o'zim uchun");
      expect(settings.reminders.reportDay, 21);
      expect(settings.personalFund.mode, PersonalFundMode.percent);
      expect(settings, const BudgetSettings());
      expect(settings.hashCode, const BudgetSettings().hashCode);
    });

    test('nusxalash', () {
      final settings = const BudgetSettings().copyWith(
        app: const AppSettings(locale: 'ru'),
        reminders: const ReminderSettings(reportDay: 1),
        personalFund: const PersonalFundSettings(value: 20),
        incomeRules: IncomeRules.defaults,
      );
      expect(settings.app.locale, 'ru');
      expect(settings.reminders.reportDay, 1);
      expect(settings.personalFund.value, 20);
      expect(
        settings.app.copyWith(themeMode: 'dark').themeMode,
        'dark',
      );
      expect(
        settings.reminders.copyWith(telegramEnabled: true).telegramEnabled,
        isTrue,
      );
      expect(
        settings.personalFund.copyWith(day: 5).day,
        5,
      );
      expect(settings.app == const AppSettings(), isFalse);
      expect(
        const ReminderSettings().hashCode,
        const ReminderSettings().hashCode,
      );
      expect(
        const PersonalFundSettings().hashCode,
        const PersonalFundSettings().hashCode,
      );
      expect(const AppSettings().hashCode, const AppSettings().hashCode);
    });

    test('daromad qoidalari', () {
      const rules = IncomeRules.defaults;
      expect(rules.shiftFor('Oylik'), -1);
      expect(rules.shiftFor('Avans'), 0);
      expect(rules.shiftFor("Noma'lum"), 0);
      expect(rules, IncomeRules.defaults);
      expect(rules.hashCode, IncomeRules.defaults.hashCode);
      expect(rules.toString(), contains('Oylik'));

      final updated = rules
          .withRule(const IncomeRule(type: 'Oylik', shift: 0))
          .withRule(const IncomeRule(type: 'Bonus', shift: -1));
      expect(updated.shiftFor('Oylik'), 0);
      expect(updated.shiftFor('Bonus'), -1);
      expect(updated.rules.length, 5);
      expect(
        const IncomeRule(type: 'A', shift: 1),
        const IncomeRule(type: 'A', shift: 1),
      );
      expect(
        const IncomeRule(type: 'A', shift: 1).hashCode,
        const IncomeRule(type: 'A', shift: 1).hashCode,
      );
      expect(
        const IncomeRule(type: 'A', shift: 1).copyWith(shift: 2).shift,
        2,
      );
      expect(const IncomeRule(type: 'A', shift: 1).toString(), contains('A'));
    });
  });

  group('enum tarjimalari', () {
    test("to'lov usuli", () {
      expect(PaymentMethod.fromWire('card'), PaymentMethod.card);
      expect(PaymentMethod.fromWire('cash'), PaymentMethod.cash);
      expect(PaymentMethod.fromLegacy('Karta'), PaymentMethod.card);
      expect(PaymentMethod.fromLegacy('naqd'), PaymentMethod.cash);
      expect(PaymentMethod.fromWire(null), PaymentMethod.cash);
      expect(PaymentMethod.card.legacyLabel, 'Karta');
    });

    test('holat', () {
      expect(PaymentStatus.fromWire('paid'), PaymentStatus.paid);
      expect(PaymentStatus.fromWire('pending'), PaymentStatus.pending);
      expect(PaymentStatus.fromWire('overdue'), PaymentStatus.overdue);
      expect(PaymentStatus.fromWire('x'), PaymentStatus.none);
      expect(PaymentStatus.overdue.isUnpaid, isTrue);
      expect(PaymentStatus.paid.isUnpaid, isFalse);
    });

    test('boshqa enumlar', () {
      expect(MonthKeySource.fromWire('manual'), MonthKeySource.manual);
      expect(MonthKeySource.fromWire(null), MonthKeySource.auto);
      expect(DebtDirection.fromWire('owedToMe'), DebtDirection.owedToMe);
      expect(DebtDirection.fromWire('iOwe'), DebtDirection.iOwe);
      expect(
        DebtDirection.fromLegacy('Menga qarzdor'),
        DebtDirection.owedToMe,
      );
      expect(DebtDirection.fromLegacy('Men qarzdorman'), DebtDirection.iOwe);
      expect(PersonalFundMode.fromWire('fixed'), PersonalFundMode.fixed);
      expect(PersonalFundMode.fromLegacy('Foiz'), PersonalFundMode.percent);
      expect(
        PersonalFundMode.fromLegacy("Qat'iy summa"),
        PersonalFundMode.fixed,
      );
      expect(EntrySource.fromWire('sms'), EntrySource.sms);
      expect(EntrySource.fromWire("yo'q"), EntrySource.manual);
      expect(CategoryKind.fromWire('income'), CategoryKind.income);
    });
  });

  group('xatolar', () {
    test('kod va matn', () {
      const failure = ValidationFailure('summa', 'Musbat son kiriting');
      expect(failure.code, 'validation.summa');
      expect(failure.toString(), contains('Musbat son kiriting'));
      expect(const MonthClosedFailure('2026-09').code, 'month_closed');
      expect(const NotFoundFailure('x').code, 'not_found');
      expect(const ConflictFailure('band').code, 'conflict');
    });

    test('validatorlar', () {
      expect(Validate.text('  Non  ', 'nom'), 'Non');
      expect(Validate.optionalText('   '), isNull);
      expect(Validate.optionalText(' a '), 'a');
      expect(Validate.amount(Money.zero, 'reja'), Money.zero);
      expect(Validate.day(15, 'kun'), 15);
      expect(() => Validate.day(0, 'kun'), throwsA(isA<ValidationFailure>()));
      expect(
        () => Validate.amount(const Money(-1), 'reja'),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => Validate.positiveAmount(null, 'summa'),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('sana yordamchilari', () {
    test('kun aniqligida solishtirish', () {
      final morning = DateTime(2026, 9, 16, 8);
      final evening = DateTime(2026, 9, 16, 22);
      expect(isSameDay(morning, evening), isTrue);
      expect(isDayBefore(morning, evening), isFalse);
      expect(isDayAfter(evening, morning), isFalse);
      expect(dateOnly(evening), DateTime(2026, 9, 16));
      expect(daysBetween(DateTime(2026, 9, 20), morning), 4);
    });

    test('nomlarni normallashtirish', () {
      expect(normalizeKey('  Oziq-Ovqat '), 'oziq-ovqat');
      expect(isBlank('   '), isTrue);
      expect(isBlank(null), isTrue);
      expect(isBlank('a'), isFalse);
    });
  });
}
