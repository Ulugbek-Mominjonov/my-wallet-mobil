import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/widgets/empty_state.dart';
import 'package:my_wallet/features/dashboard/presentation/dashboard_screen.dart';

import '../support/pump_app.dart';

/// Bo'lim sarlavhasi — mazmun ichida (pastki navigatsiyada ham shu matn bor).
Finder tabTitle(String title) =>
    find.descendant(of: find.byType(EmptyState), matching: find.text(title));

void main() {
  testWidgets('ilova Xulosa bo‘limida ochiladi', (tester) async {
    await pumpApp(tester);

    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('tablar orasida o‘tish', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Amallar'));
    await tester.pumpAndSettle();
    // Amallar bo'limi (E15-T06): bo'sh oy — mos xabar.
    expect(find.text("Bu oyda amal yo'q"), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Hamyon'));
    await tester.pumpAndSettle();
    expect(tabTitle('Hamyon'), findsOneWidget);
  });

  testWidgets('＋ tugmasi yangi amal sahifasini ochadi va yopiladi', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip("Amal qo'shish"));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Yangi amal'), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets("noma'lum yo'l — 404 va bosh sahifaga qaytish", (tester) async {
    final router = await pumpApp(tester);

    router.go('/mavjud-emas');
    await tester.pumpAndSettle();
    expect(find.text('Sahifa topilmadi'), findsOneWidget);

    await tester.tap(find.text('Bosh sahifaga'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('dizayn katalogi dev flavorda ochiladi', (tester) async {
    final router = await pumpApp(tester);

    router.go('/dev/catalog');
    await tester.pumpAndSettle();
    expect(find.text('Dizayn katalogi'), findsOneWidget);
  });

  testWidgets('dizayn katalogi prod flavorda mavjud emas', (tester) async {
    final router = await pumpApp(tester, env: AppEnv.prod);

    router.go('/dev/catalog');
    await tester.pumpAndSettle();
    expect(find.text('Sahifa topilmadi'), findsOneWidget);
  });
}
