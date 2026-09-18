import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/value_objects/money.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

part 'recurring_rule.freezed.dart';

/// BR-080..083: doimiy reja — har oy ochilganda oy rejasi shu yerdan.
@freezed
abstract class RecurringRule with _$RecurringRule {
  const factory({
    required String id,
    required String householdId,
    required PlanKind kind,
    required String name,

    /// 1–31; qisqa oyda oxirgi kunga qisiladi (BR-080).
    required int dayOfMonth,
    String? categoryId,
    String? accountId,

    /// null — summa o'zgaruvchan (har oy kiritiladi).
    Money? amount,
    @Default(false) bool autoPay,
    @Default(true) bool active,
    String? debtId,
    MonthKey? startMonth,
    MonthKey? endMonth,
    @Default(0) int sortOrder,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _RecurringRule;

  const new _();

  /// [month] da amal qiladimi (faol, o'chirilmagan, davr ichida).
  bool appliesTo(MonthKey month) =>
      active &&
      deletedAt == null &&
      (startMonth == null || !startMonth!.isAfter(month)) &&
      (endMonth == null || !endMonth!.isBefore(month));
}
