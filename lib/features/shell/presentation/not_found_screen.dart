import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

class NotFoundScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.link_off,
        title: l10n.errorNotFound,
        message: l10n.notFoundMessage,
        action: FilledButton(
          onPressed: () => context.go('/'),
          child: Text(l10n.actionHome),
        ),
      ),
    );
  }
}
