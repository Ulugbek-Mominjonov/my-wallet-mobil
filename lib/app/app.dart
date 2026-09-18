import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/app_theme.dart';
import 'package:my_wallet/core/l10n/locale_resolution.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

/// Ilova ildizi. Marshrutlash E04-T06 da qo'shiladi.
class MyWalletApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppL10n.of(context).appName,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      localeResolutionCallback: resolveAppLocale,
      home: Builder(
        builder: (context) =>
            Scaffold(body: Center(child: Text(AppL10n.of(context).appName))),
      ),
    );
  }
}
