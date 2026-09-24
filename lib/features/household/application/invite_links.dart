import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Taklif kodi uzunligi (BR-012) — server alifbosidagi 8 belgi.
const inviteCodeLength = 8;

/// QR skaner marshruti.
const inviteScanPath = '/join/scan';

/// Taklif havolasi (BR-012) — muhitga mos sxema bilan; Android manifestidagi
/// `deepLinkScheme` bilan bir xil (admin paneldagi `inviteLink` kabi).
String inviteLink(String code, AppEnv env) => '${_scheme(env)}://invite/$code';

/// E33-T01: vidjetdagi "＋" tugmasi havolasi (xarajat qo'shish).
String addLink(AppEnv env) => '${_scheme(env)}://add?kind=expense';

/// Android manifestidagi `deepLinkScheme` bilan bir xil.
String _scheme(AppEnv env) => switch (env) {
  AppEnv.dev => 'mywallet-dev',
  AppEnv.staging => 'mywallet-stg',
  AppEnv.prod => 'mywallet',
};

/// Kiruvchi havolalar (ilova yopiq bo'lsa ham — birinchi havola):
/// taklif, tez amallar va bosh ekran vidjeti. Testda almashtiriladi.
/// Bir nechta tinglovchi (taklif va tez amallar) — broadcast oqim.
final Provider<Stream<String>> appLinksProvider = Provider(
  (ref) => AppLinks().uriLinkStream
      .map((uri) => uri.toString())
      // Plagin yo'q yoki kanal xato bersa — havolasiz davom etadi.
      .handleError((Object error) => AppLog.info('Havola oqimi: $error'))
      .asBroadcastStream(),
);

/// `mywallet://invite/<kod>` havolalari — kod.
final StreamProvider<String> inviteLinksProvider = StreamProvider(
  (ref) => ref
      .watch(appLinksProvider)
      .map(parseInviteCode)
      .where((code) => code != null)
      .cast<String>(),
);

/// E33-T01, T03: vidjet va tez amallar havolalari — ilova marshruti.
final StreamProvider<String> shortcutLinksProvider = StreamProvider(
  (ref) => ref
      .watch(appLinksProvider)
      .map(parseShortcutRoute)
      .where((route) => route != null)
      .cast<String>(),
);

/// Havola hosti → marshrut (oq ro'yxat: tashqaridan kelgan qiymat
/// marshrut sifatida ishlatilmaydi).
const Map<String, String> shortcutRoutes = {
  'add': '/add',
  'payments': '/payments',
};

/// `mywallet://add?kind=expense` → `/add?kind=expense`; noma'lum — `null`.
String? parseShortcutRoute(String input) {
  final uri = Uri.tryParse(input.trim());
  final route = uri == null ? null : shortcutRoutes[uri.host];
  if (uri == null || route == null) return null;
  final kind = uri.queryParameters['kind'];
  final allowed = TransactionKind.values.any((k) => k.wire == kind);
  return route == '/add' && allowed ? '$route?kind=$kind' : route;
}

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
