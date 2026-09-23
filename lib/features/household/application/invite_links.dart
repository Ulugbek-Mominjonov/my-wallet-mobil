import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';

/// Taklif kodi uzunligi (BR-012) — server alifbosidagi 8 belgi.
const inviteCodeLength = 8;

/// QR skaner marshruti.
const inviteScanPath = '/join/scan';

/// Taklif havolasi (BR-012) — muhitga mos sxema bilan; Android manifestidagi
/// `deepLinkScheme` bilan bir xil (admin paneldagi `inviteLink` kabi).
String inviteLink(String code, AppEnv env) => switch (env) {
  AppEnv.dev => 'mywallet-dev://invite/$code',
  AppEnv.staging => 'mywallet-stg://invite/$code',
  AppEnv.prod => 'mywallet://invite/$code',
};

/// Kiruvchi `mywallet://invite/<kod>` havolalari (ilova yopiq bo'lsa ham —
/// birinchi havola). Testda boshqa oqim bilan almashtiriladi.
final inviteLinksProvider = StreamProvider<String>((ref) {
  final links = AppLinks();
  return links.uriLinkStream
      .map((uri) => parseInviteCode(uri.toString()))
      .where((code) => code != null)
      .cast<String>();
});

/// Oxirgi kelgan taklif kodi — qo'shilish ekrani shuni to'ldiradi.
final NotifierProvider<PendingInvite, String?> pendingInviteProvider =
    NotifierProvider(PendingInvite.new);

final class PendingInvite extends Notifier<String?> {
  @override
  String? build() {
    ref.listen(inviteLinksProvider, (_, next) {
      final code = next.value;
      if (code != null) state = code;
    });
    return null;
  }

  void clear() => state = null;
}
