import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/main.dart';

void main() {
  testWidgets('ilova ishga tushadi', (tester) async {
    await tester.pumpWidget(const MyWalletApp());

    expect(find.text('My Wallet'), findsOneWidget);
  });
}
