import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/features/payments/presentation/plan_tile.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// E17-T05: oy to'ri — kunlarda holat rangidagi nuqtalar; kun bosilsa
/// shu kun rejalari ([onSelect]). Hafta boshi — lokal (uz/ru: dushanba).
class PlanCalendar extends StatelessWidget {
  const new({
    required this.month,
    required this.plans,
    required this.today,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final MonthKey month;
  final List<PlannedItem> plans;
  final LocalDate today;
  final LocalDate? selected;
  final ValueChanged<LocalDate> onSelect;

  /// Kunda ko'pi bilan shuncha nuqta.
  static const int _maxDots = 3;
  static const double _dotSize = 6;
  static const int _week = DateTime.daysPerWeek;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstWeekday = localizations.firstDayOfWeekIndex; // 0 — yakshanba.
    final weekdays = [
      for (var i = 0; i < _week; i++)
        localizations.narrowWeekdays[(firstWeekday + i) % _week],
    ];
    // DateTime.weekday: 1 — dushanba … 7 — yakshanba.
    final offset = (month.firstDay.weekday % _week - firstWeekday) % _week;
    final byDay = <int, List<PlannedStatus>>{};
    for (final plan in plans) {
      if (plan.dueDate.monthKey != month) continue;
      (byDay[plan.dueDate.day] ??= []).add(PlannedStatus.of(plan, today));
    }

    return Column(
      children: [
        Row(
          children: [
            for (final day in weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.count(
          crossAxisCount: _week,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < offset; i++) const SizedBox.shrink(),
            for (var day = 1; day <= month.daysInMonth; day++)
              _DayCell(
                date: LocalDate(month.year, month.month, day),
                statuses: byDay[day] ?? const [],
                today: today,
                selected: selected,
                onSelect: onSelect,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const new({
    required this.date,
    required this.statuses,
    required this.today,
    required this.selected,
    required this.onSelect,
  });

  final LocalDate date;
  final List<PlannedStatus> statuses;
  final LocalDate today;
  final LocalDate? selected;
  final ValueChanged<LocalDate> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = date == selected;
    final isToday = date == today;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      onTap: () => onSelect(date),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xs / 2),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: isToday ? Border.all(color: scheme.primary) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${date.day}'),
            const SizedBox(height: AppSpacing.xs / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final status in statuses.take(PlanCalendar._maxDots))
                  Container(
                    width: PlanCalendar._dotSize,
                    height: PlanCalendar._dotSize,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs / 4,
                    ),
                    decoration: BoxDecoration(
                      color: planStatusColor(context, status),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
