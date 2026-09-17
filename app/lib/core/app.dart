import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import 'l10n/strings.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Ilovaning ildizi.
class BudgetApp extends ConsumerStatefulWidget {
  const BudgetApp({super.key});

  @override
  ConsumerState<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends ConsumerState<BudgetApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final mode = switch (ref.watch(settingsProvider).app.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: Uz.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: _router,
    );
  }
}
