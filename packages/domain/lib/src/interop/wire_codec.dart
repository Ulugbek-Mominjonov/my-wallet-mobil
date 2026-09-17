import '../calc/delta_calc.dart';
import '../entities/expense.dart';
import '../entities/income.dart';
import '../entities/month_summary.dart';
import '../entities/personal_spend.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// Dart va TypeScript IMPLEMENTATSIYALARI UCHUN UMUMIY sim formati.
///
/// `testdata/aggregate-cases.json` shu ko'rinishda yoziladi va ikkala
/// platforma ham aynan shu fayldan o'qiydi — shunda `packages/domain`
/// (Dart) va `packages/calc-ts` (TS) o'rtasida drift bo'lmaydi (§12.3).
///
/// Sanalar `YYYY-MM-DD` matni sifatida uzatiladi: JSON'da vaqt zonasi
/// muammosi bo'lmasligi uchun soat-minut umuman yo'q.
abstract final class WireCodec {
  static String dateToWire(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime dateFromWire(String value) {
    final parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static Map<String, Object?> incomeToWire(Income income) =>
      <String, Object?>{
        'id': income.id,
        'amount': income.amount.soum,
        'type': income.type,
        'method': income.method.wire,
        'paidAt': dateToWire(income.paidAt),
        'monthKey': income.monthKey.value,
        'debtId': income.debtId,
      };

  static Income incomeFromWire(Map<String, Object?> json) => Income(
        id: json['id']! as String,
        amount: Money(json['amount']! as int),
        type: json['type']! as String,
        method: PaymentMethod.fromWire(json['method']),
        paidAt: dateFromWire(json['paidAt']! as String),
        monthKey: MonthKey(json['monthKey']! as String),
        debtId: json['debtId'] as String?,
      );

  static Map<String, Object?> expenseToWire(Expense expense) =>
      <String, Object?>{
        'id': expense.id,
        'name': expense.name,
        'category': expense.category,
        'method': expense.method.wire,
        'planned': expense.planned?.soum,
        'actual': expense.actual?.soum,
        'dueDate': dateToWire(expense.dueDate),
        'monthKey': expense.monthKey.value,
        'monthKeySource': expense.monthKeySource.wire,
        'debtId': expense.debtId,
        'autoPay': expense.autoPay,
      };

  static Expense expenseFromWire(Map<String, Object?> json) => Expense(
        id: json['id']! as String,
        name: json['name']! as String,
        category: json['category']! as String,
        method: PaymentMethod.fromWire(json['method']),
        planned:
            json['planned'] == null ? null : Money(json['planned']! as int),
        actual: json['actual'] == null ? null : Money(json['actual']! as int),
        dueDate: dateFromWire(json['dueDate']! as String),
        monthKey: MonthKey(json['monthKey']! as String),
        monthKeySource: MonthKeySource.fromWire(json['monthKeySource']),
        debtId: json['debtId'] as String?,
        autoPay: json['autoPay'] as bool? ?? false,
      );

  static Map<String, Object?> spendToWire(PersonalSpend spend) =>
      <String, Object?>{
        'id': spend.id,
        'amount': spend.amount.soum,
        'purpose': spend.purpose,
        'method': spend.method.wire,
        'spentAt': dateToWire(spend.spentAt),
        'monthKey': spend.monthKey.value,
      };

  static PersonalSpend spendFromWire(Map<String, Object?> json) =>
      PersonalSpend(
        id: json['id']! as String,
        amount: Money(json['amount']! as int),
        purpose: json['purpose']! as String,
        method: PaymentMethod.fromWire(json['method']),
        spentAt: dateFromWire(json['spentAt']! as String),
        monthKey: MonthKey(json['monthKey']! as String),
      );

  /// Delta natijasini solishtirish uchun barqaror (saralangan) ko'rinish.
  static Map<String, Object?> deltaToWire(AggregateDelta delta) {
    final months = delta.months.keys.map((key) => key.value).toList()..sort();
    final debts = delta.debts.keys.toList()..sort();
    return <String, Object?>{
      'months': <String, Object?>{
        for (final month in months)
          month: delta.months[MonthKey(month)]!.toIncrements(),
      },
      'totals': delta.totals.toIncrements(),
      'debts': <String, Object?>{
        for (final debt in debts) debt: delta.debts[debt]!.toIncrements(),
      },
    };
  }

  /// Oy agregatining to'liq (hosila qiymatlari bilan) ko'rinishi.
  static Map<String, Object?> summaryToWire(MonthSummary summary) =>
      <String, Object?>{
        'monthKey': summary.monthKey.value,
        'income': summary.income.soum,
        'incomeCard': summary.incomeCard.soum,
        'incomeCash': summary.incomeCash.soum,
        'expense': summary.expense.soum,
        'expenseCard': summary.expenseCard.soum,
        'expenseCash': summary.expenseCash.soum,
        'planned': summary.planned.soum,
        'unpaidTotal': summary.unpaidTotal.soum,
        'unknownCount': summary.unknownCount,
        'personalAllocated': summary.personalAllocated.soum,
        'personalSpent': summary.personalSpent.soum,
        'byType': <String, Object?>{
          for (final key in summary.byType.keys.toList()..sort())
            key: <String, int>{
              'card': summary.byType[key]!.card.soum,
              'cash': summary.byType[key]!.cash.soum,
            },
        },
        'byCategory': <String, Object?>{
          for (final key in summary.byCategory.keys.toList()..sort())
            key: <String, int>{
              'planned': summary.byCategory[key]!.planned.soum,
              'actual': summary.byCategory[key]!.actual.soum,
            },
        },
        // Hosila qiymatlar — ikkala platformada bir xil chiqishi shart.
        'balance': summary.balance.soum,
        'forecast': summary.forecast.soum,
        'card': summary.card.soum,
        'cash': summary.cash.soum,
        'saved': summary.saved.soum,
      };
}
