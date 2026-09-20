import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Byudjet yo'q (yoki taklif havolasi ochilgan): yangi byudjet yaratish yoki
/// taklif kodi bilan qo'shilish — kod, QR yoki `mywallet://invite/<kod>`.
class JoinOrCreateScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<JoinOrCreateScreen> createState() => _JoinOrCreateState();
}

class _JoinOrCreateState extends ConsumerState<JoinOrCreateScreen> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  var _busy = false;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    final pending = ref.read(pendingInviteProvider);
    if (pending != null) _code.text = pending;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<Result<void>> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failure = result is Err ? (result as Err<void>).failure : null;
    });
    if (result is Ok) {
      ref.read(pendingInviteProvider.notifier).clear();
      context.go('/');
    }
  }

  Future<void> _scan() async {
    final code = await context.push<String>(inviteScanPath);
    if (code == null || !mounted) return;
    _code.text = code;
    await _run(() => ref.read(startupProvider.notifier).joinHousehold(code));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(startupProvider.notifier);
    // Ilova ochiq turganda kelgan taklif havolasi — kodni to'ldiradi.
    ref.listen(pendingInviteProvider, (_, code) {
      if (code != null) _code.text = code;
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.householdSetupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.householdSetupSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.householdCreateTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _name,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.householdNameLabel,
                    hintText: l10n.householdNameDefault,
                    errorText: _errorFor('name', l10n),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => unawaited(
                          _run(
                            () => controller.createHousehold(
                              _name.text.trim().isEmpty
                                  ? l10n.householdNameDefault
                                  : _name.text,
                            ),
                          ),
                        ),
                  child: Text(l10n.householdCreate),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.householdJoinTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _code,
                  enabled: !_busy,
                  maxLength: inviteCodeLength,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [UpperCaseFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.householdCodeLabel,
                    counterText: '',
                    errorText: _errorFor('code', l10n),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => unawaited(
                          _run(() => controller.joinHousehold(_code.text)),
                        ),
                  child: Text(l10n.householdJoin),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : () => unawaited(_scan()),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.householdScan),
                ),
              ],
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: AppSpacing.lg),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  /// Xato shu maydonga tegishli bo'lsa — matni, aks holda `null`.
  String? _errorFor(String field, AppL10n l10n) {
    final failure = _failure;
    if (failure == null) return null;
    final isCode = failure is! ValidationFailure || failure.field == 'code';
    return (field == 'code') == isCode
        ? householdErrorText(l10n, failure)
        : null;
  }
}

/// Taklif kodi katta harflarda (server ham shunday saqlaydi).
final class UpperCaseFormatter extends TextInputFormatter {
  const new();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}

/// Byudjet yaratish/qo'shilish xatosi → foydalanuvchi matni.
String householdErrorText(AppL10n l10n, Failure failure) => switch (failure) {
  ValidationFailure(field: 'name') => l10n.householdErrorName,
  ValidationFailure() => l10n.householdErrorCode,
  RejectedFailure(code: 'invite_not_found') => l10n.householdErrorNotFound,
  RejectedFailure(code: 'invite_used') => l10n.householdErrorUsed,
  RejectedFailure(code: 'invite_expired') => l10n.householdErrorExpired,
  RejectedFailure(code: 'already_member') => l10n.householdErrorMember,
  OfflineFailure() => l10n.errorOffline,
  _ => l10n.errorUnexpected,
};
