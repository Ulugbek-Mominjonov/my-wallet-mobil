import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format/formatters.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';

/// Summa kiritish maydoni — kiritilayotgan raqam darhol formatlanadi.
class AmountField extends StatefulWidget {
  const AmountField({
    required this.controller,
    super.key,
    this.label = Uz.amount,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final ValueChanged<Money?>? onChanged;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFeatures: tabularFigures,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: Uz.soum,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          _ThousandsFormatter(),
        ],
        onChanged: (value) => widget.onChanged?.call(Money.tryParse(value)),
      );
}

/// `1200000` → `1 200 000` — yozayotganda ajratadi.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = Fmt.money(Money(int.parse(digits)));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Karta / naqd tanlovi.
class MethodPicker extends StatelessWidget {
  const MethodPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<PaymentMethod>(
        segments: const <ButtonSegment<PaymentMethod>>[
          ButtonSegment<PaymentMethod>(
            value: PaymentMethod.card,
            label: Text(Uz.card),
            icon: Icon(Icons.credit_card),
          ),
          ButtonSegment<PaymentMethod>(
            value: PaymentMethod.cash,
            label: Text(Uz.cash),
            icon: Icon(Icons.payments_outlined),
          ),
        ],
        selected: <PaymentMethod>{value},
        onSelectionChanged: (selection) => onChanged(selection.first),
      );
}

/// Sana tanlash maydoni.
class DateField extends StatelessWidget {
  const DateField({
    required this.value,
    required this.onChanged,
    super.key,
    this.label = Uz.date,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
          child: Text(Fmt.day(value)),
        ),
      );
}

/// Matn tanlash uchun chip ro'yxati (kategoriya, tur, tez tugmalar).
class ChipPicker extends StatelessWidget {
  const ChipPicker({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (final option in options)
            ChoiceChip(
              label: Text(option),
              selected: option == value,
              onSelected: (_) => onChanged(option),
            ),
        ],
      );
}
