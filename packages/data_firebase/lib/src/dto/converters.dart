import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

/// Firestore ↔ domen turlari o'rtasidagi tarjima.
///
/// Tashqi ma'lumot HAR DOIM shubhali: hujjat qo'lda tahrirlangan, eski
/// versiyadan qolgan yoki import buzilgan bo'lishi mumkin. Shuning uchun
/// har bir o'qish himoyalangan — `as` bilan to'g'ridan-to'g'ri cast yo'q.
abstract final class Read {
  static String text(Map<String, dynamic> data, String key, {String or = ''}) {
    final value = data[key];
    return value is String ? value : or;
  }

  static String? optionalText(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int integer(Map<String, dynamic> data, String key, {int or = 0}) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.round();
    return or;
  }

  static Money money(Map<String, dynamic> data, String key) =>
      Money(integer(data, key));

  static Money? optionalMoney(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is int) return Money(value);
    if (value is num) return Money(value.round());
    return null;
  }

  static bool flag(Map<String, dynamic> data, String key, {bool or = false}) {
    final value = data[key];
    return value is bool ? value : or;
  }

  static DateTime date(Map<String, dynamic> data, String key) =>
      optionalDate(data, key) ?? DateTime.fromMillisecondsSinceEpoch(0);

  static DateTime? optionalDate(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Oy kaliti; noto'g'ri bo'lsa [fallback] dan olinadi.
  static MonthKey monthKey(
    Map<String, dynamic> data,
    String key, {
    required DateTime fallback,
  }) =>
      MonthKey.tryParse(data[key]) ?? MonthKey.of(fallback);

  static Map<String, dynamic> map(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  static List<Map<String, dynamic>> mapList(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value is! List) return const <Map<String, dynamic>>[];
    return <Map<String, dynamic>>[
      for (final item in value)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }
}

/// Yozishda ishlatiladigan yordamchilar.
abstract final class Write {
  /// Sana — Firestore `Timestamp` sifatida (so'rovlar uchun ham shu shart).
  static Timestamp? date(DateTime? value) =>
      value == null ? null : Timestamp.fromDate(value);

  /// Server vaqti — yozuv qachon sinxronlangani.
  static FieldValue get now => FieldValue.serverTimestamp();

  /// Ichma-ich map'dagi har bir butun sonni `increment` ga o'raydi.
  ///
  /// Nuqtali "field path" ishlatilmaydi: kategoriya nomida nuqta bo'lsa yo'l
  /// noto'g'ri talqin qilinardi. `merge: true` ichma-ich map'larni
  /// maydonma-maydon birlashtiradi.
  static Map<String, Object?> increments(Map<String, Object> source) =>
      <String, Object?>{
        for (final entry in source.entries)
          entry.key: entry.value is Map<String, Object>
              ? increments(entry.value as Map<String, Object>)
              : FieldValue.increment(entry.value as int),
      };
}
