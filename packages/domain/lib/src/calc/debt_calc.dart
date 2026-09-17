import 'package:meta/meta.dart';

import '../entities/debt.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// Qarzning hisoblangan ko'rinishi.
@immutable
final class DebtView {
  const DebtView({
    required this.debt,
    required this.applied,
    required this.remaining,
    required this.monthsLeft,
    required this.finishMonth,
  });

  final Debt debt;

  /// Ilova orqali qoplangan summa (yo'nalishga mos hisoblagich).
  final Money applied;

  /// Qolgan summa.
  final Money remaining;

  /// Necha oyda tugaydi (oylik to'lov ko'rsatilgan bo'lsa).
  final int monthsLeft;

  /// Taxminiy tugash oyi.
  final MonthKey? finishMonth;

  /// Jami to'langan = oldin to'langan + ilovadan.
  Money get paid => debt.paidBefore + applied;

  /// Bog'langan, lekin hali to'lanmagan rejalar — qarzni KAMAYTIRMAYDI,
  /// alohida ko'rsatiladi (§2.7).
  Money get pending => debt.pendingFromApp;

  bool get isClosed => remaining.isZero;

  /// 0..1 oralig'idagi progress.
  double get progress {
    if (!debt.total.isPositive) return 0;
    final ratio = paid.soum / debt.total.soum;
    return ratio.clamp(0.0, 1.0);
  }

  @override
  String toString() => 'DebtView(${debt.name}, qolgan: $remaining)';
}

/// Barcha qarzlar bo'yicha yakun.
@immutable
final class DebtTotals {
  const DebtTotals({
    this.iOwe = Money.zero,
    this.owedToMe = Money.zero,
    this.monthlyTotal = Money.zero,
    this.pending = Money.zero,
  });

  /// Men to'lashim kerak bo'lgan qolgan summa.
  final Money iOwe;

  /// Menga qaytarilishi kerak bo'lgan qolgan summa.
  final Money owedToMe;

  /// Aktiv qarzlarning oylik to'lovlari yig'indisi.
  final Money monthlyTotal;

  /// Bog'langan, to'lanmagan rejalar.
  final Money pending;

  /// Sof holat: menga qarzdor − men qarzdorman.
  Money get net => owedToMe - iOwe;
}

/// §2.7 — qarzlarni hisoblash.
///
/// ```
/// ilovadan = menQarzdorman ? Σ(bog'langan XARAJAT fakt)
///                          : Σ(bog'langan DAROMAD summa)
/// qolgan   = max(0, umumiy − oldinTolangan − ilovadan)
/// qolganOy = oylik > 0 ? ceil(qolgan / oylik) : 0
/// ```
/// Bog'lanish faqat `debtId` orqali — nom bo'yicha taxmin qilinmaydi.
abstract final class DebtCalc {
  static DebtView view(Debt debt, {required DateTime today}) {
    final applied = debt.appliedFromApp;
    final remaining = (debt.total - debt.paidBefore - applied).clampedToZero;
    final monthsLeft = debt.monthly.isPositive && remaining.isPositive
        ? (remaining.soum / debt.monthly.soum).ceil()
        : 0;
    return DebtView(
      debt: debt,
      applied: applied,
      remaining: remaining,
      monthsLeft: monthsLeft,
      finishMonth:
          monthsLeft > 0 ? MonthKey.of(today).shift(monthsLeft) : null,
    );
  }

  static List<DebtView> views(
    Iterable<Debt> debts, {
    required DateTime today,
  }) =>
      <DebtView>[
        for (final debt in debts)
          if (!debt.archived) view(debt, today: today),
      ];

  static DebtTotals totals(Iterable<DebtView> views) {
    var iOwe = Money.zero;
    var owedToMe = Money.zero;
    var monthlyTotal = Money.zero;
    var pending = Money.zero;
    for (final view in views) {
      pending += view.pending;
      if (view.debt.isMine) {
        iOwe += view.remaining;
        if (view.remaining.isPositive) monthlyTotal += view.debt.monthly;
      } else {
        owedToMe += view.remaining;
      }
    }
    return DebtTotals(
      iOwe: iOwe,
      owedToMe: owedToMe,
      monthlyTotal: monthlyTotal,
      pending: pending,
    );
  }
}
