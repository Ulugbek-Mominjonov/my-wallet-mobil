import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/receipts/receipt_providers.dart';
import 'package:my_wallet/data/receipts/receipt_queue.dart';

final class _CountingStorage implements ReceiptStorage {
  int calls = 0;
  bool fail = false;

  @override
  Future<void> upload(String path, Uint8List bytes, {required String mime}) =>
      throw UnimplementedError();

  @override
  Future<String> signedUrl(String path) async {
    calls++;
    if (fail) throw Exception('offline');
    return 'https://signed/$path?v=$calls';
  }
}

void main() {
  late _CountingStorage storage;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [receiptStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Ekranga chiqish: tinglash, qiymatni olish va ekrandan ketish.
  AsyncValue<String> show(ProviderContainer c, FakeAsync async) {
    final sub = c.listen(receiptUrlProvider('h/r.jpg'), (_, _) {});
    async.flushMicrotasks();
    final value = sub.read();
    sub.close();
    async.flushMicrotasks();
    return value;
  }

  setUp(() => storage = _CountingStorage());

  test(
    'E20-T02: havola muddati ichida qayta ishlatiladi — yangi imzo yo‘q',
    () {
      fakeAsync((async) {
        final c = container();
        expect(show(c, async).value, 'https://signed/h/r.jpg?v=1');

        async.elapse(const Duration(minutes: 10));
        expect(show(c, async).value, 'https://signed/h/r.jpg?v=1');
        expect(storage.calls, 1);

        // Muddati tugashidan oldin unutiladi — keyingi ko'rishda yangi havola.
        async.elapse(receiptUrlReuse);
        expect(show(c, async).value, 'https://signed/h/r.jpg?v=2');
        expect(receiptUrlReuse, lessThan(receiptUrlTtl));
      });
    },
  );

  test(
    'xato havola sifatida saqlanmaydi — qayta urinishda yangisi olinadi',
    () {
      fakeAsync((async) {
        final c = container();
        storage.fail = true;
        expect(show(c, async).hasError, isTrue);

        // Riverpod xatoni o'zi qayta urinadi (backoff); tarmoq qaytgan.
        storage.fail = false;
        async.elapse(const Duration(seconds: 1));
        expect(show(c, async).value, 'https://signed/h/r.jpg?v=2');
      });
    },
  );
}
