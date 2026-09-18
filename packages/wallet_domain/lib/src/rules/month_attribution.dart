import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// BR-040..046: amalning tegishli oyi (qaysi oyning byudjetiga). Tartib
/// serverdagi `validate_transaction` bilan bir xil:
///
/// 1. qo'lda tanlangan oy ([manualMonth], BR-041, BR-042);
/// 2. rejaga bog'langan — reja oyi ([plannedMonth], BR-044, BR-046);
/// 3. daromad — sana oyi + kategoriya siljishi ([incomeShift], BR-040);
/// 4. xarajat va o'tkazma — sana oyi (BR-041, BR-046).
///
/// Mobil natija — taxmin: sinxronda server qaytargan kanonik oy yoziladi.
MonthKey attributeBudgetMonth({
  required TransactionKind kind,
  required LocalDate occurredOn,
  MonthKey? manualMonth,
  MonthKey? plannedMonth,
  int incomeShift = 0,
}) {
  if (manualMonth != null) return manualMonth;
  if (plannedMonth != null) return plannedMonth;
  final month = occurredOn.monthKey;
  return kind == TransactionKind.income ? month.shift(incomeShift) : month;
}
