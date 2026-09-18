import 'package:meta/meta.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// BR-090: bitta oyning yig'indilari — serverdagi `private.month_facts` bilan
/// bir xil ma'no (mobil — lokal SQLite agregatidan). Hammasi asosiy valyutada.
///
/// * `income` — byudjet daromadlari (fondga daromad yo'q, BR-063);
/// * `expense` — byudjet xarajatlari + fondga ajratmalar (BR-061);
/// * `allocated` — fondga ajratmalar (fonddan qaytish — manfiy);
/// * `fundSpent` — fond hisobidan xarajatlar (byudjetga ta'sir qilmaydi);
/// * `planned` / `unpaid` / `unknownCount` — xarajat va ajratma rejalari
///   (o'tkazilgan va daromad rejalari kirmaydi; BR-076).
@immutable
final class MonthFacts {
  const new({
    required this.month,
    this.income = Money.zero,
    this.incomeCard = Money.zero,
    this.incomeCash = Money.zero,
    this.expense = Money.zero,
    this.expenseCard = Money.zero,
    this.expenseCash = Money.zero,
    this.allocated = Money.zero,
    this.fundSpent = Money.zero,
    this.planned = Money.zero,
    this.unpaid = Money.zero,
    this.unknownCount = 0,
    this.hasRecords = false,
  });

  final MonthKey month;
  final Money income;
  final Money incomeCard;
  final Money incomeCash;
  final Money expense;
  final Money expenseCard;
  final Money expenseCash;
  final Money allocated;
  final Money fundSpent;
  final Money planned;
  final Money unpaid;
  final int unknownCount;

  /// BR-092: "yozuvi bor oy" (amal yoki reja bor).
  final bool hasRecords;

  /// 💰 Qoldiq (BR-091).
  Money get balance => income - expense;

  @override
  bool operator ==(Object other) =>
      other is MonthFacts &&
      other.month == month &&
      other.income == income &&
      other.incomeCard == incomeCard &&
      other.incomeCash == incomeCash &&
      other.expense == expense &&
      other.expenseCard == expenseCard &&
      other.expenseCash == expenseCash &&
      other.allocated == allocated &&
      other.fundSpent == fundSpent &&
      other.planned == planned &&
      other.unpaid == unpaid &&
      other.unknownCount == unknownCount &&
      other.hasRecords == hasRecords;

  @override
  int get hashCode => Object.hash(
    month,
    income,
    incomeCard,
    incomeCash,
    expense,
    expenseCard,
    expenseCash,
    allocated,
    fundSpent,
    planned,
    unpaid,
    unknownCount,
    hasRecords,
  );

  @override
  String toString() =>
      'MonthFacts($month, income: $income, expense: $expense, '
      'allocated: $allocated, fundSpent: $fundSpent, unpaid: $unpaid)';
}
