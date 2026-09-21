import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/core/logging/app_log.dart';
import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/core/notifications/push_service.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Push turi (`data.type`, contracts/api.md) → ochiladigan ekran. Faqat shu
/// oq ro'yxat — tashqaridan kelgan qiymat marshrut sifatida ishlatilmaydi.
const Map<String, String> pushRoutes = {
  'daily_reminder': '/payments',
  'income_missing': '/payments',
  'limit_alert': '/wallet/limits',
  'monthly_report': '/',
  'test': '/',
};

/// Lokal eslatma/push bosilganda ochilishi mumkin bo'lgan marshrutlar.
const Set<String> notificationRoutes = {'/', '/payments', '/wallet/limits'};

/// Push turi → marshrut (noma'lum — Xulosa).
String pushRoute(String? type) => pushRoutes[type] ?? '/';

/// Bildirishnoma bosilganda ochiladigan marshrutlar (push va lokal
/// eslatmalar); ilova ildizi tinglaydi va o'tadi.
final StreamProvider<String> notificationTapsProvider = StreamProvider((ref) {
  final push = ref.watch(pushServiceProvider);
  final local = ref.watch(localNotifierProvider);
  final controller = StreamController<String>();
  final subscriptions = [
    push.openedMessages.listen((m) => controller.add(pushRoute(m.type))),
    local.taps.listen((payload) {
      if (notificationRoutes.contains(payload)) controller.add(payload);
    }),
  ];
  unawaited(
    push.initialMessage().then((message) {
      if (message != null) controller.add(pushRoute(message.type));
    }),
  );
  ref.onDispose(() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await controller.close();
  });
  return controller.stream;
});

/// Ilova ochiq paytida kelgan push — tizim ko'rsatmaydi, lokal
/// bildirishnoma bilan ko'rsatiladi (bosilsa — tegishli ekran).
final Provider<void> foregroundPushProvider = Provider((ref) {
  final local = ref.watch(localNotifierProvider);
  final subscription = ref.watch(pushServiceProvider).foregroundMessages.listen(
    (message) {
      final title = message.title;
      if (title == null) return;
      unawaited(
        local.show(
          title: title,
          body: message.body ?? '',
          payload: pushRoute(message.type),
        ),
      );
    },
  );
  ref.onDispose(subscription.cancel);
});

/// E19-T01: FCM tokeni → `register_device` (byudjet tayyor bo'lganda va
/// token yangilanganda). Oflayn/xato — log, keyingi ochilishda qayta.
final Provider<void> pushRegistrationProvider = Provider((ref) {
  final push = ref.watch(pushServiceProvider);
  final signedIn = ref.watch(startupProvider) is StartupReady;
  if (!push.isAvailable || !signedIn) return;
  final remote = ref.watch(remoteApiProvider);

  Future<void> register(Future<String?> Function() token) async {
    try {
      final value = await token();
      if (value == null) return;
      final version = await ref.read(appVersionProvider.future);
      final result = await remote.registerDevice(value, appVersion: version);
      if (result case Err(:final failure)) {
        AppLog.info("Qurilma ro'yxatdan o'tmadi: ${failure.runtimeType}");
      }
    } on Object catch (error, stackTrace) {
      // FCM xizmati vaqtincha ishlamasligi mumkin — keyingi ochilishda qayta.
      AppLog.error('FCM tokeni olinmadi', error, stackTrace);
    }
  }

  unawaited(register(push.token));
  final subscription = push.tokenRefreshes.listen(
    (token) => unawaited(register(() async => token)),
  );
  ref.onDispose(subscription.cancel);
});
