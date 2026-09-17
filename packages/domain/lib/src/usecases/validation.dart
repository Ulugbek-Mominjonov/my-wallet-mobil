import '../repositories/errors.dart';
import '../value_objects/money.dart';

/// Tashqi kirish DOIM shu yerdan o'tadi — usecase'lar ichida takroriy
/// `if` lar yozilmaydi.
abstract final class Validate {
  /// Musbat summa talab qiladi (`musbatSon_` ning analogi).
  static Money positiveAmount(Money? value, String field) {
    if (value == null || !value.isPositive) {
      throw ValidationFailure(field, 'Musbat summa kiriting');
    }
    return value;
  }

  /// Manfiy bo'lmagan summa (nol ruxsat).
  static Money amount(Money? value, String field) {
    if (value == null || value.isNegative) {
      throw ValidationFailure(field, "Summa manfiy bo'lishi mumkin emas");
    }
    return value;
  }

  /// Bo'sh bo'lmagan matn (`matnTalab_` ning analogi).
  static String text(String? value, String field) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      throw ValidationFailure(field, "To'ldirilishi shart");
    }
    return trimmed;
  }

  /// Ixtiyoriy matn — bo'sh bo'lsa `null`.
  static String? optionalText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Oy ichidagi kun (1..31).
  static int day(int value, String field) {
    if (value < 1 || value > 31) {
      throw ValidationFailure(field, "Kun 1–31 oralig'ida bo'lsin");
    }
    return value;
  }
}
