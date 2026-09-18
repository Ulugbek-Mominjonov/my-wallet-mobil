import 'package:flutter/material.dart';

/// Ilova ildizi. Tema, l10n va marshrutlash E04-T04..T06 da qo'shiladi.
class MyWalletApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My Wallet',
      home: Scaffold(body: Center(child: Text('My Wallet'))),
    );
  }
}
