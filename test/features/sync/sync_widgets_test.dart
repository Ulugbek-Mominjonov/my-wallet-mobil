import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_wallet/core/design_system/app_theme.dart';
import 'package:my_wallet/core/format/time_format.dart';
import 'package:my_wallet/data/auth/auth_providers.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/data/sync/sync_scheduler.dart';
import 'package:my_wallet/data/sync/sync_status.dart';
import 'package:my_wallet/features/sync/presentation/sync_status_badge.dart';
import 'package:my_wallet/features/sync/presentation/sync_status_screen.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_auth.dart';

SyncIssueRow issue(int id, String status, {String? code}) => SyncIssueRow(
  id: id,
  householdId: 'h',
  mutationId: 'm$id',
  targetTable: 'transactions',
  recordId: 'r$id',
  status: status,
  code: code,
  localData: '{}',
  createdAt: DateTime.utc(2026, 10, 5, 4),
);

Future<void> pumpScreen(
  WidgetTester tester, {
  required SyncStatus? status,
  List<Override> overrides = const [],
  Widget home = const SyncStatusScreen(),
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        // Nishon — ilova panelida, ekran — o'zi.
        builder: (_, _) => home is SyncStatusBadge
            ? Scaffold(appBar: AppBar(actions: [home]))
            : home,
      ),
      GoRoute(path: '/sync', builder: (_, _) => const SyncStatusScreen()),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncStatusProvider.overrideWith((ref) => Stream.value(status)),
        authGatewayProvider.overrideWithValue(
          FakeAuthGateway(currentUserId: 'u1'),
        ),
        ...overrides,
      ],
      child: MaterialApp.router(
        theme: buildAppTheme(Brightness.light),
        locale: const Locale('uz'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SyncStatusBadge', () {
    final cases = <SyncStatus, (IconData, String)>{
      const SyncStatus(): (Icons.cloud_done_outlined, 'Sinxronlangan'),
      const SyncStatus(running: true): (Icons.sync, 'Yuborilmoqda…'),
      const SyncStatus(pendingCount: 2): (
        Icons.cloud_upload_outlined,
        "2 ta o'zgarish yuborilmagan",
      ),
      const SyncStatus(lastFailure: OfflineFailure()): (
        Icons.cloud_off_outlined,
        'Oflayn — tarmoq kelganda yuboriladi',
      ),
      SyncStatus(issues: [issue(1, 'conflict'), issue(2, 'rejected')]): (
        Icons.warning_amber_rounded,
        '2 ta muammo',
      ),
      const SyncStatus(lastFailure: UnauthorizedFailure()): (
        Icons.lock_outline,
        'Qayta kirish kerak',
      ),
    };
    for (final MapEntry(key: status, value: (icon, label)) in cases.entries) {
      testWidgets('${status.phase.name}: $label', (tester) async {
        await pumpScreen(tester, status: status, home: const SyncStatusBadge());
        expect(find.byIcon(icon), findsOneWidget);
        expect(find.byTooltip(label), findsOneWidget);
      });
    }

    testWidgets("byudjet tanlanmagan — ko'rinmaydi", (tester) async {
      await pumpScreen(tester, status: null, home: const SyncStatusBadge());
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('bosilsa — holat ekrani', (tester) async {
      await pumpScreen(
        tester,
        status: const SyncStatus(),
        home: const SyncStatusBadge(),
      );
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.text('Sinxron holati'), findsOneWidget);
    });
  });

  group('SyncStatusScreen', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets(
      "muammolar: to'qnashuvda 'mening versiyam', rad etishda — kod",
      (tester) async {
        await pumpScreen(
          tester,
          status: SyncStatus(
            issues: [
              issue(1, 'conflict'),
              issue(2, 'rejected', code: 'month_closed'),
            ],
            lastPullAt: DateTime.now().toUtc(),
            pendingCount: 3,
          ),
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );
        expect(find.text('Mening versiyam'), findsOneWidget);
        expect(find.text('Tushunarli'), findsNWidgets(2));
        expect(find.textContaining('month_closed'), findsOneWidget);
        expect(find.textContaining('Oxirgi sinxron:'), findsOneWidget);
        expect(find.text("3 ta o'zgarish yuborilmagan"), findsOneWidget);
      },
    );

    testWidgets('hozir sinxronlash — rejalashtiruvchi orqali', (tester) async {
      var runs = 0;
      final scheduler = SyncScheduler(() async {
        runs++;
        return const SyncReport();
      });
      addTearDown(scheduler.dispose);
      await pumpScreen(
        tester,
        status: const SyncStatus(),
        overrides: [
          syncSchedulerProvider.overrideWith((ref) async => scheduler),
        ],
      );
      expect(find.text('Hali sinxronlanmagan'), findsOneWidget);
      await tester.tap(find.text('Hozir sinxronlash'));
      await tester.pumpAndSettle();
      expect(runs, 1);
    });

    testWidgets("to'liq qayta yuklash — tasdiq so'raladi", (tester) async {
      await pumpScreen(
        tester,
        status: const SyncStatus(),
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      await tester.tap(find.text("To'liq qayta yuklash"));
      await tester.pumpAndSettle();
      expect(
        find.textContaining("Yuborilmagan o'zgarishlar saqlanadi"),
        findsOneWidget,
      );
      await tester.tap(find.text('Bekor qilish'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('holat yuklanmoqda — indikator', (tester) async {
      final pending = StreamController<SyncStatus?>();
      addTearDown(pending.close);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SyncStatusScreen()),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [syncStatusProvider.overrideWith((ref) => pending.stream)],
          child: MaterialApp.router(
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  test('vaqt: bugun — soat, aks holda sana bilan', () {
    final now = DateTime(2026, 10, 5, 12);
    expect(formatEventTime(DateTime(2026, 10, 5, 9, 7), now: now), '09:07');
    expect(
      formatEventTime(DateTime(2026, 10, 4, 23, 59), now: now),
      '04.10 23:59',
    );
  });
}
