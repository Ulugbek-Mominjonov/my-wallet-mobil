import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/household.dart';
import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// BR-060: oyning 👤 fond ajratmasi. Foiz rejimida — oy daromadidan, **bir
/// marta** yaxlitlanadi: `round(daromad × foiz / 100 / birlik) × birlik`
/// (serverdagi `private.fund_allocation_amount`); qat'iy rejimda — sozlamadagi
/// summa. Nol — reja yo'q (null).
Money? personalAllocation({
  required Money income,
  required PersonalFundRule rule,
}) {
  final amount = switch (rule.mode) {
    PersonalFundMode.percent => _percentOf(income, rule.percentBasisPoints),
    PersonalFundMode.fixed => rule.fixedAmount,
  };
  return amount.isZero ? null : amount;
}

/// Bazis punktlar: 10% = 1000 → `daromad × 1000 / 10000`.
const _basisPointsPerUnit = 10000;

Money _percentOf(Money income, int basisPoints) {
  final unit = income.currency.allocationUnit;
  final units = roundDiv(
    income.minor * basisPoints,
    _basisPointsPerUnit * unit,
  );
  return Money(units * unit, income.currency);
}
