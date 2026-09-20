import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/security/pin_store.dart';

/// PIN kiritish: nuqtalar va raqamli klaviatura (48 dp teginish maydoni).
/// To'liq terilganda [onCompleted] chaqiriladi va maydon tozalanadi.
class PinPad extends StatefulWidget {
  const new({
    required this.onCompleted,
    this.biometricsLabel,
    this.onBiometrics,
    super.key,
  });

  final ValueChanged<String> onCompleted;
  final String? biometricsLabel;
  final VoidCallback? onBiometrics;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  var _pin = '';

  void _press(String digit) {
    if (_pin.length >= pinLength) return;
    setState(() => _pin += digit);
    if (_pin.length == pinLength) {
      final pin = _pin;
      setState(() => _pin = '');
      widget.onCompleted(pin);
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < pinLength; i++)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  i < _pin.length ? Icons.circle : Icons.circle_outlined,
                  size: 16,
                  color: scheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final digit in row) _Key(digit, () => _press(digit)),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.onBiometrics != null)
              _IconKey(
                icon: Icons.fingerprint,
                label: widget.biometricsLabel ?? '',
                onPressed: widget.onBiometrics!,
              )
            else
              const SizedBox(width: 72, height: 72),
            _Key('0', () => _press('0')),
            _IconKey(
              icon: Icons.backspace_outlined,
              label: '⌫',
              onPressed: _backspace,
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const new(this.digit, this.onPressed);

  final String digit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    height: 72,
    child: TextButton(
      onPressed: onPressed,
      child: Text(digit, style: Theme.of(context).textTheme.headlineSmall),
    ),
  );
}

class _IconKey extends StatelessWidget {
  const new({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    height: 72,
    child: IconButton(onPressed: onPressed, tooltip: label, icon: Icon(icon)),
  );
}
