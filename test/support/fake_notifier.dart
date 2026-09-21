import 'dart:async';

import 'package:my_wallet/core/notifications/local_notifier.dart';
import 'package:my_wallet/core/notifications/push_service.dart';

/// Qurilma bildirishnomalari o'rnida — ko'rsatilgan va rejalashtirilganlar
/// yoziladi, bosishlar testdan yuboriladi.
final class FakeLocalNotifier implements LocalNotifier {
  final shown = <({String title, String body, String? payload})>[];
  List<LocalReminder> scheduled = const [];
  int replaceCalls = 0;
  bool permission = true;
  final StreamController<String> _taps = StreamController.broadcast();

  void tap(String payload) => _taps.add(payload);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async => shown.add((title: title, body: body, payload: payload));

  @override
  Future<void> replaceScheduled(List<LocalReminder> reminders) async {
    replaceCalls++;
    scheduled = reminders;
  }
}

/// FCM o'rnida: token va xabarlar testdan.
final class FakePushService implements PushService {
  String? currentToken = 'token-1';
  bool deleted = false;
  final StreamController<String> refreshes = StreamController.broadcast();
  final StreamController<PushMessage> foreground = StreamController.broadcast();
  final StreamController<PushMessage> opened = StreamController.broadcast();
  PushMessage? initial;

  @override
  bool get isAvailable => true;

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;

  @override
  Stream<PushMessage> get foregroundMessages => foreground.stream;

  @override
  Stream<PushMessage> get openedMessages => opened.stream;

  @override
  Future<PushMessage?> initialMessage() async => initial;

  @override
  Future<void> deleteToken() async => deleted = true;
}
