import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Push xabari (contracts/api.md, E11): server tayyorlagan `notification
/// {title, body}` va `data {type}`.
typedef PushMessage = ({String? type, String? title, String? body});

/// FCM (E19-T01). Firebase sozlanmagan bo'lsa (dev, testlar) — o'chiq.
abstract interface class PushService {
  bool get isAvailable;
  Future<String?> token();
  Stream<String> get tokenRefreshes;

  /// Ilova ochiq paytida kelgan xabarlar (tizim ko'rsatmaydi).
  Stream<PushMessage> get foregroundMessages;

  /// Bildirishnoma bosilib ilova ochilgan (fonda bo'lgan).
  Stream<PushMessage> get openedMessages;

  /// Ilova yopiq edi va bildirishnoma bosilib ishga tushdi.
  Future<PushMessage?> initialMessage();

  /// Chiqishda — qurilma boshqa akkauntga xabar olmasin.
  Future<void> deleteToken();
}

/// `bootstrap` Firebase'ni ishga tushira olganmi (testlarda — yo'q).
final Provider<bool> firebaseReadyProvider = Provider((ref) => false);

final Provider<PushService> pushServiceProvider = Provider(
  (ref) => ref.watch(firebaseReadyProvider)
      ? FirebasePushService(FirebaseMessaging.instance)
      : const DisabledPushService(),
);

final class FirebasePushService implements PushService {
  const new(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  bool get isAvailable => true;

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage.map(_toMessage);

  @override
  Stream<PushMessage> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp.map(_toMessage);

  @override
  Future<PushMessage?> initialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toMessage(message);
  }

  @override
  Future<void> deleteToken() => _messaging.deleteToken();

  /// `data` — tashqi kirish: faqat matn qiymat olinadi.
  static PushMessage _toMessage(RemoteMessage message) => (
    type: switch (message.data['type']) {
      final String type => type,
      _ => null,
    },
    title: message.notification?.title,
    body: message.notification?.body,
  );
}

final class DisabledPushService implements PushService {
  const new();

  @override
  bool get isAvailable => false;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Stream<PushMessage> get foregroundMessages => const Stream.empty();

  @override
  Stream<PushMessage> get openedMessages => const Stream.empty();

  @override
  Future<PushMessage?> initialMessage() async => null;

  @override
  Future<void> deleteToken() async {}
}
