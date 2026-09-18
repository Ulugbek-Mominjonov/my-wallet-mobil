import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/app_theme.dart';

/// Ilova ildizi. L10n va marshrutlash E04-T05/T06 da qo'shiladi.
class MyWalletApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wallet',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: const Scaffold(body: Center(child: Text('My Wallet'))),
    );
  }
}
