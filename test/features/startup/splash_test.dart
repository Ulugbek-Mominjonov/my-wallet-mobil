import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../../support/fake_startup.dart';
import '../../support/pump_app.dart';

void main() {
  testWidgets('yuklanmoqda — indikator', (tester) async {
    await pumpApp(tester, startup: const StartupLoading(), settle: false);
    expect(find.text('Byudjet yuklanmoqda…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('oflayn — sabab va qayta urinish', (tester) async {
    final controller = FakeStartupController(
      const StartupFailed(OfflineFailure()),
    );
    await pumpApp(tester, startupController: controller);

    expect(find.text("Ma'lumotni yuklab bo'lmadi"), findsOneWidget);
    expect(find.text("Internet yo'q — ulanishni tekshiring"), findsOneWidget);

    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();
    expect(controller.calls, ['reload']);
  });

  testWidgets('sessiya eskirgan — qayta kirish matni va chiqish tugmasi', (
    tester,
  ) async {
    await pumpApp(tester, startup: const StartupFailed(UnauthorizedFailure()));
    expect(find.text('Qayta kirish kerak'), findsOneWidget);
    expect(find.text('Chiqish'), findsOneWidget);
  });
}
