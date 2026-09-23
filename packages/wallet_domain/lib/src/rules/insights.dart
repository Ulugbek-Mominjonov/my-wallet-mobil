import 'package:meta/meta.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

// E32 (server `report_insights` bilan bir xil qoidalar): kategoriya sakrashi
// va takrorlanuvchi to'lovlar. Kirish — lokal agregatlar, chiqish — ro'yxat.

/// Oxirgi 3 oy o'rtachasidan shu foizdan ko'p oshsa — "sakrash".
const spikeThresholdPercent = 30;

/// O'rtacha necha oy bo'yicha olinadi.
const spikeAverageMonths = 3;

/// Obuna: oxirgi 6 oyning kamida 3 tasida bir xil nom va summa.
const subscriptionWindowMonths = 6;
const subscriptionMinMonths = 3;

/// Kategoriya sakrashi (BR-095 ma'nosida): shu oy fakti va oldingi
/// [spikeAverageMonths] oy o'rtachasi.
@immutable
final class CategorySpike {
  const new({
    required this.categoryId,
    required this.name,
    required this.actual,
    required this.average,
  });

  final String categoryId;
  final String name;
  final Money actual;
  final Money average;

  /// O'rtachadan necha foiz ko'p (butun songa yaxlitlangan).
  int get deltaPercent =>
      roundDiv((actual.minor - average.minor) * 100, average.minor);

  Money get delta => actual - average;
}

/// Takrorlanuvchi to'lov (obuna): bir xil nom va summa bir necha oyda.
@immutable
final class Subscription {
  const new({
    required this.payee,
    required this.amount,
    required this.months,
    required this.lastMonth,
  });

  final String payee;
  final Money amount;

  /// Necha oyda uchradi (oxirgi olti oy ichida — `subscriptionWindowMonths`).
  final int months;
  final MonthKey lastMonth;
}

/// Sakragan kategoriyalar — kamayish tartibida (farq bo'yicha).
/// [current] — shu oy fakti, [previousTotal] — oldingi uch oy yig'indisi
/// (ikkalasi ham subkategoriyalar bilan, BR-132).
List<CategorySpike> categorySpikes({
  required Map<String, ({String name, Money actual})> current,
  required Map<String, Money> previousTotal,
  int limit = 5,
}) {
  final spikes = <CategorySpike>[];
  for (final MapEntry(key: id, value: line) in current.entries) {
    final total = previousTotal[id];
    if (total == null || !total.isPositive) continue;
    final average = Money(
      roundDiv(total.minor, spikeAverageMonths),
      total.currency,
    );
    if (!average.isPositive) continue;
    final spike = CategorySpike(
      categoryId: id,
      name: line.name,
      actual: line.actual,
      average: average,
    );
    if (spike.deltaPercent >= spikeThresholdPercent) spikes.add(spike);
  }
  spikes.sort((a, b) => b.delta.minor.compareTo(a.delta.minor));
  return spikes.take(limit).toList();
}

/// Obunalar — summasi bo'yicha kamayish tartibida. [payments] — oxirgi
/// olti oydagi xarajatlar (nom, summa, oy).
List<Subscription> subscriptions(
  Iterable<({String payee, Money amount, MonthKey month})> payments, {
  int limit = 10,
}) {
  final groups =
      <String, ({String payee, Money amount, Set<MonthKey> months})>{};
  for (final payment in payments) {
    final payee = payment.payee.trim();
    if (payee.isEmpty || !payment.amount.isPositive) continue;
    final key = '${payee.toLowerCase()}|${payment.amount.minor}';
    final group = groups[key];
    if (group == null) {
      groups[key] = (
        payee: payee,
        amount: payment.amount,
        months: {payment.month},
      );
    } else {
      group.months.add(payment.month);
    }
  }
  final found = [
    for (final group in groups.values)
      if (group.months.length >= subscriptionMinMonths)
        Subscription(
          payee: group.payee,
          amount: group.amount,
          months: group.months.length,
          lastMonth: group.months.reduce((a, b) => a.isAfter(b) ? a : b),
        ),
  ]..sort((a, b) => b.amount.minor.compareTo(a.amount.minor));
  return found.take(limit).toList();
}
