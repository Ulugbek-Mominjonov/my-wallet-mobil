import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart' as tz;

/// Rejalashtiriladigan lokal eslatma (BR-168). [payload] — ochiladigan
/// marshrut (bosilganda oq ro'yxat orqali tekshiriladi).
@immutable
final class LocalReminder {
  const new({
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
  });

  final tz.TZDateTime at;
  final String title;
  final String body;
  final String payload;

  @override
  bool operator ==(Object other) =>
      other is LocalReminder &&
      other.at == at &&
      other.title == title &&
      other.body == body &&
      other.payload == payload;

  @override
  int get hashCode => Object.hash(at, title, body, payload);

  @override
  String toString() => 'LocalReminder($at, $title, $body, $payload)';
}

/// Qurilmadagi bildirishnomalar: ruxsat, darhol ko'rsatish (ilova ochiq
/// paytidagi push) va rejali eslatmalar. Testda soxtasi bilan almashtiriladi.
abstract interface class LocalNotifier {
  /// Bosilgan bildirishnomalar marshruti (payload).
  Stream<String> get taps;

  /// Android 13+ — tizim ruxsati (push ham shunga bog'liq).
  Future<bool> requestPermission();

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  });

  /// Oldingi rejali eslatmalar o'chirilib, shular qo'yiladi.
  Future<void> replaceScheduled(List<LocalReminder> reminders);
}

final Provider<LocalNotifier> localNotifierProvider = Provider((ref) {
  final notifier = PluginLocalNotifier(FlutterLocalNotificationsPlugin());
  ref.onDispose(notifier.dispose);
  return notifier;
});

final class PluginLocalNotifier implements LocalNotifier {
  new(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String> _taps = StreamController.broadcast();
  Future<void>? _ready;

  /// Push ko'rsatish va eslatmalar — bitta kanal.
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Eslatmalar',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Bir vaqtda "darhol" ko'rsatilgan xabar ID si (rejalilar — 0 dan).
  static const int _foregroundId = 1 << 20;

  Future<void> _init() => _ready ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload case final payload?) _taps.add(payload);
        },
      )
      .then((_) async {
        // Ilova yopiq edi va eslatma bosilib ochildi.
        final launch = await _plugin.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp ?? false) {
          if (launch?.notificationResponse?.payload case final payload?) {
            _taps.add(payload);
          }
        }
      });

  @override
  Stream<String> get taps {
    unawaited(_init());
    return _taps.stream;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _init();
    await _plugin.show(
      id: _foregroundId,
      title: title,
      body: body,
      notificationDetails: _details,
      payload: payload,
    );
  }

  @override
  Future<void> replaceScheduled(List<LocalReminder> reminders) async {
    await _init();
    await _plugin.cancelAllPendingNotifications();
    for (final (id, reminder) in reminders.indexed) {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: reminder.at,
        notificationDetails: _details,
        // Aniq vaqt ruxsati kerak emas — eslatma bir necha daqiqa kech
        // kelishi mumkin.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: reminder.title,
        body: reminder.body,
        payload: reminder.payload,
      );
    }
  }

  Future<void> dispose() => _taps.close();
}
