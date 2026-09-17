import 'package:meta/meta.dart';

import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';
import '../value_objects/name_key.dart';
import 'entity_support.dart';

/// Daromad yozuvi — bitta tushum.
///
/// [monthKey] SANADAN EMAS, daromad qoidasidan kelib chiqadi (§2.1):
/// 1-sentabrda olingan "Oylik" avgust byudjetiga tushadi. Qiymat yozuv
/// paytida hisoblanib saqlanadi — so'rov faqat shu maydon bo'yicha ketadi.
@immutable
final class Income {
  const Income({
    required this.id,
    required this.amount,
    required this.type,
    required this.method,
    required this.paidAt,
    required this.monthKey,
    this.note = '',
    this.debtId,
    this.source = EntrySource.manual,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final Money amount;

  /// Daromad turi: `Oylik`, `Avans`, `KPI`, `Qo'shimcha` yoki foydalanuvchi
  /// qo'shgan boshqa tur.
  final String type;
  final PaymentMethod method;
  final DateTime paidAt;

  /// Qaysi oy byudjetiga tegishli (qoidaga ko'ra hisoblangan).
  final MonthKey monthKey;
  final String note;

  /// Menga qarzdor bo'lgan odam pulni qaytarsa — shu qarzga bog'lanadi.
  final String? debtId;
  final EntrySource source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get typeKey => normalizeKey(type);

  Income copyWith({
    String? id,
    Money? amount,
    String? type,
    PaymentMethod? method,
    DateTime? paidAt,
    MonthKey? monthKey,
    String? note,
    Object? debtId = unchanged,
    EntrySource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Income(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        method: method ?? this.method,
        paidAt: paidAt ?? this.paidAt,
        monthKey: monthKey ?? this.monthKey,
        note: note ?? this.note,
        debtId: orKeep(debtId, this.debtId),
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Income &&
          other.id == id &&
          other.amount == amount &&
          other.type == type &&
          other.method == method &&
          other.paidAt == paidAt &&
          other.monthKey == monthKey &&
          other.note == note &&
          other.debtId == debtId &&
          other.source == source;

  @override
  int get hashCode => Object.hash(
        id,
        amount,
        type,
        method,
        paidAt,
        monthKey,
        note,
        debtId,
        source,
      );

  @override
  String toString() => 'Income($id, $monthKey, $type, $amount)';
}
