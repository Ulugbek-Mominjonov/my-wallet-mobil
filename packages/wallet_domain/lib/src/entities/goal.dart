import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

part 'goal.freezed.dart';

/// BR-120..122: maqsad. Hisobga bog'langan bo'lsa yig'ilgan = hisob
/// qoldig'i, aks holda qo'lda kiritilgan (`savedManual`).
@freezed
abstract class Goal with _$Goal {
  const factory({
    required String id,
    required String householdId,
    required String name,
    required Money target,
    required Money savedManual,
    Money? monthlyContribution,
    MonthKey? deadline,
    String? accountId,
    @Default(0) int sortOrder,
    DateTime? achievedAt,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _Goal;
}
