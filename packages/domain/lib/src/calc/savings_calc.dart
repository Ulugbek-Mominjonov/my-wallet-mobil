import 'package:meta/meta.dart';

import '../entities/month_summary.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// Bitta oyning jamg'armadagi o'rni.
@immutable
final class SavingsPoint {
  const SavingsPoint({
    required this.monthKey,
    required this.income,
    required this.expense,
    required this.balance,
    required this.saved,
    required this.cumulative,
  });

  final MonthKey monthKey;
  final Money income;
  final Money expense;

  /// Shu oy qoldig'i.
  final Money balance;

  /// Shu oyda orttirilgan (qoldiq + ajratma − shaxsiy sarf).
  final Money saved;

  /// Shu oygacha (shu oy ham kiritilgan) to'plangan jami.
  final Money cumulative;

  @override
  String toString() => 'SavingsPoint($monthKey, $balance, Σ$cumulative)';
}

/// 🏦 Jamg'armaning to'planish qatori.
@immutable
final class SavingsSeries {
  const SavingsSeries({
    required this.points,
    required this.total,
    required this.totalSaved,
    required this.averageSaved,
  });

  static const SavingsSeries empty = SavingsSeries(
    points: <SavingsPoint>[],
    total: Money.zero,
    totalSaved: Money.zero,
    averageSaved: Money.zero,
  );

  final List<SavingsPoint> points;

  /// Umumiy jamg'arma qoldig'i = Σ(oylik qoldiq).
  final Money total;

  /// Umumiy orttirgan.
  final Money totalSaved;

  /// O'rtacha oylik orttirish — maqsadlar prognozi uchun (`umumiy.ortacha`).
  final Money averageSaved;

  int get monthCount => points.length;

  MonthKey? get firstMonth => points.isEmpty ? null : points.first.monthKey;

  MonthKey? get lastMonth => points.isEmpty ? null : points.last.monthKey;
}

/// §2.5 — jamg'arma xronologik to'planadi.
///
/// `toplangan[i] = toplangan[i-1] + qoldiq[oy_i]`
///
/// Bu qiymat Firestore'da SAQLANMAYDI: bir oy o'zgarsa keyingi barcha
/// oylarni qayta yozish kerak bo'lardi. Oy hujjatlari kam (yiliga 12 ta),
/// shuning uchun klientda prefix-sum arzon.
abstract final class SavingsCalc {
  static SavingsSeries build(Iterable<MonthSummary> months) {
    final sorted = months.toList()
      ..sort((a, b) => a.monthKey.compareTo(b.monthKey));
    if (sorted.isEmpty) return SavingsSeries.empty;

    final points = <SavingsPoint>[];
    var cumulative = Money.zero;
    var totalSaved = Money.zero;
    for (final month in sorted) {
      cumulative += month.balance;
      totalSaved += month.saved;
      points.add(
        SavingsPoint(
          monthKey: month.monthKey,
          income: month.income,
          expense: month.expense,
          balance: month.balance,
          saved: month.saved,
          cumulative: cumulative,
        ),
      );
    }
    return SavingsSeries(
      points: points,
      total: cumulative,
      totalSaved: totalSaved,
      averageSaved: Money((totalSaved.soum / points.length).round()),
    );
  }
}
