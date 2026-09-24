import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:my_wallet/core/di/app_providers.dart';
import 'package:my_wallet/core/format/format_context.dart';
import 'package:my_wallet/core/format/money_format.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/security/privacy_mode.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/features/dashboard/application/dashboard_controller.dart';
import 'package:my_wallet/features/household/application/invite_links.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Bosh ekran vidjetiga qiymat yozish (E33-T01). Testda soxta funksiya.
typedef HomeWidgetWriter = Future<void> Function(Map<String, String> data);

/// Android vidjeti nomi (`HomeScreenWidget.kt`).
const homeWidgetName = 'HomeScreenWidget';

final Provider<HomeWidgetWriter> homeWidgetWriterProvider = Provider(
  (ref) => (data) async {
    for (final MapEntry(:key, :value) in data.entries) {
      await HomeWidget.saveWidgetData<String>(key, value);
    }
    await HomeWidget.updateWidget(androidName: homeWidgetName);
  },
);

/// E33-T01: joriy oy qoldig'i, "kuniga ≈ X" va "＋" havolasi vidjetga
/// yoziladi — hisob yoki maxfiylik rejimi (BR-212) o'zgarganda.
class HomeWidgetSync extends ConsumerWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Qiymat o'zgarganda ham, birinchi qurishda ham yoziladi.
    ref
      ..listen(monthReportProvider, (_, _) => unawaited(_write(context, ref)))
      ..listen(privacyModeProvider, (_, _) => unawaited(_write(context, ref)));
    unawaited(_write(context, ref));
    return child;
  }

  Future<void> _write(BuildContext context, WidgetRef ref) async {
    final report = ref.read(monthReportProvider).value;
    if (report == null || !context.mounted) return;
    final l10n = AppL10n.of(context);
    final hidden = ref.read(privacyModeProvider);
    String money(Money amount) => hidden
        ? MoneyText.hiddenValue
        : formatMoney(
            amount.minor,
            currency: amount.currency.code,
            locale: appLocaleOf(context),
          );
    final perDay = report.forecast.perDayAvailable;

    await ref.read(homeWidgetWriterProvider)({
      'title': formatMonthTitle(
        l10n,
        year: report.month.year,
        month: report.month.month,
      ),
      'balance': money(report.summary.balance),
      'per_day': perDay == null ? '' : l10n.dashPerDay(money(perDay)),
      'add_label': '＋ ${l10n.kindExpense}',
      'add_uri': addLink(ref.read(appConfigProvider).env),
    });
  }
}
