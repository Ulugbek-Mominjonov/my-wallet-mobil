import 'package:flutter/material.dart';

import '../l10n/strings.dart';

/// Sarlavhali karta — barcha ekranlarda bir xil ko'rinish.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.title,
    this.action,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (action != null) action!,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Bo'sh holat — "hozircha yozuv yo'q".
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.message = Uz.empty,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 40, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Yuklanish paytidagi "skelet" — spinner emas, chunki sakrash kamroq.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width = double.infinity,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
      );
}

/// Xato holati — qayta urinish tugmasi bilan.
class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text(Uz.retry)),
            ],
          ],
        ),
      );
}

/// Progress chizig'i — limit va maqsadlar uchun.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    required this.value,
    super.key,
    this.color,
    this.height = 8,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: scheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? scheme.primary),
      ),
    );
  }
}

/// Bitta variantni tanlash qatori.
///
/// `RadioListTile` o'rniga: Flutter'ning yangi versiyasida `groupValue`
/// eskirgan, `RadioGroup` esa bu yerda ortiqcha murakkablik bo'lardi.
class SelectTile extends StatelessWidget {
  const SelectTile({
    required this.title,
    required this.selected,
    required this.onTap,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        selected: selected,
        onTap: onTap,
      );
}
