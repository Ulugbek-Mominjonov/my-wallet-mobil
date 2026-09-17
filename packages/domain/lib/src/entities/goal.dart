import 'package:meta/meta.dart';

import '../value_objects/money.dart';
import 'entity_support.dart';

/// 🎯 To'planish maqsadi.
@immutable
final class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.target,
    this.saved = Money.zero,
    this.monthly,
    this.deadline,
    this.note = '',
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;

  /// Kerakli summa.
  final Money target;

  /// Yig'ilgan summa.
  final Money saved;

  /// Oyiga ajratma; `null` bo'lsa o'rtacha orttirish ishlatiladi (§2.8).
  final Money? monthly;
  final DateTime? deadline;
  final String note;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Goal copyWith({
    String? id,
    String? name,
    Money? target,
    Money? saved,
    Object? monthly = unchanged,
    Object? deadline = unchanged,
    String? note,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Goal(
        id: id ?? this.id,
        name: name ?? this.name,
        target: target ?? this.target,
        saved: saved ?? this.saved,
        monthly: orKeep(monthly, this.monthly),
        deadline: orKeep(deadline, this.deadline),
        note: note ?? this.note,
        order: order ?? this.order,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          other.id == id &&
          other.name == name &&
          other.target == target &&
          other.saved == saved &&
          other.monthly == monthly &&
          other.deadline == deadline &&
          other.note == note &&
          other.order == order;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        target,
        saved,
        monthly,
        deadline,
        note,
        order,
      );

  @override
  String toString() => 'Goal($id, $name, $saved/$target)';
}
