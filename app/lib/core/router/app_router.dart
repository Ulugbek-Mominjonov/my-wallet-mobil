import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_gate.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/presentation/add_expense_screen.dart';
import '../../features/funds/presentation/funds_screen.dart';
import '../../features/income/presentation/add_income_screen.dart';
import '../../features/notifications/notification_service.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../l10n/strings.dart';
import '../security/app_lock.dart';
import '../widgets/offline_banner.dart';

/// Pastki navigatsiya — 5 ta bo'lim (§8).
///
/// `StatefulShellRoute` har bo'limning o'z navigatsiya tarixini saqlaydi:
/// xarajat formasidan chiqib, qaytib kirganda holat yo'qolmaydi.
GoRouter createRouter() => GoRouter(
      initialLocation: '/summary',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AuthGate(
            child: AppLockGate(child: _Shell(shell: shell)),
          ),
          branches: <StatefulShellBranch>[
            _branch('/summary', const DashboardScreen()),
            _branch('/income', const AddIncomeScreen()),
            _branch('/expense', const AddExpenseScreen()),
            _branch('/payments', const PaymentsScreen()),
            _branch('/funds', const FundsScreen()),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const AuthGate(child: SettingsScreen()),
        ),
      ],
    );

StatefulShellBranch _branch(String path, Widget screen) =>
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(path: path, builder: (context, state) => screen),
      ],
    );

class _Shell extends ConsumerWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eslatmalar kuzatuvchisi: ilova ochiq bo'lganda kechikkan to'lovlar
    // bo'yicha lokal bildirishnoma ko'rsatadi (server cron'iga qo'shimcha).
    ref
      ..watch(notificationBootstrapProvider)
      ..watch(reminderWatcherProvider);
    return Scaffold(
        body: Column(
          children: <Widget>[
            const OfflineBanner(),
            Expanded(child: shell),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: Uz.tabSummary,
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: Uz.tabIncome,
            ),
            NavigationDestination(
              icon: Icon(Icons.remove_circle_outline),
              selectedIcon: Icon(Icons.remove_circle),
              label: Uz.tabExpense,
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: Uz.tabPayments,
            ),
            NavigationDestination(
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings),
              label: Uz.tabFunds,
            ),
          ],
        ),
      );
  }
}
