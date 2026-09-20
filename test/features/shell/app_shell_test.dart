import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/remote/dto.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/data/sync/sync_status.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';

void main() {
  StartupState twoHouseholds() {
    final boot = AppBootstrap.fromJson(
      bootstrapJson(
        households: [
          householdJson(id: 'h1'),
          householdJson(id: 'h2', name: 'Oila', role: 'member'),
        ],
      ),
    );
    return StartupReady(boot.households.first, boot);
  }

  testWidgets("qobiqda byudjet nomi; bitta byudjetda strelka yo'q", (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.widgetWithText(AppBar, 'Uy'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });

  testWidgets('almashtirgich: ro\'yxat, tanlov va "yangi byudjet"', (
    tester,
  ) async {
    final controller = FakeStartupController(twoHouseholds());
    await pumpApp(tester, startupController: controller);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    await tester.tap(find.text('Uy'));
    await tester.pumpAndSettle();
    expect(find.text('Oila'), findsOneWidget);
    expect(find.text('member'), findsOneWidget);

    await tester.tap(find.text('Oila'));
    await tester.pumpAndSettle();
    expect(controller.calls, ['select:h2']);

    await tester.tap(find.text('Uy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yangi byudjet yoki taklif kodi'));
    await tester.pumpAndSettle();
    expect(find.text('Byudjetni boshlang'), findsOneWidget);
  });

  testWidgets('oflayn banneri sinxron holatidan', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        syncStatusProvider.overrideWith(
          (ref) => Stream.value(
            const SyncStatus(pendingCount: 2, lastFailure: OfflineFailure()),
          ),
        ),
      ],
    );
    expect(
      find.text("Oflayn — o'zgarishlar tarmoq kelganda yuboriladi"),
      findsOneWidget,
    );
  });

  testWidgets("texnik ishlar banneri — tilga mos, muddati o'tgani yo'q", (
    tester,
  ) async {
    final boot = AppBootstrap.fromJson(
      bootstrapJson(
        config: {
          'maintenance': {
            'message': {'uz': 'Texnik ishlar', 'ru': 'Техработы'},
            'until': '2099-01-01T00:00:00Z',
          },
        },
      ),
    );
    await pumpApp(tester, startup: StartupReady(boot.households.first, boot));
    expect(find.text('Texnik ishlar'), findsOneWidget);

    final expired = AppBootstrap.fromJson(
      bootstrapJson(
        config: {
          'maintenance': {
            'message': {'uz': 'Eski xabar'},
            'until': '2020-01-01T00:00:00Z',
          },
        },
      ),
    );
    expect(expired.maintenance!.isActive(DateTime.now()), isFalse);
  });

  testWidgets("profil menyusi — chiqish tasdig'i", (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Chiqish'), findsOneWidget);
  });
}
