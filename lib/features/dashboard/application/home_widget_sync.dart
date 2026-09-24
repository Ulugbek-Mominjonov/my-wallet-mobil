import 'dart:async';

import 'package:flutter/foundation.dart' show mapEquals;
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
import 'package:my_wallet/features/dashboard/application/month_report.dart';
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
/// yoziladi — hisob yoki maxfiylik rejimi (BR-212) o'zgarganda. Qiymat
/// o'zgarmagan bo'lsa yozilmaydi (har qayta qurishda diskka tegmaydi).
class HomeWidgetSync extends ConsumerStatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends ConsumerState<HomeWidgetSync> {
  Map<String, String>? _written;

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(monthReportProvider).value;
    final hidden = ref.watch(privacyModeProvider);
    if (report != null) unawaited(_write(report, hidden: hidden));
    return widget.child;
  }

  Future<void> _write(MonthReport report, {required bool hidden}) async {
    final l10n = AppL10n.of(context);
    String money(Money amount) => hidden
        ? MoneyText.hiddenValue
        : formatMoney(
            amount.minor,
            currency: amount.currency.code,
            locale: appLocaleOf(context),
          );
    final perDay = report.forecast.perDayAvailable;
    final data = {
      'title': formatMonthTitle(
        l10n,
        year: report.month.year,
        month: report.month.month,
      ),
      'balance': money(report.summary.balance),
      'per_day': perDay == null ? '' : l10n.dashPerDay(money(perDay)),
      'add_label': '＋ ${l10n.kindExpense}',
      'add_uri': addLink(ref.read(appConfigProvider).env),
    };
    if (mapEquals(_written, data)) return;
    _written = data;
    await ref.read(homeWidgetWriterProvider)(data);
  }
}
