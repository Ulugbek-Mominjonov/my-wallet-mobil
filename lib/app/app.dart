import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/app/router.dart';
import 'package:my_wallet/core/design_system/app_theme.dart';
import 'package:my_wallet/core/l10n/locale_resolution.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Ilova ildizi: tema, lokalizatsiya va marshrutlash.
class MyWalletApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppL10n.of(context).appName,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      localeResolutionCallback: resolveAppLocale,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
