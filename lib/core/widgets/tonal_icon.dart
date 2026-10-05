import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';

/// Ro'yxat qatorining chap belgisi: doira ichida piktogramma. Rang ma'noga
/// qarab (daromad yashil, xarajat qizil, qolgani neytral) — ro'yxat bir
/// qarashda o'qiladi, lekin rang faqat yordamchi belgi (ma'no matnda ham bor).
enum IconTone { neutral, income, expense }

class TonalIcon extends StatelessWidget {
  const new(this.icon, {super.key, this.tone = IconTone.neutral});

  final IconData icon;
  final IconTone tone;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final color = switch (tone) {
      IconTone.income => colors.income,
      IconTone.expense => colors.expense,
      IconTone.neutral => theme.colorScheme.onSurfaceVariant,
    };

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        // Juda och fon: matn kontrastiga ta'sir qilmaydi.
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
