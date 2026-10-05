import 'package:flutter/material.dart';

/// Mayda kulrang yorliq (katta raqam yoki ro'yxat ustida): "QOLDIQ",
/// "BU OY", "HISOBLAR". Tipografika mavzudan (`labelSmall`) — bitta joyda.
class SectionLabel extends StatelessWidget {
  const new(this.text, {super.key, this.trailing});

  final String text;

  /// O'ng chetdagi qo'shimcha (masalan "Hammasi" tugmasi).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = Text(
      text.toUpperCase(),
      // Ekranda katta harf, TalkBack esa odatdagidek o'qiydi.
      semanticsLabel: text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    if (trailing == null) return label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [label, trailing!],
    );
  }
}
