import 'package:meta/meta.dart';

import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import 'entity_support.dart';

/// 💳 Qarz yoki haq.
///
/// [paidFromExpenses], [paidFromIncomes] va [pendingFromApp] —
/// denormallashtirilgan hisoblagichlar: bog'langan yozuv yozilganda o'sha
/// bitta batch ichida `increment` bilan yangilanadi. Shu tufayli qarzlar
/// ekrani bog'langan xarajatlarni o'qimaydi (N+1 yo'q).
///
/// Xarajat va daromad ALOHIDA sanaladi: "men qarzdorman" da faqat
/// xarajat, "menga qarzdor" da faqat daromad qarzni kamaytiradi
/// (`qarzlarniHisobla_` dagi qoida).
@immutable
final class Debt {
  const Debt({
    required this.id,
    required this.name,
    required this.direction,
    required this.total,
    this.paidBefore = Money.zero,
    this.monthly = Money.zero,
    this.paidFromExpenses = Money.zero,
    this.paidFromIncomes = Money.zero,
    this.pendingFromApp = Money.zero,
    this.dueDate,
    this.note = '',
    this.archived = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final DebtDirection direction;

  /// Umumiy summa.
  final Money total;

  /// Ilovadan tashqarida allaqachon to'langan qism.
  final Money paidBefore;

  /// Oylik to'lov rejasi (tugash muddatini hisoblash uchun).
  final Money monthly;

  /// Ilova orqali to'langan bog'langan XARAJATLAR yig'indisi (fakt).
  final Money paidFromExpenses;

  /// Bog'langan DAROMADLAR yig'indisi (haq qaytarilgani).
  final Money paidFromIncomes;

  /// Bog'langan, lekin hali to'lanmagan rejalar yig'indisi.
  final Money pendingFromApp;
  final DateTime? dueDate;
  final String note;
  final bool archived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isMine => direction == DebtDirection.iOwe;

  /// Ilova orqali qarzni kamaytirgan summa: yo'nalishga qarab tanlanadi.
  Money get appliedFromApp =>
      isMine ? paidFromExpenses : paidFromIncomes;

  Debt copyWith({
    String? id,
    String? name,
    DebtDirection? direction,
    Money? total,
    Money? paidBefore,
    Money? monthly,
    Money? paidFromExpenses,
    Money? paidFromIncomes,
    Money? pendingFromApp,
    Object? dueDate = unchanged,
    String? note,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Debt(
        id: id ?? this.id,
        name: name ?? this.name,
        direction: direction ?? this.direction,
        total: total ?? this.total,
        paidBefore: paidBefore ?? this.paidBefore,
        monthly: monthly ?? this.monthly,
        paidFromExpenses: paidFromExpenses ?? this.paidFromExpenses,
        paidFromIncomes: paidFromIncomes ?? this.paidFromIncomes,
        pendingFromApp: pendingFromApp ?? this.pendingFromApp,
        dueDate: orKeep(dueDate, this.dueDate),
        note: note ?? this.note,
        archived: archived ?? this.archived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Debt &&
          other.id == id &&
          other.name == name &&
          other.direction == direction &&
          other.total == total &&
          other.paidBefore == paidBefore &&
          other.monthly == monthly &&
          other.paidFromExpenses == paidFromExpenses &&
          other.paidFromIncomes == paidFromIncomes &&
          other.pendingFromApp == pendingFromApp &&
          other.dueDate == dueDate &&
          other.note == note &&
          other.archived == archived;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        direction,
        total,
        paidBefore,
        monthly,
        paidFromExpenses,
        paidFromIncomes,
        pendingFromApp,
        dueDate,
        note,
        archived,
      );

  @override
  String toString() => 'Debt($id, $name, ${direction.wire}, $total)';
}
