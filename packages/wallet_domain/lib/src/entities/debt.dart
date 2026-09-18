import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

part 'debt.freezed.dart';

/// BR-110..116: qarz — o'z valyutasida (BR-194).
@freezed
abstract class Debt with _$Debt {
  const factory({
    required String id,
    required String householdId,
    required String name,
    required DebtDirection direction,
    required Money total,

    /// Ilovadan tashqarida (oldin) to'langan qism.
    required Money paidBefore,
    Money? monthlyPayment,
    LocalDate? dueDate,
    String? note,
    DateTime? archivedAt,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _Debt;
}
