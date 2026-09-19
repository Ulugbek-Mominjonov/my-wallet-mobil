import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:my_wallet/data/sync/sync_scheduler.dart';
import 'package:wallet_domain/wallet_domain.dart';

void main() {
  late int runs;
  late List<SyncReport> results;

  SyncScheduler scheduler() => SyncScheduler(() async {
    runs++;
    return results.isEmpty ? const SyncReport() : results.removeAt(0);
  });

  setUp(() {
    runs = 0;
    results = [];
  });

  test('yozuvlar debounce bilan — bitta sikl', () {
    fakeAsync((async) {
      final s = scheduler()
        ..onLocalWrite()
        ..onLocalWrite();
      async.elapse(const Duration(milliseconds: 900));
      s.onLocalWrite();
      async.elapse(const Duration(milliseconds: 900));
      expect(runs, 0);
      async.elapse(const Duration(milliseconds: 200));
      expect(runs, 1);
      s.dispose();
    });
  });

  test("oflayn — 1, 2, 4 … s, 5 daqiqada to'xtaydi; muvaffaqiyat — nolga", () {
    fakeAsync((async) {
      results = List.filled(
        12,
        const SyncReport(failure: OfflineFailure()),
        growable: true,
      );
      final s = scheduler()..onStart();
      async.flushMicrotasks();
      expect(runs, 1);
      final delays = <Duration?>[];
      for (var i = 0; i < 10; i++) {
        delays.add(s.pendingRetry);
        async
          ..elapse(s.pendingRetry!)
          ..flushMicrotasks();
      }
      expect(
        [for (final d in delays) d!.inSeconds],
        [1, 2, 4, 8, 16, 32, 64, 128, 256, 300],
      );
      results
        ..clear()
        ..add(const SyncReport());
      async
        ..elapse(s.pendingRetry!)
        ..flushMicrotasks();
      expect(s.pendingRetry, isNull);
      s.dispose();
    });
  });

  test('tarmoq qaytdi — darhol, hisob nolga', () {
    fakeAsync((async) {
      results = [
        const SyncReport(failure: OfflineFailure()),
        const SyncReport(failure: OfflineFailure()),
        const SyncReport(failure: OfflineFailure()),
      ];
      final s = scheduler()..onStart();
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 1))
        ..flushMicrotasks();
      expect(s.pendingRetry, const Duration(seconds: 2));
      s.onNetworkRestored();
      async.flushMicrotasks();
      expect(runs, 3);
      expect(s.pendingRetry, const Duration(seconds: 1));
      s.dispose();
    });
  });

  test(
    "sessiya xatosi — qayta urinish yo'q; refresh natija qaytaradi",
    () async {
      results = [
        const SyncReport(failure: UnauthorizedFailure()),
        const SyncReport(pulled: 3),
      ];
      final s = scheduler();
      expect((await s.refresh()).failure, isA<UnauthorizedFailure>());
      expect(s.pendingRetry, isNull);
      expect((await s.refresh()).pulled, 3);
      s
        ..onResume()
        ..dispose();
      expect((await s.refresh()).ok, isTrue);
      expect(runs, 3);
    },
  );

  test('dispose — rejalangan ishlar bekor', () {
    fakeAsync((async) {
      scheduler()
        ..onLocalWrite()
        ..dispose();
      async.elapse(const Duration(seconds: 10));
      expect(runs, 0);
    });
  });
}
