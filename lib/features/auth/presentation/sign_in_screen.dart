import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/features/auth/application/sign_in_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Kirish (E14-T01): Google yoki email kodi. Yangi foydalanuvchi shu yerda
/// ro'yxatdan o'tadi (BR-010 — shaxsiy byudjet server yaratadi).
class SignInScreen extends ConsumerWidget {
  const new({super.key});

  static const _maxWidth = 420.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(signInControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Logo(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.authTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: state.codeSent
                        ? _CodeStep(key: const ValueKey('code'), state: state)
                        : _EmailStep(
                            key: const ValueKey('email'),
                            state: state,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 48,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _EmailStep extends ConsumerStatefulWidget {
  const new({required this.state, super.key});

  final SignInState state;

  @override
  ConsumerState<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends ConsumerState<_EmailStep> {
  late final _email = TextEditingController(text: widget.state.email);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() => unawaited(
    ref.read(signInControllerProvider.notifier).sendCode(_email.text),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = widget.state;
    final controller = ref.read(signInControllerProvider.notifier);
    final google = ref.watch(authGatewayProvider).googleAvailable;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (google) ...[
            OutlinedButton.icon(
              onPressed: state.busy
                  ? null
                  : () => unawaited(controller.signInWithGoogle()),
              icon: const Icon(Icons.account_circle_outlined),
              label: Text(l10n.authGoogle),
            ),
            const SizedBox(height: AppSpacing.lg),
            _OrDivider(label: l10n.authOr),
            const SizedBox(height: AppSpacing.lg),
          ],
          TextField(
            controller: _email,
            enabled: !state.busy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.authEmailLabel,
              prefixIcon: const Icon(Icons.mail_outline),
              errorText: authErrorText(l10n, state.failure),
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _BusyButton(
            busy: state.busy,
            label: l10n.authSendCode,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _CodeStep extends ConsumerStatefulWidget {
  const new({required this.state, super.key});

  final SignInState state;

  @override
  ConsumerState<_CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends ConsumerState<_CodeStep> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() =>
      unawaited(ref.read(signInControllerProvider.notifier).verify(_code.text));

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final state = widget.state;
    final controller = ref.read(signInControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authCodeTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authCodeSent(state.email, emailCodeLength),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _code,
          enabled: !state.busy,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: emailCodeLength,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 8),
          onChanged: (value) {
            if (value.length == emailCodeLength) _submit();
          },
          decoration: InputDecoration(
            labelText: l10n.authCodeLabel,
            counterText: '',
            errorText: authErrorText(l10n, state.failure),
            errorMaxLines: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _BusyButton(
          busy: state.busy,
          label: l10n.authVerify,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ResendButton(
          key: ValueKey(state.sends),
          enabled: !state.busy,
          onPressed: () => unawaited(controller.resend()),
        ),
        TextButton(
          onPressed: state.busy ? null : controller.changeEmail,
          child: Text(l10n.authChangeEmail),
        ),
      ],
    );
  }
}

/// Qayta yuborish — [resendCooldown] tugaguncha orqaga sanaydi.
class _ResendButton extends StatefulWidget {
  const new({required this.enabled, required this.onPressed, super.key});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  int _left = resendCooldown.inSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _left--);
      if (_left <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final waiting = _left > 0;
    return TextButton(
      onPressed: widget.enabled && !waiting ? widget.onPressed : null,
      child: Text(waiting ? l10n.authResendIn(_left) : l10n.authResend),
    );
  }
}

class _BusyButton extends StatelessWidget {
  const new({required this.busy, required this.label, required this.onPressed});

  final bool busy;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Kirish xatosi → foydalanuvchi matni (`null` — xato yo'q).
String? authErrorText(AppL10n l10n, Failure? failure) => switch (failure) {
  null => null,
  ValidationFailure(code: AuthCodes.invalidEmail) ||
  RejectedFailure(
    code: 'email_address_invalid' || 'validation_failed',
  ) => l10n.authErrorInvalidEmail,
  ValidationFailure(code: AuthCodes.invalidCode) => l10n.authErrorInvalidCode(
    emailCodeLength,
  ),
  RejectedFailure(code: 'otp_expired') => l10n.authErrorCodeExpired,
  RejectedFailure(
    code: 'over_email_send_rate_limit' || 'over_request_rate_limit',
  ) =>
    l10n.authErrorRateLimit,
  RejectedFailure(
    code: AuthCodes.googleFailed || AuthCodes.googleUnavailable,
  ) =>
    l10n.authErrorGoogle,
  OfflineFailure() => l10n.errorOffline,
  _ => l10n.errorUnexpected,
};
