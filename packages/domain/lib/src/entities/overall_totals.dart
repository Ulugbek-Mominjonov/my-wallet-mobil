import 'package:meta/meta.dart';

import '../value_objects/money.dart';
import 'entity_support.dart';

/// ★ Global agregat — `meta/totals` hujjati.
///
/// Faqat `increment` bilan xavfsiz yangilanadigan hisoblagichlar saqlanadi.
/// `savings`, `personalBalance`, `monthCount` kabi HOSILA qiymatlar
/// saqlanmaydi — ular shu yerda hisoblanadi yoki `months` ro'yxatidan
/// olinadi (bitta haqiqat manbai qoidasi).
@immutable
final class OverallTotals {
  const OverallTotals({
    this.income = Money.zero,
    this.expense = Money.zero,
    this.personalAllocated = Money.zero,
    this.personalSpent = Money.zero,
    this.updatedAt,
  });

  final Money income;
  final Money expense;
  final Money personalAllocated;
  final Money personalSpent;
  final DateTime? updatedAt;

  /// 🏦 Umumiy jamg'arma = Σ(oylik qoldiq) = daromad − xarajat.
  Money get savings => income - expense;

  /// 👤 Shaxsiy fond qoldig'i = ajratilgan − sarflangan.
  ///
  /// Bu qiymat [savings] bilan HECH QACHON qo'shilmaydi (§2.4).
  Money get personalBalance => personalAllocated - personalSpent;

  /// Umumiy orttirgan = qoldiq + ajratma − shaxsiy sarf.
  Money get saved => savings + personalAllocated - personalSpent;

  OverallTotals copyWith({
    Money? income,
    Money? expense,
    Money? personalAllocated,
    Money? personalSpent,
    Object? updatedAt = unchanged,
  }) =>
      OverallTotals(
        income: income ?? this.income,
        expense: expense ?? this.expense,
        personalAllocated: personalAllocated ?? this.personalAllocated,
        personalSpent: personalSpent ?? this.personalSpent,
        updatedAt: orKeep(updatedAt, this.updatedAt),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverallTotals &&
          other.income == income &&
          other.expense == expense &&
          other.personalAllocated == personalAllocated &&
          other.personalSpent == personalSpent;

  @override
  int get hashCode =>
      Object.hash(income, expense, personalAllocated, personalSpent);

  @override
  String toString() =>
      'OverallTotals(daromad: $income, xarajat: $expense, '
      'jamgarma: $savings, shaxsiy: $personalBalance)';
}
