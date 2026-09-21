import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/format/format_context.dart';
import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/core/security/privacy_mode.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Summa rangi: `auto` — manfiy qizil, musbat yashil (qoldiq uchun).
enum MoneyTone { neutral, auto, income, expense }

/// Summalar FAQAT shu vidjet orqali chiqariladi: tabular raqamlar, bir xil
/// format va maxfiylik rejimi (BR-212) bitta joyda.
class MoneyText extends ConsumerWidget {
  const new(
    this.minor, {
    super.key,
    this.currency = 'UZS',
    this.tone = MoneyTone.neutral,
    this.signed = false,
    this.style,
  });

  /// Eng kichik birlikdagi summa (tiyin/sent).
  final int minor;
  final String currency;
  final MoneyTone tone;
  final bool signed;
  final TextStyle? style;

  static const hiddenValue = '•••';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(privacyModeProvider);
    final text = hidden
        ? hiddenValue
        : formatMoney(
            minor,
            currency: currency,
            locale: appLocaleOf(context),
            signed: signed,
          );
    final base = style ?? DefaultTextStyle.of(context).style;

    return Text(
      text,
      // TalkBack "•••" ni belgi-belgi o'qimasin.
      semanticsLabel: hidden
          ? Localizations.of<AppL10n>(context, AppL10n)?.amountHidden
          : null,
      maxLines: 1,
      softWrap: false,
      style: base.copyWith(
        color: _color(context) ?? base.color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Color? _color(BuildContext context) {
    final colors = context.appColors;
    return switch (tone) {
      MoneyTone.income => colors.income,
      MoneyTone.expense => colors.expense,
      MoneyTone.auto when minor < 0 => colors.expense,
      MoneyTone.auto when minor > 0 => colors.income,
      MoneyTone.auto || MoneyTone.neutral => null,
    };
  }
}

/// Summa matn ichida (masalan "Kuniga ≈ X") — [MoneyText] bilan bir xil
/// format va maxfiylik rejimi (BR-212).
String moneyLabel(BuildContext context, WidgetRef ref, Money amount) =>
    ref.watch(privacyModeProvider)
    ? MoneyText.hiddenValue
    : formatMoney(
        amount.minor,
        currency: amount.currency.code,
        locale: appLocaleOf(context),
      );
