import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/features/auth/presentation/sign_in_screen.dart';
import 'package:my_wallet/features/dev/design_catalog_screen.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';
import 'package:my_wallet/features/household/presentation/invite_scan_screen.dart';
import 'package:my_wallet/features/household/presentation/join_or_create_screen.dart';
import 'package:my_wallet/features/onboarding/presentation/onboarding_screen.dart';
import 'package:my_wallet/features/shell/presentation/app_shell.dart';
import 'package:my_wallet/features/shell/presentation/not_found_screen.dart';
import 'package:my_wallet/features/shell/presentation/placeholder_screen.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/startup/presentation/splash_screen.dart';
import 'package:my_wallet/features/startup/presentation/update_required_screen.dart';
import 'package:my_wallet/features/sync/presentation/sync_status_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Kirish ekrani manzili.
const signInPath = '/sign-in';

/// Byudjet yuklanguncha (`app_bootstrap`).
const splashPath = '/splash';

/// Byudjet yaratish yoki taklif kodi bilan qo'shilish.
const joinPath = '/join';

/// Sozlash oynasi (E14-T03).
const onboardingPath = '/onboarding';

/// BR-214: majburiy yangilash ekrani.
const updatePath = '/update';

/// Marshrutlar. Kirilmagan — faqat kirish ekrani; kirilgan — undan
/// bosh sahifaga (sessiya eskirsa ham avtomatik).
final routerProvider = Provider<GoRouter>((ref) {
  final isDev = ref.watch(appConfigProvider).env == AppEnv.dev;
  final signedIn = ValueNotifier(ref.read(authUserProvider) != null);
  final startup = ValueNotifier<StartupState>(ref.read(startupProvider));
  final invite = ValueNotifier<String?>(ref.read(pendingInviteProvider));
  ref
    ..listen(authUserProvider, (_, user) => signedIn.value = user != null)
    ..listen(startupProvider, (_, next) => startup.value = next)
    ..listen(pendingInviteProvider, (_, code) => invite.value = code);

  final router = GoRouter(
    refreshListenable: Listenable.merge([signedIn, startup, invite]),
    redirect: (context, state) => appRedirect(
      signedIn: signedIn.value,
      startup: startup.value,
      hasInvite: invite.value != null,
      location: state.matchedLocation,
    ),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: signInPath,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: updatePath,
        builder: (context, state) => const UpdateRequiredScreen(),
      ),
      GoRoute(
        path: joinPath,
        builder: (context, state) => const JoinOrCreateScreen(),
        routes: [
          GoRoute(
            path: 'scan',
            builder: (context, state) => const InviteScanScreen(),
          ),
        ],
      ),
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
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
          child: Scaffold(
            appBar: AppBar(title: Text(AppL10n.of(context).addTitle)),
            body: const PlaceholderScreen(
              title: '',
              icon: Icons.add_card_outlined,
            ),
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
    ..onDispose(signedIn.dispose)
    ..onDispose(startup.dispose)
    ..onDispose(invite.dispose);
  return router;
});

/// Yo'naltirish (`null` — o'z joyida qoladi): kirish → byudjet yuklash →
/// byudjet tanlash/taklif → sozlash oynasi → ilova.
String? appRedirect({
  required bool signedIn,
  required StartupState startup,
  required bool hasInvite,
  required String location,
}) {
  if (!signedIn) return location == signInPath ? null : signInPath;

  final target = switch (startup) {
    StartupUpdateRequired() => updatePath,
    StartupLoading() || StartupFailed() => splashPath,
    StartupNoHousehold() => joinPath,
    // Taklif havolasi ochilgan — qo'shilish ekrani (byudjet bor bo'lsa ham).
    StartupReady() when hasInvite => joinPath,
    StartupReady(needsOnboarding: true) => onboardingPath,
    StartupReady() => null,
  };
  if (target == null) {
    // `/join` ro'yxatda yo'q: byudjet bor bo'lsa ham foydalanuvchi uni
    // almashtirgichdan ochishi mumkin (qo'shilgach ekranning o'zi qaytaradi).
    return _gatePaths.any(location.startsWith) ? '/' : null;
  }
  return location.startsWith(target) ? null : target;
}

const List<String> _gatePaths = [
  signInPath,
  splashPath,
  onboardingPath,
  updatePath,
];

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
