import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/widgets/app_card.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/core/widgets/money_text.dart';
import 'package:my_wallet/core/widgets/skeleton.dart';

/// Dizayn tizimi katalogi — faqat dev flavor'da (vizual tekshiruv uchun).
/// Matnlar ataylab tarjima qilinmagan: foydalanuvchiga ko'rinmaydi.
class DesignCatalogScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dizayn katalogi')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Swatch('primary', scheme.primary),
              _Swatch('income', colors.income),
              _Swatch('expense', colors.expense),
              _Swatch('warning', colors.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoneyText(1234567800, style: TextStyle(fontSize: 32)),
                MoneyText(-45000000, tone: MoneyTone.auto),
                MoneyText(12000000, tone: MoneyTone.auto, signed: true),
                MoneyText(12345, currency: 'USD'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Saqlash')),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(onPressed: () {}, child: const Text('Bekor')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Skeleton(width: 200),
          const SizedBox(height: AppSpacing.sm),
          const Skeleton(height: 48),
          const SizedBox(height: AppSpacing.lg),
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: "Hozircha amal yo'q",
            message: "Birinchi xarajatni ＋ tugmasi bilan qo'shing",
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const new(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color),
      label: Text(name),
    );
  }
}
