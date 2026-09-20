import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/format/money_format.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Summa kiritish: faqat raqam (asosiy birlikda — so'm), pastda to'liq
/// ko'rinishi. Qiymat — eng kichik birlikda (BR-001).
class MoneyField extends StatefulWidget {
  const new({
    required this.label,
    required this.onChanged,
    this.initial,
    this.currency = Currency.uzs,
    this.enabled = true,
    super.key,
  });

  final String label;
  final ValueChanged<Money> onChanged;
  final Money? initial;
  final Currency currency;
  final bool enabled;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late final TextEditingController _controller;
  late Money _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial ?? Money(0, widget.currency);
    _controller = TextEditingController(
      text: _value.minor == 0
          ? ''
          : (_value.minor ~/ widget.currency.minorPerMajor).toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    final parsed = Money.tryParse(text, currency: widget.currency);
    setState(() => _value = parsed ?? Money(0, widget.currency));
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: _value.minor == 0
            ? null
            : formatMoney(_value.minor, currency: widget.currency.code),
      ),
    );
  }
}
