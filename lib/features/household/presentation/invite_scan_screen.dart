// Kamera va ML Kit — platforma qismi; kod ajratish mantiqi
// `parseInviteCode` da va o'sha yerda testlanadi.
// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Taklif QR kodini o'qiydi va kodni qaytaradi (`mywallet://invite/<kod>`
/// yoki kodning o'zi). Birinchi to'g'ri kodda yopiladi.
class InviteScanScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.householdScanTitle)),
      body: MobileScanner(
        onDetect: (capture) {
          for (final barcode in capture.barcodes) {
            final code = parseInviteCode(barcode.rawValue ?? '');
            if (code != null) {
              context.pop(code);
              return;
            }
          }
        },
      ),
    );
  }
}
