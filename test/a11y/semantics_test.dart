import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/local/database.dart';

import '../features/payments/payments_harness.dart';
import '../features/wallet/wallet_harness.dart';
import '../support/test_database.dart';

/// E20-T03: TalkBack o'qiydigan nomlar — yashirin summa va reja holati
/// (faqat rang/belgi bilan emas).
void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('maxfiylik rejimida summa — «Summa yashirin»', (tester) async {
    final semantics = tester.ensureSemantics();
    await seedWallet(db);
    await pumpWallet(tester, db);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
    // Qator semantikasi birlashadi — nom uning ichida.
    expect(find.bySemanticsLabel(RegExp('Summa yashirin')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('•••')), findsNothing);
    semantics.dispose();
  });

  testWidgets('reja holati belgisi nomlangan', (tester) async {
    final semantics = tester.ensureSemantics();
    await seedPayments(db);
    await pumpWallet(tester, db, path: '/payments');
    // Qator semantikasi birlashadi: holat nomi reja nomidan oldin o'qiladi.
    final labels = _labels(tester);
    expect(labels.where((l) => l.contains('Kechikkan\nIjara')), hasLength(1));
    expect(labels.where((l) => l.contains('Kutilmoqda\nKurs')), hasLength(1));
    semantics.dispose();
  });
}

/// Semantika daraxtidagi barcha yorliqlar.
List<String> _labels(WidgetTester tester) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    if (node.label.isNotEmpty) labels.add(node.label);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return labels;
}
