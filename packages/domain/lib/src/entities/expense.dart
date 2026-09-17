import 'package:meta/meta.dart';

import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';
import '../value_objects/name_key.dart';
import 'entity_support.dart';

/// Xarajat yozuvi — reja va fakt bitta qatorda.
///
/// [planned] `null` bo'lishi mumkin: "summasi har oy o'zgaradi" degani
/// (Sheets'dagi bo'sh "Reja" katagi). Bu holat aniq `Money.zero` dan
/// farq qiladi — nol reja umuman kuzatilmaydigan qator demak.
///
/// [actual] `null` yoki nol — to'lov hali qilinmagan.
@immutable
final class Expense {
  const Expense({
    required this.id,
    required this.name,
    required this.category,
    required this.method,
    required this.dueDate,
    required this.monthKey,
    this.planned,
    this.actual,
    this.monthKeySource = MonthKeySource.auto,
    this.status = PaymentStatus.pending,
    this.debtId,
    this.recurringId,
    this.autoPay = false,
    this.note = '',
    this.source = EntrySource.manual,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final PaymentMethod method;

  /// Kutilayotgan summa; `null` — summasi oldindan noma'lum.
  final Money? planned;

  /// Haqiqatda to'langan summa; `null`/nol — to'lanmagan.
  final Money? actual;
  final DateTime dueDate;

  /// Qaysi oy byudjetiga tegishli (§2.2).
  final MonthKey monthKey;
  final MonthKeySource monthKeySource;

  /// So'rov uchun saqlanadigan holat; ko'rsatishda sanadan qayta hisoblanadi.
  final PaymentStatus status;
  final String? debtId;

  /// Qaysi doimiy xarajat shablonidan ko'chirilgan.
  final String? recurringId;
  final bool autoPay;
  final String note;
  final EntrySource source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Money get plannedOrZero => planned ?? Money.zero;

  Money get actualOrZero => actual ?? Money.zero;

  bool get isPaid => actualOrZero.isPositive;

  /// Reja ham berilmagan — summasi noma'lum to'lov.
  bool get isUnknownAmount => planned == null;

  String get nameKey => normalizeKey(name);

  String get categoryKey => normalizeKey(category);

  Expense copyWith({
    String? id,
    String? name,
    String? category,
    PaymentMethod? method,
    Object? planned = unchanged,
    Object? actual = unchanged,
    DateTime? dueDate,
    MonthKey? monthKey,
    MonthKeySource? monthKeySource,
    PaymentStatus? status,
    Object? debtId = unchanged,
    Object? recurringId = unchanged,
    bool? autoPay,
    String? note,
    EntrySource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Expense(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        method: method ?? this.method,
        planned: orKeep(planned, this.planned),
        actual: orKeep(actual, this.actual),
        dueDate: dueDate ?? this.dueDate,
        monthKey: monthKey ?? this.monthKey,
        monthKeySource: monthKeySource ?? this.monthKeySource,
        status: status ?? this.status,
        debtId: orKeep(debtId, this.debtId),
        recurringId: orKeep(recurringId, this.recurringId),
        autoPay: autoPay ?? this.autoPay,
        note: note ?? this.note,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          other.id == id &&
          other.name == name &&
          other.category == category &&
          other.method == method &&
          other.planned == planned &&
          other.actual == actual &&
          other.dueDate == dueDate &&
          other.monthKey == monthKey &&
          other.monthKeySource == monthKeySource &&
          other.status == status &&
          other.debtId == debtId &&
          other.recurringId == recurringId &&
          other.autoPay == autoPay &&
          other.note == note &&
          other.source == source;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        method,
        planned,
        actual,
        dueDate,
        monthKey,
        monthKeySource,
        status,
        debtId,
        recurringId,
        autoPay,
        note,
        source,
      );

  @override
  String toString() =>
      'Expense($id, $monthKey, $name, reja=$planned, fakt=$actual)';
}
