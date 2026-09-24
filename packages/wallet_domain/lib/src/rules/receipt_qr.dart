import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/money.dart';

/// E33-T02: fiskal chek QR kodi (soliq.uz) — summa, sana va sotuvchi STIR i.
///
/// Havola ko'rinishi: `https://ofd.soliq.uz/check?t=301234567&r=12345
/// &c=UZ...&s=15000000&d=20261005&fp=...` — `s` tiyinda, `d` — `YYYYMMDD`
/// (vaqt bilan ham bo'lishi mumkin). Nom havolada yo'q: STIR faqat izohga.
typedef ReceiptScan = ({
  Money amount,
  LocalDate? date,

  /// Sotuvchi STIR i (`t`) — bo'lsa.
  String? tin,

  /// Chek havolasi (izohga yoziladi — keyin ochib tekshirish uchun).
  String link,
});

/// Chek havolasidan summa va sanani ajratadi; tanilmasa — `null`
/// (chaqiruvchi havolani izohga yozadi).
ReceiptScan? parseReceiptLink(String raw) {
  final text = raw.trim();
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasQuery) return null;
  if (!uri.host.toLowerCase().endsWith('soliq.uz')) return null;

  final minor = int.tryParse(uri.queryParameters['s'] ?? '');
  if (minor == null || minor <= 0) return null;
  final tin = uri.queryParameters['t'];
  return (
    amount: Money(minor),
    date: _date(uri.queryParameters['d']),
    tin: tin == null || tin.isEmpty ? null : tin,
    link: text,
  );
}

/// `20261005` yoki `202610051530` → sana; boshqasi — `null`.
LocalDate? _date(String? value) {
  if (value == null || value.length < 8) return null;
  final year = int.tryParse(value.substring(0, 4));
  final month = int.tryParse(value.substring(4, 6));
  final day = int.tryParse(value.substring(6, 8));
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return LocalDate(year, month, day);
}
