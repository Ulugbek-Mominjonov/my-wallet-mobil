import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

part 'directory_items.freezed.dart';

/// BR-130..134: kategoriya limiti (asosiy valyutada); 80/100% ogohlantirish.
@freezed
abstract class CategoryLimit with _$CategoryLimit {
  const factory({
    required String id,
    required String householdId,
    required String categoryId,
    required Money amount,
    @Default(true) bool alert80,
    @Default(true) bool alert100,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _CategoryLimit;
}

/// BR-140..142: tez tugma — bir bosishda xarajat.
@freezed
abstract class QuickAction with _$QuickAction {
  const factory({
    required String id,
    required String householdId,
    required String name,
    required Money amount,
    required String categoryId,
    required String accountId,
    String? payee,
    @Default(0) int sortOrder,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _QuickAction;
}

/// BR-200: teg.
@freezed
abstract class Tag with _$Tag {
  const factory({
    required String id,
    required String householdId,
    required String name,
    String? color,
    DateTime? deletedAt,
    @Default(0) int rowVersion,
  }) = _Tag;
}
