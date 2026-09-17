import 'package:meta/meta.dart';

import '../entities/month_summary.dart';
import '../entities/overall_totals.dart';
import '../entities/settings.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';

/// 👤 Shaxsiy fondning holati.
@immutable
final class PersonalFundView {
  const PersonalFundView({
    required this.allocated,
    required this.spent,
  });

  /// Jami ajratilgan.
  final Money allocated;

  /// Jami sarflangan.
  final Money spent;

  /// Qoldiq = ajratilgan − sarflangan.
  ///
  /// Bu qiymat 🏦 jamg'arma bilan HECH QACHON qo'shilmaydi (§2.4).
  Money get balance => allocated - spent;

  double get usedRatio =>
      allocated.isPositive ? (spent.soum / allocated.soum).clamp(0.0, 1.0) : 0;

  @override
  String toString() => 'PersonalFundView(qoldiq: $balance)';
}

/// §2.10 — "O'zim uchun" rejasi va fond qoldig'i.
abstract final class PersonalFundCalc {
  /// Yaxlitlash qadami: 1000 so'm.
  static const int roundingStep = 1000;

  /// ```
  /// Foiz rejimi:  round(daromad × foiz / 100 / 1000) × 1000
  /// Qat'iy rejim: sozlamadagi summa
  /// ```
  /// Yaxlitlash BIR MARTA bajariladi — avval so'mgacha, keyin minggacha
  /// yaxlitlansa natija farq qilishi mumkin edi.
  static Money plannedAmount({
    required Money monthIncome,
    required PersonalFundSettings settings,
  }) {
    if (settings.mode == PersonalFundMode.fixed) {
      return Money(settings.value);
    }
    if (!monthIncome.isPositive || settings.value <= 0) return Money.zero;
    final raw = monthIncome.soum * settings.value / 100 / roundingStep;
    return Money(raw.round() * roundingStep);
  }

  /// Umumiy hisobdan fond holati.
  static PersonalFundView fromTotals(OverallTotals totals) =>
      PersonalFundView(
        allocated: totals.personalAllocated,
        spent: totals.personalSpent,
      );

  /// Bitta oy kesimidagi fond harakati.
  static PersonalFundView fromMonth(MonthSummary month) => PersonalFundView(
        allocated: month.personalAllocated,
        spent: month.personalSpent,
      );
}
