import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:my_wallet/data/local/directory_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:my_wallet/features/transactions/application/amount_entry.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// "Qo'shish" varag'i holati (E15): tur, summa va maydonlar.
@immutable
final class AddTransactionState {
  const new({
    this.kind = TransactionKind.expense,
    this.entry = const AmountEntry(),
    this.currency = Currency.uzs,
    this.accountId,
    this.toAccountId,
    this.categoryId,
    this.occurredOn,
    this.payee,
    this.note,
    this.tagIds = const {},
    this.debtId,
    this.manualMonth,
    this.saving = false,
    this.failure,
  });

  final TransactionKind kind;
  final AmountEntry entry;
  final Currency currency;
  final String? accountId;

  /// O'tkazmada — manzil hisob (E15-T05).
  final String? toAccountId;
  final String? categoryId;

  /// `null` — bugun (byudjet vaqt zonasida, BR-002).
  final LocalDate? occurredOn;
  final String? payee;
  final String? note;
  final Set<String> tagIds;

  /// BR-112: qarz to'lovi/olinishi shu qarzga bog'lanadi.
  final String? debtId;

  /// BR-041, BR-042: qo'lda tanlangan tegishli oy (`null` — qoida bo'yicha).
  final MonthKey? manualMonth;
  final bool saving;
  final Failure? failure;

  Money get amount => entry.value(currency);

  bool get isTransfer => kind == TransactionKind.transfer;

  /// Saqlash mumkinmi: summa va kerakli maydonlar to'ldirilgan.
  bool get canSave =>
      amount.minor > 0 &&
      accountId != null &&
      !saving &&
      (!isTransfer || (toAccountId != null && toAccountId != accountId));

