import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/security/app_lock.dart';
import '../../../core/widgets/actions.dart';
import '../../../di/providers.dart';
import '../../../di/state_providers.dart';
import 'catalog_screens.dart';
import 'health_screen.dart';
import 'income_rules_screen.dart';
import 'reminders_screen.dart';

/// Sozlamalar — profil ikonkasi orqali ochiladi.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final month = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthSummaryProvider).value;
    final isClosed = summary?.closed ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text(Uz.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: <Widget>[
          if (user != null)
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  (user.displayName ?? user.email ?? '?')
                      .characters
                      .first
                      .toUpperCase(),
                ),
              ),
              title: Text(user.displayName ?? 'Foydalanuvchi'),
              subtitle: Text(user.email ?? user.uid),
            ),
          const Divider(),
          _tile(
            context,
            icon: Icons.repeat,
            title: Uz.recurring,
            subtitle: "Har oy takrorlanadigan to'lovlar",
            screen: const RecurringScreen(),
          ),
          _tile(
            context,
            icon: Icons.speed,
            title: Uz.limits,
            subtitle: "Kategoriya bo'yicha oylik chegara",
            screen: const LimitsScreen(),
          ),
          _tile(
            context,
            icon: Icons.bolt,
            title: Uz.quickAdd,
            subtitle: "Bir bosishda xarajat qo'shish",
            screen: const QuickAddScreen(),
          ),
          _tile(
            context,
            icon: Icons.rule,
            title: Uz.incomeRules,
            subtitle: 'Daromad turi → qaysi oyga tegishli',
            screen: const IncomeRulesScreen(),
          ),
          _tile(
            context,
            icon: Icons.notifications_outlined,
            title: Uz.reminders,
            subtitle: 'Telegram, email, kun va soat',
            screen: const RemindersScreen(),
          ),
          _tile(
            context,
            icon: Icons.health_and_safety_outlined,
            title: Uz.health,
            subtitle: 'Agregatni qayta hisoblab solishtirish',
            screen: const HealthScreen(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text(Uz.openMonth),
            subtitle: Text(
              "${Fmt.monthTitle(month)} — doimiy xarajatlarni ko'chirish",
            ),
            onTap: () => _openMonth(context, ref, month),
          ),
          ListTile(
            leading: Icon(isClosed ? Icons.lock_open : Icons.lock_outline),
            title: Text(isClosed ? Uz.reopenMonth : Uz.closeMonth),
            subtitle: Text(Fmt.monthTitle(month)),
            onTap: () => _toggleLock(context, ref, month, isClosed),
          ),
          const Divider(),
          const _AppLockTile(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(Uz.signOut),
            onTap: () async {
              final ok = await confirm(
                context,
                title: Uz.signOut,
                message: 'Hisobdan chiqasizmi?',
              );
              if (!ok || !context.mounted) return;
              await ref.read(firebaseAuthProvider).signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) =>
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => screen),
        ),
      );

  Future<void> _openMonth(
    BuildContext context,
    WidgetRef ref,
    MonthKey month,
  ) async {
    await runAction(
      context,
      action: () async {
        final plan = await ref.read(openMonthProvider).call(month);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              plan.isEmpty
                  ? 'Barcha qatorlar allaqachon mavjud '
                      '(${plan.skipped} ta)'
                  : "✅ ${plan.created.length} ta reja qatori qo'shildi",
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleLock(
    BuildContext context,
    WidgetRef ref,
    MonthKey month,
    bool isClosed,
  ) async {
    final ok = await confirm(
      context,
      title: isClosed ? Uz.reopenMonth : Uz.closeMonth,
      message: isClosed
          ? '${Fmt.monthTitle(month)} qayta ochilsinmi?'
          : '${Fmt.monthTitle(month)} yopilsinmi? Yozuvlarni tahrirlashda '
              'ogohlantirish chiqadi.',
    );
    if (!ok || !context.mounted) return;
    await runAction(
      context,
      successMessage: isClosed ? '🔓 Oy ochildi' : '🔒 Oy yopildi',
      action: () =>
          ref.read(setMonthLockProvider).call(month, closed: !isClosed),
    );
  }
}

/// 🔒 Lokal qulf tugmasi.
///
/// Sozlama QURILMADA saqlanadi (Firestore'da emas) — qulf hisobga emas,
/// telefonga tegishli.
class _AppLockTile extends ConsumerStatefulWidget {
  const _AppLockTile();

  @override
  ConsumerState<_AppLockTile> createState() => _AppLockTileState();
}

class _AppLockTileState extends ConsumerState<_AppLockTile> {
  @override
  Widget build(BuildContext context) {
    final service = ref.watch(appLockProvider);
    if (service == null) return const SizedBox.shrink();

    return SwitchListTile(
      secondary: const Icon(Icons.lock_outline),
      title: const Text('Qulf (PIN / biometrika)'),
      subtitle: const Text("Ilovani ochishda tasdiqlash so'raladi"),
      value: service.isEnabled,
      onChanged: (value) async {
        final available = await service.isAvailable;
        if (value && !available) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Qurilmada PIN yoki biometrika sozlanmagan'),
            ),
          );
          return;
        }
        await service.setEnabled(value: value);
        if (mounted) setState(() {});
      },
    );
  }
}
