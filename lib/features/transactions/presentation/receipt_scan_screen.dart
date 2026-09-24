// Kamera va ML Kit — platforma qismi; havolani tahlil qilish
// `parseReceiptLink` da va o'sha yerda testlanadi.
// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// E33-T02: fiskal chek QR kodini o'qiydi. Tanilgan havolada summa va sana
/// qaytadi; tanilmasa — havolaning o'zi (izohga yoziladi).
class ReceiptScanScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptScanTitle)),
      body: MobileScanner(
        onDetect: (capture) {
          for (final barcode in capture.barcodes) {
            final raw = barcode.rawValue;
            if (raw == null || raw.isEmpty) continue;
            context.pop(parseReceiptLink(raw) ?? _unknown(raw));
            return;
          }
        },
      ),
    );
  }

  /// Tanilmagan kod — faqat havola (summa va sana qo'lda kiritiladi).
  static ReceiptScan _unknown(String raw) =>
      (amount: Money.zero, date: null, tin: null, link: raw);
}