  AddTransactionState copyWith({
    TransactionKind? kind,
    AmountEntry? entry,
    Currency? currency,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    LocalDate? occurredOn,
    String? payee,
    String? note,
    Set<String>? tagIds,
    String? debtId,
    MonthKey? manualMonth,
    bool? saving,
    Failure? failure,
    bool clearCategory = false,
    bool clearDebt = false,
    bool clearManualMonth = false,
    bool clearFailure = false,
  }) => AddTransactionState(
    kind: kind ?? this.kind,
    entry: entry ?? this.entry,
    currency: currency ?? this.currency,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId ?? this.toAccountId,
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    occurredOn: occurredOn ?? this.occurredOn,
    payee: payee ?? this.payee,
    note: note ?? this.note,
    tagIds: tagIds ?? this.tagIds,
    debtId: clearDebt ? null : (debtId ?? this.debtId),
    manualMonth: clearManualMonth ? null : (manualMonth ?? this.manualMonth),
    saving: saving ?? this.saving,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

final NotifierProvider<AddTransactionController, AddTransactionState>
addTransactionProvider = NotifierProvider.autoDispose(
  AddTransactionController.new,
);

/// Yangi amal kiritish (BR-140..142). Saqlash — domen use-case'lari orqali,
/// ya'ni oflaynda ham ishlaydi (outbox).
base class AddTransactionController extends Notifier<AddTransactionState> {
  @override
  AddTransactionState build() {
    final startup = ref.watch(startupProvider);
    final state = AddTransactionState(
      currency: startup is StartupReady ? startup.currency : Currency.uzs,
    );
    // Standart hisob — ro'yxatdagi birinchisi (fond emas).
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final defaultAccount = accounts
        .where((a) => a.type != AccountType.personalFund)
        .firstOrNull;
    return defaultAccount == null
        ? state
        : state.copyWith(accountId: defaultAccount.id);
  }

  /// Tur o'zgarsa kategoriya va qo'lda tanlangan oy qaytadan tanlanadi;
  /// daromadda fond hisobi bo'lmaydi (BR-063) — standart hisobga qaytadi.
  void selectKind(TransactionKind kind) {
    final accounts = ref.read(accountsProvider).value ?? const <Account>[];
    final onFund = accounts.any(
      (a) => a.id == state.accountId && a.type == AccountType.personalFund,
    );
    final fallback = accounts
        .where((a) => a.type != AccountType.personalFund)
        .firstOrNull
        ?.id;
    state = state.copyWith(
      kind: kind,
      accountId: kind == TransactionKind.income && onFund ? fallback : null,
      clearCategory: true,
      clearManualMonth: true,
    );
  }

  void press(AmountKey key) =>
      state = state.copyWith(entry: state.entry.press(key));

  void selectAccount(String id) => state = state.copyWith(accountId: id);

  void selectToAccount(String id) => state = state.copyWith(toAccountId: id);

  void selectCategory(String? id) => state = id == null
      ? state.copyWith(clearCategory: true)
      : state.copyWith(categoryId: id);

  void selectDate(LocalDate date) => state = state.copyWith(occurredOn: date);

  /// BR-035: joyida yangi kategoriya (shu nomlisi bo'lsa — o'sha) va tanlash.
  Future<Result<Category>> createCategory(String name) async {
    final deps = ref.read(domainDepsProvider);
    if (deps == null) return const Err(UnauthorizedFailure());
    final result = await CreateCategory(deps)(
      kind: state.kind == TransactionKind.income
          ? CategoryKind.income
          : CategoryKind.expense,
      name: name,
    );
    if (result case Ok(:final value)) {
      state = state.copyWith(categoryId: value.id);
    }
    return result;
  }

  /// BR-056: joy nomi bilan birga oxirgi kategoriya/hisob taklif qilinadi.
  void setPayee(String payee, {String? categoryId, String? accountId}) =>
      state = state.copyWith(
        payee: payee,
        categoryId: categoryId,
        accountId: accountId,
      );

  void setNote(String note) => state = state.copyWith(note: note);

  /// BR-141: uzoq bosilgan tez tugma — forma shu qiymatlar bilan to'ladi
  /// (summani o'zgartirib saqlash uchun).
  void prefill(QuickAction action) => state = state.copyWith(
    kind: TransactionKind.expense,
    entry: AmountEntry(
      digits: '${action.amount.minor ~/ action.amount.currency.minorPerMajor}',
    ),
    accountId: action.accountId,
    categoryId: action.categoryId,
    payee: action.payee,
    clearManualMonth: true,
  );

  void toggleTag(String tagId) => state = state.copyWith(
    tagIds: state.tagIds.contains(tagId)
        ? ({...state.tagIds}..remove(tagId))
        : {...state.tagIds, tagId},
  );

  /// BR-045: `null` — qoida bo'yicha (sana oyi / daromad siljishi).
  void selectMonth(MonthKey? month) => state = month == null
      ? state.copyWith(clearManualMonth: true)
      : state.copyWith(manualMonth: month);

  void selectDebt(String? debtId) => state = debtId == null
      ? state.copyWith(clearDebt: true)
      : state.copyWith(debtId: debtId);

  /// Saqlaydi va natijani qaytaradi (`Ok` — varaq yopiladi).
  Future<Result<Transaction>> save({bool confirmClosedMonth = false}) async {
    final deps = ref.read(domainDepsProvider);
    if (deps == null || !state.canSave) {
      return const Err(ValidationFailure('amount', 'required'));
    }
    state = state.copyWith(saving: true, clearFailure: true);

    // Amal va uning teglari — bitta lokal tranzaksiyada.
    final result = await deps.transactor.run(() async {
      final saved = await _saveTransaction(
        deps,
        confirmClosedMonth: confirmClosedMonth,
      );
      if (saved case Ok(:final value) when state.tagIds.isNotEmpty) {
        await ref
            .read(transactionTagWriterProvider)
            ?.setTags(value.id, state.tagIds);
      }
      return saved;
    });

    state = switch (result) {
      Ok() => state.copyWith(saving: false),
      Err(:final failure) => state.copyWith(saving: false, failure: failure),
    };
    return result;
  }

  Future<Result<Transaction>> _saveTransaction(
    DomainDeps deps, {
    required bool confirmClosedMonth,
  }) async => state.isTransfer
      ? await AddTransfer(deps)(
          TransferInput(
            fromAccountId: state.accountId!,
            toAccountId: state.toAccountId!,
            amount: state.amount,
            occurredOn: state.occurredOn,
            note: _trimmed(state.note),
          ),
          confirmClosedMonth: confirmClosedMonth,
        )
      : await AddTransaction(deps)(
          TransactionInput(
            kind: state.kind,
            accountId: state.accountId!,
            amount: state.amount,
            categoryId: state.categoryId,
            occurredOn: state.occurredOn,
            manualMonth: state.manualMonth,
            payee: _trimmed(state.payee),
            note: _trimmed(state.note),
            debtId: state.debtId,
          ),
          confirmClosedMonth: confirmClosedMonth,
        );

  static String? _trimmed(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
