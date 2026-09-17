/// Nomlarni solishtirish uchun yagona normalizatsiya.
///
/// `Code.gs` dagi `kalit_()` funksiyasining aynan o'zi: trim + lowercase.
/// Kategoriya, qarz nomi, doimiy xarajat nomi — hammasi shu orqali
/// solishtiriladi: `"Oziq-ovqat "` va `"oziq-ovqat"` bitta narsa bo'ladi.
String normalizeKey(Object? value) => value.toString().trim().toLowerCase();

/// Bo'sh yoki faqat probeldan iborat emasligini tekshiradi.
bool isBlank(Object? value) => value == null || value.toString().trim().isEmpty;
