import 'package:wallet_domain/src/internal/rounding.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// BR-130: limit holati — < 80% ok, 80–100% near, > 100% over.
enum LimitStatus { ok, near, over }

/// Serverdagi `private.limit_status` bilan bir xil (kasrsiz: `fakt × 5 ≥
/// limit × 4`). Ota-kategoriya fakti — subkategoriyalari bilan (BR-132) —
/// chaqiruvchi yig'adi.
LimitStatus? limitStatus(Money actual, Money? limit) {
  if (limit == null) return null;
  if (actual > limit) return LimitStatus.over;
  if (actual.minor * 5 >= limit.minor * 4) return LimitStatus.near;
  return LimitStatus.ok;
}

/// Limitdan ulush (4 xona); limit yo'q yoki 0 — null.
double? limitRatio(Money actual, Money? limit) =>
    limit == null || !limit.isPositive
    ? null
    : ratio4(actual.minor, limit.minor);
