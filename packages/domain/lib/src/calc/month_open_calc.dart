import 'package:meta/meta.dart';

import '../entities/catalog.dart';
import '../entities/expense.dart';
import '../entities/settings.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';
import 'payment_status_calc.dart';
import 'personal_fund_calc.dart';

/// Yangi oy ochish rejasi.
@immutable
final class MonthOpenPlan {
  const MonthOpenPlan({
    required this.month,
    required this.created,
    required this.skipped,
  });

  final MonthKey month;

  /// Yaratiladigan xarajat qatorlari.
  final List<Expense> created;

  /// Shu oyda allaqachon mavjud bo'lgani uchun o'tkazib yuborilgani.
  final int skipped;

  bool get isEmpty => created.isEmpty;

  @override
  String toString() =>
      "MonthOpenPlan($month, +${created.length}, o'tkazildi: $skipped)";
}

/// §2.11 — yangi oy ochish (`oyniTayyorla_`).
///
/// Doimiy xarajatlar + "O'zim uchun" ajratmasi yangi oyga ko'chiriladi.
/// **Idempotent:** shu nomdagi qator oyda bor bo'lsa — o'tkazib yuboriladi,
/// shuning uchun funksiyani necha marta chaqirsa ham takror yozuv paydo
/// bo'lmaydi (cron ham, foydalanuvchi ham chaqirishi mumkin).
abstract final class MonthOpenCalc {
  static MonthOpenPlan plan({
    required MonthKey month,
    required Iterable<RecurringExpense> recurring,
    required Iterable<Expense> existing,
    required BudgetSettings settings,
    required Money monthIncome,
    required DateTime now,
    required String Function() nextId,
  }) {
    final existingNames = <String>{};
    var hasPersonalRow = false;
    final personalKey = settings.app.personalCategoryKey;
    for (final expense in existing) {
      if (expense.monthKey != month) continue;
      existingNames.add(expense.nameKey);
      if (expense.categoryKey == personalKey) hasPersonalRow = true;
    }

    final created = <Expense>[];
    var skipped = 0;

    final templates = recurring.where((item) => item.active).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final template in templates) {
      if (existingNames.contains(template.nameKey)) {
        skipped++;
        continue;
      }
      created.add(
        _draft(
          id: nextId(),
          month: month,
          name: template.name,
          category: template.category,
          method: template.method,
          day: template.day,
          planned: template.amount,
          autoPay: template.autoPay,
          debtId: template.debtId,
          recurringId: template.id,
          now: now,
        ),
      );
      existingNames.add(template.nameKey);
    }

    if (hasPersonalRow) {
      skipped++;
    } else {
      final fund = settings.personalFund;
      created.add(
        _draft(
          id: nextId(),
          month: month,
          name: settings.app.personalRowName,
          category: settings.app.personalCategory,
          method: fund.method,
          day: fund.day,
          planned: PersonalFundCalc.plannedAmount(
            monthIncome: monthIncome,
            settings: fund,
          ),
          autoPay: false,
          debtId: null,
          recurringId: null,
          now: now,
        ),
      );
    }

    return MonthOpenPlan(month: month, created: created, skipped: skipped);
  }

  static Expense _draft({
    required String id,
    required MonthKey month,
    required String name,
    required String category,
    required PaymentMethod method,
    required int day,
    required Money? planned,
    required bool autoPay,
    required String? debtId,
    required String? recurringId,
    required DateTime now,
  }) {
    final dueDate = month.dayOf(day);
    return Expense(
      id: id,
      name: name,
      category: category,
      method: method,
      planned: planned,
      dueDate: dueDate,
      // To'lov sanasi keyingi oyga tushsa ham, qator OCHILGAN oyga tegishli
      // bo'lib qoladi — shuning uchun manba `manual`.
      monthKey: month,
      monthKeySource: MonthKeySource.manual,
      status: PaymentStatusCalc.compute(
        planned: planned,
        actual: null,
        dueDate: dueDate,
        today: now,
      ),
      debtId: debtId,
      recurringId: recurringId,
      autoPay: autoPay,
      source: EntrySource.recurring,
      createdAt: now,
      updatedAt: now,
    );
  }
}
