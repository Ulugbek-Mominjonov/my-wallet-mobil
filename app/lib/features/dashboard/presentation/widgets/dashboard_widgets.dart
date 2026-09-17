import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/l10n/strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/money_text.dart';

/// Oyning asosiy ko'rsatkichi — QOLDIQ.
class BalanceHero extends StatelessWidget {
  const BalanceHero({required this.summary, super.key});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            scheme.primaryContainer,
            Color.alphaBlend(
              scheme.primary.withValues(alpha: 0.12),
              scheme.surfaceContainerHigh,
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            Uz.balance,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          MoneyText(
            summary.balance,
            withSuffix: true,
            colorBySign: true,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                summary.saved.isNegative
                    ? Icons.trending_down
                    : Icons.trending_up,
                size: 18,
                color: summary.saved.soum.signColor,
              ),
              const SizedBox(width: 6),
              Text('${Uz.saved}: ', style: theme.textTheme.bodyMedium),
              MoneyText(
                summary.saved,
                colorBySign: true,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${Fmt.percent(summary.savedRatio)})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kichik ko'rsatkich plitasi.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.color,
    this.onTap,
  });

  final String label;
  final Money value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: 16,
                    color: color ?? theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            MoneyText(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nomi + summasi bo'lgan qator (kategoriya / daromad turi kesimi).
class BreakdownRow extends StatelessWidget {
  const BreakdownRow({
    required this.label,
    required this.value,
    required this.ratio,
    super.key,
    this.subtitle,
    this.color,
  });

  final String label;
  final Money value;
  final double ratio;
  final String? subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
              MoneyText(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 6),
          ProgressBar(value: ratio, color: color),
        ],
      ),
    );
  }
}

/// 👤 va 🏦 fondlar plitasi.
class FundTile extends StatelessWidget {
  const FundTile({
    required this.emoji,
    required this.title,
    required this.amount,
    required this.color,
    super.key,
    this.subtitle,
    this.onTap,
  });

  final String emoji;
  final String title;
  final Money amount;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$emoji  $title', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            MoneyText(
              amount,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Prognoz kartasi (§2.9).
class ForecastCard extends StatelessWidget {
  const ForecastCard({required this.forecast, super.key});

  final MonthForecast forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: '📉 ${Uz.forecast}',
      child: Column(
        children: <Widget>[
          _row(context, Uz.dailyBurn, Fmt.moneyLong(forecast.dailyBurn)),
          _row(
            context,
            '${Uz.monthEnd} sarf',
            Fmt.moneyLong(forecast.monthEndSpend),
          ),
          if (forecast.isCurrentMonth)
            _row(
              context,
              Uz.expectedIncome,
              Fmt.moneyLong(forecast.expectedIncome),
            ),
          const Divider(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${Uz.monthEnd} qoldiq',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              MoneyText(
                forecast.monthEndBalance,
                colorBySign: true,
                withSuffix: true,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (forecast.isIncomePending)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Oyning ${forecast.daysPassed}-kuni. '
                'Hali kelmagan daromad hisobga olindi.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontFeatures: tabularFigures)),
        ],
      ),
    );
  }
}
