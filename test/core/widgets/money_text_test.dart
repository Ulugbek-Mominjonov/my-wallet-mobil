import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/design_system/app_theme.dart';
import 'package:my_wallet/core/design_system/tokens.dart';
import 'package:my_wallet/core/security/privacy_mode.dart';
import 'package:my_wallet/core/widgets/money_text.dart';

const nbsp = ' ';

Future<ProviderContainer> pumpMoney(WidgetTester tester, Widget child) async {
  final container = ProviderContainer.test();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(body: child),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets("summa so'mda, tabular raqamlar bilan", (tester) async {
    await pumpMoney(tester, const MoneyText(123456700));

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.data, contains('1${nbsp}234${nbsp}567'));
    expect(
      text.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('tone=auto: manfiy qizil, musbat yashil (BR-091)', (
    tester,
  ) async {
    await pumpMoney(
      tester,
      const Column(
        children: [
          MoneyText(-100, tone: MoneyTone.auto, key: Key('neg')),
          MoneyText(100, tone: MoneyTone.auto, key: Key('pos')),
        ],
      ),
    );

    Color? colorOf(String key) => tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(Text),
          ),
        )
        .style
        ?.color;
    expect(colorOf('neg'), AppColors.light.expense);
    expect(colorOf('pos'), AppColors.light.income);
  });

  testWidgets('BR-212: maxfiylik rejimida summa yashiriladi', (tester) async {
    final container = await pumpMoney(tester, const MoneyText(5000000));
    expect(find.text(MoneyText.hiddenValue), findsNothing);

    container.read(privacyModeProvider.notifier).toggle();
    await tester.pump();

    expect(find.text(MoneyText.hiddenValue), findsOneWidget);
  });
}
