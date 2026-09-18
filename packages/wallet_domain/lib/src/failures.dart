import 'package:meta/meta.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

/// Domen natijasi: use-case xato bermaydi (exception emas), aniq sabab
/// qaytaradi — UI tarjima qiladi. Kodlar server bilan bir xil
/// (`contracts/api.md`).
@immutable
sealed class Failure {
  const new();
}

/// Kiritish xatosi: [field] — forma maydoni, [code] — mashina o'qiydigan kod
/// (masalan `amount_required`, `invalid_name`).
final class ValidationFailure extends Failure {
  const new(this.field, this.code);

  final String field;
  final String code;

  @override
  bool operator ==(Object other) =>
      other is ValidationFailure && other.field == field && other.code == code;

  @override
  int get hashCode => Object.hash(field, code);

  @override
  String toString() => 'ValidationFailure($field: $code)';
}

/// BR-006: yozuv boshqa qurilmada o'zgargan (sinxron `conflict`).
final class ConflictFailure extends Failure {
  const new(this.recordId);

  final String recordId;

  @override
  String toString() => 'ConflictFailure($recordId)';
}

/// BR-055: yopilgan oyga yozuv. Qattiq qulfda — rad etiladi; qulfsiz rejimda
/// — faqat ogohlantirish ([blocking] = false), foydalanuvchi tasdiqlaydi.
final class MonthClosedWarning extends Failure {
  const new(this.month, {required this.blocking});

  final MonthKey month;
  final bool blocking;

  @override
  String toString() => 'MonthClosedWarning($month, blocking: $blocking)';
}
