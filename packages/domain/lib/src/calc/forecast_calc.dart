import 'package:meta/meta.dart';

import '../entities/month_summary.dart';
import '../entities/overall_totals.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// Oy oxirigacha prognoz.
@immutable
final class MonthForecast {
  const MonthForecast({
    required this.isCurrentMonth,
    required this.daysPassed,
    required this.daysInMonth,
    required this.dailyBurn,
    required this.monthEndSpend,
    required this.expectedIncome,
    required this.monthEndBalance,
    required this.averageExpense,
  });

  final bool isCurrentMonth;
  final int daysPassed;
  final int daysInMonth;

  /// Kunlik o'rtacha sarf.
  final Money dailyBurn;

  /// Shu sur'atda oy oxirigacha qancha sarflanadi.
  final Money monthEndSpend;

  /// Oy oxirigacha kutilayotgan daromad.
  final Money expectedIncome;

  /// Oy oxiridagi taxminiy qoldiq.
  final Money monthEndBalance;

  /// Barcha oylar bo'yicha o'rtacha xarajat.
  final Money averageExpense;

  /// Hali kelmagan daromad kutilyaptimi?
  bool get isIncomePending => isCurrentMonth && expectedIncome > monthEndSpend;

  @override
  String toString() =>
      'MonthForecast(kunlik: $dailyBurn, oy oxiri: $monthEndBalance)';
}

/// §2.9 — prognoz.
///
/// Daromad oy davomida bo'lib tushadi (oylik 1–3, KPI 5–8, avans 15–17),
/// shuning uchun joriy oyda "hali kelmagan daromad" o'rtachaga qarab
/// kutiladi — aks holda oyning boshida qoldiq doim manfiy ko'rinardi.
abstract final class ForecastCalc {
  static MonthForecast compute({
    required MonthSummary month,
    required OverallTotals totals,
    required int monthCount,
    required DateTime today,
  }) {
    final daysInMonth = month.monthKey.daysInMonth;
    final isCurrent = month.monthKey == MonthKey.of(today);
    final daysPassed =
        isCurrent ? today.day.clamp(1, daysInMonth) : daysInMonth;
    final dailyRate = daysPassed > 0 ? month.expense.soum / daysPassed : 0.0;
    final monthEndSpend = isCurrent
        ? Money((dailyRate * daysInMonth).round())
        : month.expense;

    final otherMonths = (monthCount - (isCurrent ? 1 : 0)).clamp(0, 1 << 30);
    final averageIncome = otherMonths > 0
        ? Money(
            ((totals.income - (isCurrent ? month.income : Money.zero)).soum /
                    otherMonths)
                .round(),
          )
        : Money.zero;
    final expectedIncome = isCurrent
        ? Money(
            month.income.soum > averageIncome.soum
                ? month.income.soum
                : averageIncome.soum,
          )
        : month.income;

    return MonthForecast(
      isCurrentMonth: isCurrent,
      daysPassed: daysPassed,
      daysInMonth: daysInMonth,
      dailyBurn: Money(dailyRate.round()),
      monthEndSpend: monthEndSpend,
      expectedIncome: expectedIncome,
      monthEndBalance: expectedIncome - monthEndSpend,
      averageExpense: monthCount > 0
          ? Money((totals.expense.soum / monthCount).round())
          : Money.zero,
    );
  }
}
