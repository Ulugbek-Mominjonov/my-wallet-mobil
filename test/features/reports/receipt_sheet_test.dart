import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/share/file_sharer.dart';
import 'package:my_wallet/data/local/daos/report_dao.dart';
import 'package:my_wallet/features/reports/application/receipt_controller.dart';
import 'package:my_wallet/features/reports/domain/receipt.dart';
import 'package:my_wallet/features/reports/presentation/receipt_sheet.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';
import 'package:wallet_domain/wallet_domain.dart';

final _month = MonthKey.parse('2026-10');

ReceiptEntry _entry({
  required String id,
  required ReceiptLine line,
  required String name,
  required int amount,
}) => (
  id: id,
  line: line,
  occurredOn: '2026-10-03',
  amount: Money(amount),
  name: name,
  category: 'Kategoriya',
  account: line == ReceiptLine.fundSpent ? 'Shaxsiy fond' : 'Karta',
);

final _receipt = Receipt(
  household: 'Oila byudjeti',
  month: _month,
  entries: [
    _entry(
      id: 'i1',
      line: ReceiptLine.income,
      name: 'Oylik',
      amount: 500000000,
    ),
    _entry(
      id: 'e1',
      line: ReceiptLine.expense,
      name: 'Bozor',
      amount: 12000000,
    ),
    _entry(
      id: 'e2',
      line: ReceiptLine.fundSpent,
      name: 'Taksi',
      amount: 3000000,
    ),
    _entry(
      id: 'a1',
      line: ReceiptLine.allocation,
      name: 'Shaxsiy fond',
      amount: 20000000,
    ),
  ],
  balances: {'Karta': const Money(488000000)},
  base: Currency.uzs,
);

void main() {
  late List<String> sharedText;
  late List<({String name, int bytes})> sharedFiles;

  Future<void> pumpSheet(WidgetTester tester) async {
    sharedText = [];
    sharedFiles = [];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          receiptProvider(_month).overrideWith((ref) async => _receipt),
          textSharerProvider.overrideWithValue(
            (text) async => sharedText.add(text),
          ),
          fileSharerProvider.overrideWithValue((
            file, {
            required fileName,
            required text,
          }) async {
            sharedFiles.add((
              name: fileName,
              bytes: (await file.readAsBytes()).length,
            ));
          }),
        ],
        child: MaterialApp(
          locale: const Locale('uz'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(body: ReceiptSheet(_month)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('matn sifatida ulashish — ro‘yxat va jamlar bilan', (
    tester,
  ) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Matn sifatida ulashish'));
    await tester.pumpAndSettle();

    expect(sharedText, hasLength(1));
    expect(sharedText.single, contains('Oila byudjeti'));
    expect(sharedText.single, contains('03.10  Bozor'));
    expect(sharedText.single, contains('Taksi (fonddan)'));
    // Fondga ajratma — alohida bo'limda (BR-061).
    expect(sharedText.single, contains('FONDGA AJRATMA'));
    expect(sharedText.single, contains('Shaxsiy fond'));
  });

  testWidgets('fond o‘chirilsa — chek matnida ham chiqmaydi', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Matn sifatida ulashish'));
    await tester.pumpAndSettle();

    expect(sharedText.single, isNot(contains('Taksi')));
    expect(sharedText.single, contains('Bozor'));
  });

  testWidgets('PDF: fayl nomi oy bilan, ichida haqiqiy PDF', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('PDF qilib ulashish'));
    await tester.pumpAndSettle();

    expect(sharedFiles, hasLength(1));
    expect(sharedFiles.single.name, 'chek-2026-10.pdf');
    // Bo'sh bo'lmagan hujjat (shriftlar ham ichida).
    expect(sharedFiles.single.bytes, greaterThan(1000));
  });
}
