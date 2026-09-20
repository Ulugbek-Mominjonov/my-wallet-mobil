import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip("Amal qo'shish"));
    await tester.pumpAndSettle();
  }

  Future<void> tapKeys(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await tester.tap(find.widgetWithText(TextButton, key));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('summa klaviaturasi: raqamlar, 000 va jonli format', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text('Xarajat'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saqlash'))
          .onPressed,
      isNull,
      reason: 'summa kiritilmagan',
    );

    await tapKeys(tester, ['1', '2', '000']);
    expect(find.text("12 000 so'm"), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saqlash'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('oddiy hisob: 12 000 + 3 000 = 15 000', (tester) async {
    await openSheet(tester);
    await tapKeys(tester, ['1', '2', '000', '+']);
    expect(find.textContaining('+'), findsWidgets);
    await tapKeys(tester, ['3', '000', '=']);
    expect(find.text("15 000 so'm"), findsOneWidget);
  });

  testWidgets('⌫ va tur almashtirish', (tester) async {
    await openSheet(tester);
    await tapKeys(tester, ['5', '000']);
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    expect(find.text("500 so'm"), findsOneWidget);

    await tester.tap(find.text('Daromad'));
    await tester.pumpAndSettle();
    // Tur o'zgarsa ham summa qoladi.
    expect(find.text("500 so'm"), findsOneWidget);
  });
}
