import 'dart:async';
import 'dart:math' as math;

import 'package:my_wallet/data/sync/sync_engine.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Sinxron qachon ishlaydi (ARXITEKTURA 5): ilova ochilganda, yozuvdan keyin
/// (1 s debounce — ketma-ket yozuvlar bitta siklda), tarmoq tiklanganda,
/// ilova oldinga chiqqanda, "tortib yangilash"da. Tarmoq xatosida —
/// eksponensial qayta urinish (1, 2, 4 … 300 s).
final class SyncScheduler {
  new(
    this._sync, {
    this.debounce = const Duration(seconds: 1),
    this.maxBackoff = const Duration(minutes: 5),
  });

  final Future<SyncReport> Function() _sync;
  final Duration debounce;
  final Duration maxBackoff;

  final _activity = StreamController<SyncActivity>.broadcast();
  var _current = const SyncActivity();

  /// Hozirgi holat (ishlayaptimi, oxirgi natija) va o'zgarishlari — UI uchun.
  SyncActivity get activity => _current;
  Stream<SyncActivity> get activityChanges => _activity.stream;

  Timer? _debounceTimer;
  Timer? _retryTimer;
  var _failures = 0;
  var _disposed = false;

  /// Keyingi qayta urinishgacha (kuzatuv/test uchun); rejada yo'q — null.
  Duration? get pendingRetry =>
      _retryTimer == null ? null : _backoff(_failures);

  void onStart() => unawaited(_run());
  void onResume() => unawaited(_run());

  /// Tarmoq qaytdi — kutib o'tirmasdan (qayta urinish hisobi nolga).
  void onNetworkRestored() {
    _failures = 0;
    unawaited(_run());
  }

  void onLocalWrite() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => unawaited(_run()));
  }

  /// "Tortib yangilash" — natijani ekran ko'rsatadi.
  Future<SyncReport> refresh() => _run();

  Future<SyncReport> _run() async {
    if (_disposed) return const SyncReport();
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    _retryTimer = null;
    _emit(SyncActivity(running: true, lastReport: _current.lastReport));
    final report = await _sync();
    if (_disposed) return report;
    _emit(SyncActivity(lastReport: report));
    if (report.failure is OfflineFailure) {
      _failures++;
      _retryTimer = Timer(_backoff(_failures), () => unawaited(_run()));
    } else {
      _failures = 0;
    }
    return report;
  }

  Duration _backoff(int failures) {
    final seconds = math.pow(2, math.max(0, failures - 1)).toInt();
    final delay = Duration(seconds: seconds);
    return delay > maxBackoff ? maxBackoff : delay;
  }

  void _emit(SyncActivity activity) {
    _current = activity;
    _activity.add(activity);
  }

  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    unawaited(_activity.close());
  }
}

/// Sinxronning jonli holati.
final class SyncActivity {
  const new({this.running = false, this.lastReport});

  final bool running;
  final SyncReport? lastReport;
}
