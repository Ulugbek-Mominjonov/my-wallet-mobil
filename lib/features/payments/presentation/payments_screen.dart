import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/core/widgets/month_switcher.dart';
import 'package:my_wallet/features/payments/application/payments_controller.dart';
import 'package:my_wallet/features/payments/presentation/open_month_card.dart';
import 'package:my_wallet/features/payments/presentation/plan_calendar.dart';
import 'package:my_wallet/features/payments/presentation/plan_tile.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "To'lovlar" (E17): oy rejalari — Xarajatlar / Kutilayotgan daromadlar;
/// ro'yxat (holat bo'limlari) yoki kalendar. Hammasi lokal bazadan, oflayn.
class PaymentsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  bool _calendar = false;
  LocalDate? _day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final month = ref.watch(paymentsMonthProvider);
    final closed = ref.watch(paymentsMonthStateProvider).value?.closed ?? false;
    return DefaultTabController(
      length: PaymentsTab.values.length,
      child: Column(
        children: [
          MonthSwitcher(
            month: month,
            onShift: (months) {
              ref.read(paymentsMonthProvider.notifier).shift(months);
              setState(() => _day = null);
            },
            badge: closed
                ? Icon(Icons.lock, size: 18, semanticLabel: l10n.dashClosed)
                : null,
            actions: [
              IconButton(
                tooltip: _calendar ? l10n.payList : l10n.payCalendar,
                icon: Icon(
                  _calendar ? Icons.view_list_outlined : Icons.calendar_month,
                ),
                onPressed: () => setState(() => _calendar = !_calendar),
              ),
            ],
          ),
          TabBar(
            tabs: [
              Tab(text: l10n.payTabExpenses),
              Tab(text: l10n.payTabIncome),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final tab in PaymentsTab.values)
                  _PlansTab(
                    tab: tab,
                    calendar: _calendar,
                    day: _day,
                    onDay: (day) => setState(() => _day = day),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansTab extends ConsumerWidget {
  const new({
    required this.tab,
    required this.calendar,
    required this.day,
    required this.onDay,
  });

  final PaymentsTab tab;
  final bool calendar;
  final LocalDate? day;
  final ValueChanged<LocalDate> onDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final board = ref.watch(planBoardProvider(tab));
    if (board == null) return const Center(child: CircularProgressIndicator());
    final month = ref.watch(paymentsMonthProvider);
    final today = ref.watch(clockProvider).today();
    final state = ref.watch(paymentsMonthStateProvider).value;
    final canOpen =
        state != null && !state.opened && !month.isBefore(today.monthKey);

    return ListView(
      // Pastdagi ＋ tugmasi oxirgi qatorni yopmasin.
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 96),
      children: [
        const SizedBox(height: AppSpacing.md),
        if (canOpen) OpenMonthCard(month: month),
        _BoardHeader(tab: tab, board: board),
        if (calendar)
          ..._calendarView(context, board, month, today)
        else if (board.isEmpty)
          EmptyState(
            icon: Icons.event_note_outlined,
            title: l10n.payEmpty,
            message: canOpen ? l10n.payEmptyHint : null,
          )
        else
          ..._sections(l10n, board),
      ],
    );
  }

  List<Widget> _calendarView(
    BuildContext context,
    PlanBoard board,
    MonthKey month,
    LocalDate today,
  ) {
    final l10n = AppL10n.of(context);
    final all = [
      ...board.overdue,
      ...board.today,
      ...board.soon,
      ...board.later,
      ...board.paid,
      ...board.skipped,
    ];
    final selected = day ?? (today.monthKey == month ? today : null);
    final ofDay = [
      for (final plan in all)
        if (plan.dueDate == selected) plan,
    ];
    return [
      PlanCalendar(
        month: month,
        plans: all,
        today: today,
        selected: selected,
        onSelect: onDay,
      ),
      const Divider(height: AppSpacing.xl),
      if (selected != null && ofDay.isEmpty)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(child: Text(l10n.payDayEmpty)),
        ),
      for (final plan in ofDay) PlanTile(key: ValueKey(plan.id), plan: plan),
    ];
  }

  List<Widget> _sections(AppL10n l10n, PlanBoard board) {
    final income = tab == PaymentsTab.income;
    Widget section(String title, List<PlannedItem> plans) =>
        _Section(title: title, plans: plans);
    return [
      if (board.overdue.isNotEmpty)
        section(l10n.paySectionOverdue, board.overdue),
      if (board.today.isNotEmpty) section(l10n.paySectionToday, board.today),
      if (board.soon.isNotEmpty)
        section(l10n.paySectionSoon(upcomingDays), board.soon),
      if (board.later.isNotEmpty) section(l10n.paySectionLater, board.later),
      // To'langan va o'tkazilganlar — yig'ilgan.
      if (board.paid.isNotEmpty)
        _Section(
          title: income ? l10n.paySectionReceived : l10n.paySectionPaid,
          plans: board.paid,
          collapsed: true,
        ),
      if (board.skipped.isNotEmpty)
        _Section(
          title: l10n.paySectionSkipped,
          plans: board.skipped,
          collapsed: true,
        ),
    ];
  }
}

/// BR-076: `To'lanmagan: X so'm + N ta ?` (daromadda — kelishi kutilmoqda).
class _BoardHeader extends StatelessWidget {
  const new({required this.tab, required this.board});

  final PaymentsTab tab;
  final PlanBoard board;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final label = tab == PaymentsTab.income
        ? l10n.payIncomePending
        : l10n.payUnpaid;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        children: [
          Text('$label:', style: theme.textTheme.titleSmall),
          MoneyText(
            board.unpaid.minor,
            currency: board.unpaid.currency.code,
            style: theme.textTheme.titleSmall,
          ),
          if (board.unknownCount > 0)
            Text(
              l10n.dashUnknown(board.unknownCount),
              style: theme.textTheme.titleSmall,
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.title, required this.plans, this.collapsed = false});

  final String title;
  final List<PlannedItem> plans;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final header = Text(
      '$title (${plans.length})',
      style: Theme.of(context).textTheme.labelLarge,
    );
    final tiles = [
      for (final plan in plans) PlanTile(key: ValueKey(plan.id), plan: plan),
    ];
    if (collapsed) {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        title: header,
        children: tiles,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, ...tiles],
      ),
    );
  }
}
