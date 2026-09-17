import 'package:meta/meta.dart';

import '../entities/catalog.dart';
import '../entities/month_summary.dart';
import '../value_objects/money.dart';
import '../value_objects/name_key.dart';

/// Kategoriya limiti holati.
@immutable
final class LimitStatus {
  const LimitStatus({
    required this.category,
    required this.limit,
    required this.spent,
  });

  final String category;
  final Money limit;
  final Money spent;

  Money get remaining => (limit - spent).clampedToZero;

  double get ratio => limit.isPositive ? spent.soum / limit.soum : 0;

  bool get isExceeded => spent > limit;

  /// 80% dan oshgan, lekin hali oshib ketmagan.
  bool get isNearLimit => !isExceeded && ratio >= 0.8;

  @override
  String toString() => 'LimitStatus($category, $spent/$limit)';
}

/// Kategoriya limitlarini oy agregatiga solishtiradi.
///
/// Agregatdagi `byCategory` map'i tufayli QO'SHIMCHA SO'ROV KERAK EMAS —
/// denormalizatsiya ataylab qilingan (§5.4).
abstract final class LimitCalc {
  static List<LimitStatus> forMonth(
    MonthSummary month,
    Iterable<CategoryLimit> limits,
  ) {
    final spentByKey = <String, Money>{};
    for (final entry in month.byCategory.entries) {
      final key = normalizeKey(entry.key);
      spentByKey[key] = (spentByKey[key] ?? Money.zero) + entry.value.actual;
    }
    return <LimitStatus>[
      for (final limit in limits)
        if (limit.monthlyLimit.isPositive)
          LimitStatus(
            category: limit.category,
            limit: limit.monthlyLimit,
            spent: spentByKey[limit.categoryKey] ?? Money.zero,
          ),
    ];
  }

  /// Limitdan oshgan kategoriyalar — oylik hisobotdagi ogohlantirish uchun.
  static List<LimitStatus> exceeded(
    MonthSummary month,
    Iterable<CategoryLimit> limits,
  ) =>
      forMonth(month, limits).where((status) => status.isExceeded).toList();
}
