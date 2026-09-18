import 'package:flutter/widgets.dart';
import 'package:my_wallet/core/format/money_format.dart';

/// Joriy UI tili (formatlash uchun). Qo'llab-quvvatlanmagan til — o'zbekcha.
AppLocale appLocaleOf(BuildContext context) {
  final code = Localizations.maybeLocaleOf(context)?.languageCode;
  return AppLocale.values.asNameMap()[code] ?? AppLocale.uz;
}
