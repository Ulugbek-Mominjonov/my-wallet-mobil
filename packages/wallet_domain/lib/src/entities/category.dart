import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/entities/enums.dart';

part 'category.freezed.dart';

/// BR-030..036: kategoriya; subkategoriya — bir daraja (BR-034).
@freezed
abstract class Category with _$Category {
  const factory({
    required String id,
    required String householdId,
    required CategoryKind kind,
    required String name,
    String? parentId,

    /// BR-040: daromad oy siljishi (−1, 0, 1); xarajatda doim 0.
    @Default(0) int monthShift,
    String? icon,
    String? color,
    @Default(0) int sortOrder,
    SystemCode? systemCode,
    DateTime? archivedAt,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _Category;

  const new _();

  /// BR-033: "O'zim uchun" — fond ajratmalari shu yerda; o'chirilmaydi.
  bool get isSystem => systemCode != null;

  bool get isActive => archivedAt == null && deletedAt == null;
}
