// E20-T04: E2E — emulyatorda haqiqiy ilova va lokal Supabase (10.0.2.2):
// kirish (email kodi) → sozlash ustasi (maosh kuni bilan) → xarajat →
// kutilgan daromad "Keldi" → Xulosa; oflaynda xarajat → onlayn bo'lganda
// sinxron.
//
//   patrol test --dart-define-from-file=env/dev.json \
//     --dart-define=MAILPIT_URL=http://10.0.2.2:54324
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_wallet/app/app.dart';
import 'package:my_wallet/bootstrap.dart';
import 'package:my_wallet/core/config/app_config.dart';
import 'package:my_wallet/core/settings/app_settings.dart';
import 'package:my_wallet/data/auth/auth_gateway.dart';
import 'package:patrol/patrol.dart';

const _mailpit = String.fromEnvironment(
  'MAILPIT_URL',
  defaultValue: 'http://10.0.2.2:54324',
);

/// Tarmoq so'rovlari (sinxron, auth) uchun kutish chegarasi.
const _network = Duration(seconds: 30);

void main() {
  patrolTest('yangi foydalanuvchi: sozlash → xarajat → daromad → oflayn', (
    $,
  ) async {
    // Oldingi yiqilgan ishga tushirish emulyatorni oflaynda qoldirgan bo'lishi
    // mumkin (holatga qarab ishlaydi — yoqilgan bo'lsa o'chiradi).
    await $.platform.mobile.disableAirplaneMode();
    await $.pumpWidgetAndSettle(
      ProviderScope(
        overrides: [
          ...await prepareApp(AppConfig.fromEnvironment(expected: AppEnv.dev)),
          // Emulyator tili (en-US) emas — matnlar o'zbekcha tekshiriladi.
          languageProvider.overrideWithBuild((ref, _) => const Locale('uz')),
        ],
        child: const MyWalletApp(),
      ),
    );

    // 1. Kirish: email → xatdagi kod (lokal Mailpit).
    final email = 'e2e-${DateTime.now().microsecondsSinceEpoch}@test.local';
    await $(TextField).containing('Email').enterText(email);
    await $('Kod olish').tap();
    await $(TextField).containing('Kod').waitUntilVisible(timeout: _network);
    await $(TextField).containing('Kod').enterText(await _emailCode(email));

    // 2. Sozlash ustasi: boshlang'ich qoldiq va maosh (kutilgan daromad).
    await $('Hisoblar va qoldiq').waitUntilVisible(timeout: _network);
    await $(TextField).containing('Naqd').enterText('1500000');
    await $('Davom etish').tap();
    await $('Maosh jadvali').waitUntilVisible();
    await $(Switch).at(0).tap();
    await $(TextField).containing('Summa').at(0).enterText('8000000');
    // Kun berilmasa reja yaratilmaydi; 1-kun — ro'yxat boshida (o'tgan bo'lsa
    // reja "muddati o'tgan" bo'lib chiqadi).
    await $(DropdownButtonFormField<int>).containing('Kuni').at(0).tap();
    await $('1').last.tap();
    for (var i = 0; i < 3; i++) {
      await $('Davom etish').tap();
    }
    await $('Tayyor!').waitUntilVisible();
    await $('Boshlash').tap();
    // Ilova karkasi — "＋" tugmasi (BottomAppBar markazini u yopadi, shuning
    // uchun u hit-test'dan o'tmaydi).
    await $(FloatingActionButton).waitUntilVisible(timeout: _network);

    // 3. Xarajat: 50 000 — kategoriya bilan.
    await _addExpense($, ['5', '0', '000']);
    await $("50 000 so'm").waitUntilVisible();

    // 4. Kutilayotgan daromad — "Keldi" (joriy oy sozlash ustasida ochilgan).
    await $("To'lovlar").tap();
    await $('Kutilayotgan daromadlar').tap();
    await $('Keldi').at(0).tap();
    // Rejada hisob yo'q (sozlashda tanlanmagan) — qaysi hisobga tushgani.
    await $(ChoiceChip).containing('Naqd').tap();
    await $(FilledButton).containing('Keldi').tap();
    await $('Saqlandi').waitUntilVisible();

    // 5. Oflayn: xarajat navbatga tushadi, tarmoq qaytganda yuboriladi.
    await $('Xulosa').tap();
    await $.platform.mobile.enableAirplaneMode();
    try {
      await _addExpense($, ['1', '2', '000']);
      // Xulosa — oy xarajati jami (50 000 + 12 000), oflaynda lokal bazadan.
      await $("62 000 so'm").waitUntilVisible();
    } finally {
      await $.platform.mobile.disableAirplaneMode();
    }
    await _waitFor(
      $,
      () => find.byTooltip('Sinxronlangan').evaluate().isNotEmpty,
      reason: 'oflayn xarajat sinxronlanmadi',
    );
  });
}

/// ＋ → klaviatura → "Oziq-ovqat" kategoriyasi → Saqlash.
Future<void> _addExpense(PatrolIntegrationTester $, List<String> keys) async {
  await $.tester.tap(find.byTooltip("Amal qo'shish"));
  await $('Yangi amal').waitUntilVisible();
  for (final key in keys) {
    await $.tester.tap(
      find.ancestor(
        of: find.text(key),
        matching: find.byWidgetPredicate(_isButton),
      ),
    );
    await $.pump();
  }
  // Birinchi chiplar — hisoblar; kategoriya nomi bilan (standart shablon).
  final category = $(ChoiceChip).containing('Oziq-ovqat');
  await category.scrollTo();
  await category.tap();
  await $(FilledButton).containing('Saqlash').tap();
  await $(FloatingActionButton).waitUntilVisible();
}

/// Klaviatura tugmasi (raqamlar — TextButton, amallar — FilledButton.tonal).
bool _isButton(Widget widget) => widget is ButtonStyleButton;

/// Mailpit'dagi oxirgi xatdan kirish kodi.
Future<String> _emailCode(String email) async {
  final code = RegExp('\\b\\d{$emailCodeLength}\\b');
  for (var attempt = 0; attempt < 40; attempt++) {
    final search = await http.get(
      Uri.parse('$_mailpit/api/v1/search?query=to:$email'),
    );
    final messages =
        (jsonDecode(search.body) as Map<String, Object?>)['messages']! as List;
    if (messages.isNotEmpty) {
      final id = (messages.first as Map<String, Object?>)['ID'];
      final message = await http.get(Uri.parse('$_mailpit/api/v1/message/$id'));
      final text =
          (jsonDecode(message.body) as Map<String, Object?>)['Text']! as String;
      final match = code.firstMatch(text);
      if (match != null) return match.group(0)!;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  throw StateError('Kod xati kelmadi: $email');
}

/// Shart bajarilguncha kadr chizadi (tarmoq — haqiqiy).
Future<void> _waitFor(
  PatrolIntegrationTester $,
  bool Function() condition, {
  required String reason,
}) async {
  final deadline = DateTime.now().add(_network);
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 500));
    if (condition()) return;
  }
  // Tashxis: ekrandagi holat belgilari (masalan sinxron nishoni matni).
  final tooltips = find
      .byType(Tooltip)
      .evaluate()
      .map((e) => (e.widget as Tooltip).message)
      .whereType<String>()
      .toSet();
  fail('$reason (tooltip: $tooltips)');
}
