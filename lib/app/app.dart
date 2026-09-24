import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/design_system/app_theme.dart';
import 'package:my_wallet/core/l10n/locale_resolution.dart';
import 'package:my_wallet/core/settings/app_settings.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';
import 'package:my_wallet/features/notifications/application/local_reminders.dart';
import 'package:my_wallet/features/notifications/application/notification_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Ilova ildizi: tema, lokalizatsiya va marshrutlash.
class MyWalletApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bildirishnomalar (E19): ro'yxatdan o'tish, ilova ochiq paytidagi push,
    // bosilganda — tegishli ekran.
    ref
      ..listen(pushRegistrationProvider, (_, _) {})
      ..listen(foregroundPushProvider, (_, _) {})
      ..listen(localRemindersProvider, (_, _) {})
      ..listen(notificationTapsProvider, (_, next) {
        if (next.value case final route?) ref.read(routerProvider).go(route);
      })
      // E33-T01, T03: vidjet va tez amallar (app shortcuts) havolalari.
      ..listen(shortcutLinksProvider, (_, next) {
        if (next.value case final route?) ref.read(routerProvider).go(route);
      });
    return MaterialApp.router(
      onGenerateTitle: (context) => AppL10n.of(context).appName,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(languageProvider),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      localeResolutionCallback: resolveAppLocale,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
