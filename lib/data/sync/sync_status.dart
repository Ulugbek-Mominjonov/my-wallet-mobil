import 'package:meta/meta.dart';
import 'package:my_wallet/data/local/database.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Sinxron holati ko'rinishi — `SyncStatusBadge` va "Sinxron holati" ekrani.
enum SyncPhase { synced, syncing, pending, offline, issues, signedOut }

@immutable
final class SyncStatus {
  const new({
    this.pendingCount = 0,
    this.issues = const [],
    this.lastPullAt,
    this.lastPushAt,
    this.running = false,
    this.lastFailure,
  });

  /// Yuborilmagan o'zgarishlar.
  final int pendingCount;

  /// Hal qilinmagan to'qnashuv/rad etishlar.
  final List<SyncIssueRow> issues;
  final DateTime? lastPullAt;
  final DateTime? lastPushAt;
  final bool running;
  final Failure? lastFailure;

  /// Eng muhimi birinchi: muammolar → sessiya → jarayon → oflayn → navbat.
  SyncPhase get phase {
    if (issues.isNotEmpty) return SyncPhase.issues;
    if (lastFailure is UnauthorizedFailure) return SyncPhase.signedOut;
    if (running) return SyncPhase.syncing;
    if (lastFailure is OfflineFailure) return SyncPhase.offline;
    if (pendingCount > 0) return SyncPhase.pending;
    return SyncPhase.synced;
  }

  /// Oxirgi muvaffaqiyatli aloqa.
  DateTime? get lastSyncAt => switch ((lastPullAt, lastPushAt)) {
    (null, final push) => push,
    (final pull, null) => pull,
    (final pull?, final push?) => pull.isAfter(push) ? pull : push,
  };
}
