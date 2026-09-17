import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Sahifalash kursori: `<saralash qiymati>|<hujjat id>`.
///
/// `startAfterDocument` uchun oldingi hujjatni QAYTA O'QISH kerak bo'lardi
/// (ortiqcha 1 read). Kursorni qiymat sifatida uzatib, `startAfter` ga
/// to'g'ridan-to'g'ri beramiz. `offset` esa umuman ishlatilmaydi —
/// Firestore o'tkazib yuborilgan hujjatlar uchun ham pul oladi (§5.4).
abstract final class Cursor {
  static String encode(DateTime sortValue, String id) =>
      '${sortValue.millisecondsSinceEpoch}|$id';

  static List<Object>? decode(String? cursor) {
    if (cursor == null || cursor.isEmpty) return null;
    final parts = cursor.split('|');
    if (parts.length != 2) return null;
    final millis = int.tryParse(parts.first);
    if (millis == null) return null;
    return <Object>[
      Timestamp.fromMillisecondsSinceEpoch(millis),
      parts.last,
    ];
  }
}

/// Bir nechta hujjat oqimini birlashtiradi.
///
/// Sozlamalar 4 ta hujjatda saqlanadi (`app`, `personalFund`, `incomeRules`,
/// `reminders`) — ularni bitta oqimga yig'ish uchun.
Stream<List<T>> combineLatest<T>(List<Stream<T>> sources) {
  if (sources.isEmpty) return Stream<List<T>>.value(const []);
  // Controller chaqiruvchiga qaytariladi; `onCancel` da obunalar
  // bekor qilinadi, shuning uchun bu yerda yopilmaydi.
  // ignore: close_sinks
  late StreamController<List<T>> controller;
  final subscriptions = <StreamSubscription<T>>[];
  final latest = List<T?>.filled(sources.length, null);
  final seen = List<bool>.filled(sources.length, false);

  void emit() {
    if (seen.every((value) => value)) {
      controller.add(<T>[for (final value in latest) value as T]);
    }
  }

  controller = StreamController<List<T>>(
    onListen: () {
      for (var index = 0; index < sources.length; index++) {
        final position = index;
        subscriptions.add(
          sources[position].listen(
            (value) {
              latest[position] = value;
              seen[position] = true;
              emit();
            },
            onError: controller.addError,
          ),
        );
      }
    },
    onCancel: () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      subscriptions.clear();
    },
  );
  return controller.stream;
}
