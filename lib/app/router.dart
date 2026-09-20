import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/features/auth/presentation/sign_in_screen.dart';
import 'package:my_wallet/features/dev/design_catalog_screen.dart';
import 'package:my_wallet/features/shell/presentation/app_shell.dart';
import 'package:my_wallet/features/shell/presentation/not_found_screen.dart';
import 'package:my_wallet/features/shell/presentation/placeholder_screen.dart';
import 'package:my_wallet/features/sync/presentation/sync_status_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Kirish ekrani manzili.
const signInPath = '/sign-in';

/// Marshrutlar. Kirilmagan — faqat kirish ekrani; kirilgan — undan
/// bosh sahifaga (sessiya eskirsa ham avtomatik).
final routerProvider = Provider<GoRouter>((ref) {
  final isDev = ref.watch(appConfigProvider).env == AppEnv.dev;
  final signedIn = ValueNotifier(ref.read(authUserProvider) != null);
  ref.listen(authUserProvider, (_, user) => signedIn.value = user != null);

  final router = GoRouter(
    refreshListenable: signedIn,
    redirect: (context, state) =>
        authRedirect(signedIn: signedIn.value, location: state.matchedLocation),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: signInPath,
        builder: (context, state) => const SignInScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          _tab('/', Icons.space_dashboard_outlined, (l10n) => l10n.tabHome),
          _tab(
            '/transactions',
            Icons.receipt_long_outlined,
            (l10n) => l10n.tabTransactions,
          ),
          _tab(
            '/payments',
            Icons.event_note_outlined,
            (l10n) => l10n.tabPayments,
          ),
          _tab(
            '/wallet',
            Icons.account_balance_wallet_outlined,
            (l10n) => l10n.tabWallet,
          ),
        ],
      ),
      // Amal qo'shish — alohida sahifa: vidjet va tez amallardan ham
      // ochiladi (E15, E33).
      GoRoute(
        path: '/add',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: PlaceholderScreen(
            title: AppL10n.of(context).addTitle,
            icon: Icons.add_card_outlined,
          ),
        ),
      ),
      // Sinxron holati (E13-T06) — SyncStatusBadge'dan.
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncStatusScreen(),
      ),
      if (isDev)
        GoRoute(
          path: '/dev/catalog',
          builder: (context, state) => const DesignCatalogScreen(),
        ),
    ],
  );
  ref
    ..onDispose(router.dispose)
    ..onDispose(signedIn.dispose);
  return router;
});

/// Kirish holatiga ko'ra yo'naltirish (`null` — o'z joyida qoladi).
String? authRedirect({required bool signedIn, required String location}) {
  final atSignIn = location == signInPath;
  if (!signedIn) return atSignIn ? null : signInPath;
  return atSignIn ? '/' : null;
}

StatefulShellBranch _tab(
  String path,
  IconData icon,
  String Function(AppL10n) title,
) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, state) =>
          PlaceholderScreen(title: title(AppL10n.of(context)), icon: icon),
    ),
  ],
);
