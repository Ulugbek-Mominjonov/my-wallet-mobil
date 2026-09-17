import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../format/formatters.dart';

/// Oy tanlash — o'q tugmalari va bosib tanlash.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    super.key,
    this.onTap,
    this.isClosed = false,
  });

  final MonthKey month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onTap;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Oldingi oy',
        ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: <Widget>[
                  Text(
                    Fmt.monthTitle(month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isClosed)
                    Text(
                      '🔒 yopilgan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Keyingi oy',
        ),
      ],
    );
  }
}
