import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// BR-141: tez tugma — bosilganda darhol xarajat (bugungi sana,
/// `source = quick_action`); 5 soniya ichida bekor qilish mumkin.
final Provider<QuickAddActions> quickAddProvider = Provider(
  QuickAddActions.new,
);

final class QuickAddActions {
  const new(this._ref);

  final Ref _ref;

  /// Bekor qilish oynasi davomiyligi (BR-141).
  static const undoWindow = Duration(seconds: 5);

  DomainDeps? get _deps => _ref.read(domainDepsProvider);

  Future<Result<Transaction>> add(
    String quickActionId, {
    bool confirmClosedMonth = false,
  }) async {
    final deps = _deps;
    if (deps == null) return const Err(UnauthorizedFailure());
    return await QuickAdd(deps)(
      quickActionId,
      confirmClosedMonth: confirmClosedMonth,
    );
  }

  /// Hali serverga yetmagan bo'lsa — navbatdan ham chiqadi (E13-T04).
  Future<Result<Transaction>> undo(String transactionId) async {
    final deps = _deps;
    if (deps == null) return const Err(UnauthorizedFailure());
    return await DeleteTransaction(deps)(
      transactionId,
      confirmClosedMonth: true,
    );
  }
}
