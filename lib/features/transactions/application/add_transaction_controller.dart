import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/application/amount_entry.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "Qo'shish" varag'i holati (E15): tur va summa; maydonlar — E15-T02.
@immutable
final class AddTransactionState {
  const new({
    this.kind = TransactionKind.expense,
    this.entry = const AmountEntry(),
    this.currency = Currency.uzs,
  });

  final TransactionKind kind;
  final AmountEntry entry;
  final Currency currency;

  Money get amount => entry.value(currency);

  /// Saqlash mumkinmi (summa noldan katta).
  bool get canSave => amount.minor > 0;

  AddTransactionState copyWith({
    TransactionKind? kind,
    AmountEntry? entry,
    Currency? currency,
  }) => AddTransactionState(
    kind: kind ?? this.kind,
    entry: entry ?? this.entry,
    currency: currency ?? this.currency,
  );
}

final NotifierProvider<AddTransaction, AddTransactionState>
addTransactionProvider = NotifierProvider.autoDispose(AddTransaction.new);

/// Yangi amal kiritish. Saqlash va maydonlar keyingi vazifalarda qo'shiladi.
base class AddTransaction extends Notifier<AddTransactionState> {
  @override
  AddTransactionState build() {
    final startup = ref.watch(startupProvider);
    return AddTransactionState(
      currency: startup is StartupReady ? startup.currency : Currency.uzs,
    );
  }

  void selectKind(TransactionKind kind) => state = state.copyWith(kind: kind);

  void press(AmountKey key) =>
      state = state.copyWith(entry: state.entry.press(key));
}
