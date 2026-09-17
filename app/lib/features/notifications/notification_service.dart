import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/formatters.dart';
import '../../core/logging/app_log.dart';
import '../../di/providers.dart';
import '../../di/state_providers.dart';

/// Bildirishnomalar (§9).
///
/// Ikki kanal ATAYLAB birga ishlatiladi:
/// * **FCM** — server (cron) yuboradigan push; ilova yopiq bo'lsa ham keladi;
/// * **lokal eslatma** — internet bo'lmasa ham ishlaydi, chunki jadval
///   telefonning o'zida turadi.
final class NotificationService {
  NotificationService(this._plugin, this._messaging);

  static const AndroidNotificationDetails _android =
      AndroidNotificationDetails(
    'payments',
    "To'lov eslatmalari",
    channelDescription: "Kechikkan va yaqinlashgan to'lovlar",
    importance: Importance.high,
    priority: Priority.high,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _android,
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin;
  final FirebaseMessaging _messaging;

  /// Ruxsat so'raydi va kanallarni tayyorlaydi.
  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _messaging.requestPermission();
  }

  /// Qurilma tokenini saqlaydi — server shu tokenga push yuboradi.
  Future<void> registerDevice(FirestoreRefsLike refs) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await refs.saveToken(token);
    } on Object catch (error, stackTrace) {
      // Push ishlamasa ham ilova ishlashda davom etadi.
      AppLog.error('FCM token saqlanmadi', error, stackTrace);
    }
  }

  /// Kechikkan va bugungi to'lovlar haqida lokal eslatma ko'rsatadi.
  Future<void> showReminder(ReminderBuckets buckets) async {
    if (buckets.isEmpty) return;
    final lines = <String>[
      if (buckets.overdue.isNotEmpty)
        "⚠️ Muddati o'tgan: ${buckets.overdue.length} ta",
      if (buckets.dueToday.isNotEmpty)
        '📌 Bugun: ${buckets.dueToday.length} ta',
      if (buckets.upcoming.isNotEmpty)
        '🗓 Yaqin kunlarda: ${buckets.upcoming.length} ta',
    ];
    await _plugin.show(
      id: 1,
      title: "To'lov eslatmasi",
      body: '${lines.join(' · ')} — jami ${Fmt.moneyLong(buckets.total)}',
      notificationDetails: _details,
    );
  }
}

/// Token saqlash uchun minimal interfeys — servis Firestore'ni to'g'ridan
/// to'g'ri bilmasligi uchun.
abstract interface class FirestoreRefsLike {
  Future<void> saveToken(String token);
}

final class UserDeviceRegistry implements FirestoreRefsLike {
  const UserDeviceRegistry(this._user);

  final DocumentReference<Map<String, dynamic>> _user;

  @override
  Future<void> saveToken(String token) => _user.set(
        <String, Object?>{
          'fcmTokens': FieldValue.arrayUnion(<String>[token]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(
    FlutterLocalNotificationsPlugin(),
    FirebaseMessaging.instance,
  ),
);

/// Ruxsat so'rash va qurilma tokenini saqlash — bir marta, kirgandan keyin.
final notificationBootstrapProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  await service.initialize();
  await service.registerDevice(
    UserDeviceRegistry(ref.watch(refsProvider).user),
  );
});

/// Ilova ochilganda eslatmalarni tekshiradi.
///
/// Serverdagi cron asosiy kanal; bu esa "ilova ochilganda ham ko'rsat"
/// zaxirasi — oflayn foydalanuvchi ham eslatmani ko'radi.
final reminderWatcherProvider = Provider<void>((ref) {
  final settings = ref.watch(settingsProvider).reminders;
  if (!settings.pushEnabled) return;
  final buckets = ref.watch(reminderBucketsProvider);
  if (buckets.isEmpty) return;
  unawaited(ref.read(notificationServiceProvider).showReminder(buckets));
});

/// `unawaited` uchun kichik yordamchi (dart:async ni import qilmaslik uchun).
void unawaited(Future<void> future) {
  future.catchError((Object error, StackTrace stackTrace) {
    AppLog.error('Bildirishnoma xatosi', error, stackTrace);
  });
}
