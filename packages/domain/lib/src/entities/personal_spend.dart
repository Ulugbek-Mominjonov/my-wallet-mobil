import 'package:meta/meta.dart';

import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import '../value_objects/month_key.dart';

/// 👤 Shaxsiy fonddan sarf.
///
/// Bu yozuv XARAJAT EMAS — oylik byudjet qoldig'iga ta'sir qilmaydi.
/// U faqat shaxsiy fond qoldig'ini kamaytiradi (§2.4).
@immutable
final class PersonalSpend {
  const PersonalSpend({
    required this.id,
    required this.amount,
    required this.purpose,
    required this.method,
    required this.spentAt,
    required this.monthKey,
    this.note = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final Money amount;

  /// Nima uchun sarflandi.
  final String purpose;
  final PaymentMethod method;
  final DateTime spentAt;
  final MonthKey monthKey;
  final String note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PersonalSpend copyWith({
    String? id,
    Money? amount,
    String? purpose,
    PaymentMethod? method,
    DateTime? spentAt,
    MonthKey? monthKey,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      PersonalSpend(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        purpose: purpose ?? this.purpose,
        method: method ?? this.method,
        spentAt: spentAt ?? this.spentAt,
        monthKey: monthKey ?? this.monthKey,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalSpend &&
          other.id == id &&
          other.amount == amount &&
          other.purpose == purpose &&
          other.method == method &&
          other.spentAt == spentAt &&
          other.monthKey == monthKey &&
          other.note == note;

  @override
  int get hashCode => Object.hash(
        id,
        amount,
        purpose,
        method,
        spentAt,
        monthKey,
        note,
      );

  @override
  String toString() => 'PersonalSpend($id, $monthKey, $purpose, $amount)';
}
