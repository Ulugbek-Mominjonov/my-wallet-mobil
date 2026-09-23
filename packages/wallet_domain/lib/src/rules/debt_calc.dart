import 'package:meta/meta.dart';
import 'package:wallet_domain/src/entities/debt.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/rules/fx.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// BR-116: qarz holati.
enum DebtStatus { closed, paying, pending, unlinked }

/// BR-112, BR-113: qarz hisobi (serverdagi `debt_balances` view'i).
@immutable
final class DebtProgress {
  /// [paidInApp] — bog'langan tirik amallar summasi (qarz valyutasida),
  /// [pendingAmount] / [pendingCount] — bog'langan, to'lanmagan rejalar
  /// (BR-113: qarzni kamaytirmaydi, alohida ko'rsatiladi).
  factory of(
    Debt debt, {
    required Money paidInApp,
    required int paymentCount,
    required Money pendingAmount,
    required int pendingCount,
    required MonthKey currentMonth,
  }) {
    final left = debt.total - debt.paidBefore - paidInApp;
    final remaining = left.isNegative ? Money(0, left.currency) : left;
    final monthly = debt.monthlyPayment;
    final monthsLeft =
        remaining.isPositive && monthly != null && monthly.isPositive
        ? _ceilDiv(remaining.minor, monthly.minor)
        : null;
    final paid = (debt.paidBefore + paidInApp).minor;
    return DebtProgress._(
      paidInApp: paidInApp,
      pendingAmount: pendingAmount,
      pendingCount: pendingCount,
      remaining: remaining,
      progress: paid >= debt.total.minor ? 1 : ratio4(paid, debt.total.minor),
      monthsLeft: monthsLeft,
      endMonth: monthsLeft == null ? null : currentMonth.shift(monthsLeft),
      status: remaining.isZero
          ? DebtStatus.closed
          : paymentCount > 0
          ? DebtStatus.paying
          : pendingCount > 0
          ? DebtStatus.pending
          : DebtStatus.unlinked,
    );
  }

  const new _({
    required this.paidInApp,
    required this.pendingAmount,
    required this.pendingCount,
    required this.remaining,
    required this.progress,
    required this.monthsLeft,
    required this.endMonth,
    required this.status,
  });

  final Money paidInApp;
  final Money pendingAmount;
  final int pendingCount;

  /// max(0, umumiy − oldin to'langan − ilovadan).
  final Money remaining;

  /// min(1, (oldin to'langan + ilovadan) ÷ umumiy), 4 xona.
  final double progress;

  /// ceil(qolgan ÷ oylik) — oylik to'lov bo'lmasa null.
  final int? monthsLeft;

  /// Tugash oyi = joriy oy + qolgan oylar.
  final MonthKey? endMonth;
  final DebtStatus status;
}

/// BR-114, BR-194: jamlar — arxivlanmagan qarzlar, asosiy valyutadagi
/// ekvivalentda. Kursi yo'q qarz jamga kirmaydi (0 deb hisoblanmaydi).
@immutable
final class DebtTotals {
  /// [paidThisMonth] — shu oyda qarzga bog'langan amallar (asosiy valyutada).
  /// [toBase] — boshqa valyutadagi summani o'tkazadi (BR-194); berilmasa
  /// faqat asosiy valyutadagi qarzlar hisobga olinadi.
  factory of(
    Iterable<(Debt, DebtProgress)> debts, {
    required Currency baseCurrency,
    required Money paidThisMonth,
    ToBaseAmount? toBase,
  }) {
    var iOwe = Money(0, baseCurrency);
    var owedToMe = Money(0, baseCurrency);
    var monthly = Money(0, baseCurrency);
    Money? inBase(Money? amount) => switch (amount) {
      null => null,
      _ when amount.currency == baseCurrency => amount,
      _ => toBase?.call(amount),
    };
    for (final (debt, progress) in debts) {
      if (debt.archivedAt != null) continue;
      final remaining = inBase(progress.remaining);
      if (remaining == null) continue;
      switch (debt.direction) {
        case DebtDirection.iOwe:
          iOwe += remaining;
          if (progress.remaining.isPositive && debt.monthlyPayment != null) {
            monthly += inBase(debt.monthlyPayment) ?? Money(0, baseCurrency);
          }
        case DebtDirection.owedToMe:
          owedToMe += remaining;
      }
    }
    return DebtTotals._(
      iOwe: iOwe,
      owedToMe: owedToMe,
      monthlyObligation: monthly,
      paidThisMonth: paidThisMonth,
    );
  }

  const new _({
    required this.iOwe,
    required this.owedToMe,
    required this.monthlyObligation,
    required this.paidThisMonth,
  });

  final Money iOwe;
  final Money owedToMe;
  final Money monthlyObligation;
  final Money paidThisMonth;

  /// ⚖️ Sof holat = menga qarzdor − men qarzdorman.
  Money get net => owedToMe - iOwe;
}

int _ceilDiv(int numerator, int denominator) =>
    (numerator + denominator - 1) ~/ denominator;
