import 'package:meta/meta.dart';

import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/name_key.dart';
import 'entity_support.dart';

/// Doimiy (har oylik) xarajat shabloni — `settings/recurring/{id}`.
///
/// [amount] `null` bo'lsa: "summasi har oy o'zgaradi" — yangi oy ochilganda
/// reja bo'sh qoladi va foydalanuvchi qo'lda kiritadi (§2.11).
@immutable
final class RecurringExpense {
  const RecurringExpense({
    required this.id,
    required this.name,
    required this.category,
    required this.method,
    required this.day,
    this.amount,
    this.autoPay = false,
    this.active = true,
    this.debtId,
    this.order = 0,
  });

  final String id;
  final String name;
  final String category;
  final Money? amount;
  final PaymentMethod method;

  /// To'lov kuni (1..31); oy qisqa bo'lsa oxirgi kunga qisiladi.
  final int day;
  final bool autoPay;
  final bool active;
  final String? debtId;
  final int order;

  String get nameKey => normalizeKey(name);

  RecurringExpense copyWith({
    String? id,
    String? name,
    String? category,
    Object? amount = unchanged,
    PaymentMethod? method,
    int? day,
    bool? autoPay,
    bool? active,
    Object? debtId = unchanged,
    int? order,
  }) =>
      RecurringExpense(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        amount: orKeep(amount, this.amount),
        method: method ?? this.method,
        day: day ?? this.day,
        autoPay: autoPay ?? this.autoPay,
        active: active ?? this.active,
        debtId: orKeep(debtId, this.debtId),
        order: order ?? this.order,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringExpense &&
          other.id == id &&
          other.name == name &&
          other.category == category &&
          other.amount == amount &&
          other.method == method &&
          other.day == day &&
          other.autoPay == autoPay &&
          other.active == active &&
          other.debtId == debtId &&
          other.order == order;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        amount,
        method,
        day,
        autoPay,
        active,
        debtId,
        order,
      );

  @override
  String toString() => 'RecurringExpense($id, $name, $amount)';
}

/// Kategoriya limiti — `settings/limits/{id}`.
@immutable
final class CategoryLimit {
  const CategoryLimit({
    required this.id,
    required this.category,
    required this.monthlyLimit,
  });

  final String id;
  final String category;
  final Money monthlyLimit;

  String get categoryKey => normalizeKey(category);

  CategoryLimit copyWith({
    String? id,
    String? category,
    Money? monthlyLimit,
  }) =>
      CategoryLimit(
        id: id ?? this.id,
        category: category ?? this.category,
        monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryLimit &&
          other.id == id &&
          other.category == category &&
          other.monthlyLimit == monthlyLimit;

  @override
  int get hashCode => Object.hash(id, category, monthlyLimit);
}

/// Tez qo'shish tugmasi — `settings/quickAdd/{id}`.
@immutable
final class QuickAdd {
  const QuickAdd({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.method,
    this.order = 0,
  });

  final String id;
  final String name;
  final Money amount;
  final String category;
  final PaymentMethod method;
  final int order;

  QuickAdd copyWith({
    String? id,
    String? name,
    Money? amount,
    String? category,
    PaymentMethod? method,
    int? order,
  }) =>
      QuickAdd(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        method: method ?? this.method,
        order: order ?? this.order,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickAdd &&
          other.id == id &&
          other.name == name &&
          other.amount == amount &&
          other.category == category &&
          other.method == method &&
          other.order == order;

  @override
  int get hashCode => Object.hash(id, name, amount, category, method, order);
}

/// Kategoriya turi.
enum CategoryKind {
  expense('expense'),
  income('income');

  const CategoryKind(this.wire);

  final String wire;

  static CategoryKind fromWire(Object? raw) =>
      raw == 'income' ? CategoryKind.income : CategoryKind.expense;
}

/// Kategoriya ma'lumotnomasi — `settings/categories/{id}`.
///
/// [parentId] kelajakdagi ierarxiya uchun (§15) — agregatdagi `byCategory`
/// kaliti o'zgarmaydi.
@immutable
final class CategoryDef {
  const CategoryDef({
    required this.id,
    required this.name,
    this.kind = CategoryKind.expense,
    this.icon = '',
    this.color = 0,
    this.order = 0,
    this.parentId,
    this.archived = false,
  });

  final String id;
  final String name;
  final CategoryKind kind;
  final String icon;

  /// ARGB rang kodi; `0` — tema rangi ishlatiladi.
  final int color;
  final int order;
  final String? parentId;
  final bool archived;

  String get nameKey => normalizeKey(name);

  CategoryDef copyWith({
    String? id,
    String? name,
    CategoryKind? kind,
    String? icon,
    int? color,
    int? order,
    Object? parentId = unchanged,
    bool? archived,
  }) =>
      CategoryDef(
        id: id ?? this.id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        order: order ?? this.order,
        parentId: orKeep(parentId, this.parentId),
        archived: archived ?? this.archived,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDef &&
          other.id == id &&
          other.name == name &&
          other.kind == kind &&
          other.icon == icon &&
          other.color == color &&
          other.order == order &&
          other.parentId == parentId &&
          other.archived == archived;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        kind,
        icon,
        color,
        order,
        parentId,
        archived,
      );
}
