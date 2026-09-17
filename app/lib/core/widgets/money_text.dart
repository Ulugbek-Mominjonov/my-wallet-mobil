import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../format/formatters.dart';
import '../theme/app_theme.dart';

/// Pul summasi — bir xil kenglikdagi raqamlar bilan.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.value, {
    super.key,
    this.style,
    this.colorBySign = false,
    this.compact = false,
    this.withSuffix = false,
  });

  final Money value;
  final TextStyle? style;

  /// Manfiy bo'lsa qizil, musbat bo'lsa yashil.
  final bool colorBySign;
  final bool compact;
  final bool withSuffix;

  @override
  Widget build(BuildContext context) {
    final text = compact
        ? Fmt.moneyCompact(value)
        : (withSuffix ? Fmt.moneyLong(value) : Fmt.money(value));
    return Text(
      text,
      style: (style ?? DefaultTextStyle.of(context).style).copyWith(
        fontFeatures: tabularFigures,
        color: colorBySign ? value.soum.signColor : style?.color,
      ),
    );
  }
}
