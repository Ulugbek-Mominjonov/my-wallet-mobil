import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show FutureProviderFamily, StreamProviderFamily;
import 'package:my_wallet/data/local/daos/ledger_dao.dart';
import 'package:my_wallet/data/local/outbox_writer.dart';
import 'package:my_wallet/data/repositories/local_ledger.dart';
import 'package:my_wallet/data/repositories/transaction_tags.dart';
import 'package:my_wallet/data/sync/sync_providers.dart';
import 'package:my_wallet/features/startup/application/startup_controller.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Joriy byudjet hisoblari (sinxron bilan yangilanadi).
final StreamProvider<List<Account>> accountsProvider = StreamProvider((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();
  return ref.watch(appDatabaseProvider).directoryDao.watchAccounts(householdId);
});

final StreamProvider<List<Tag>> tagsProvider = StreamProvider((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();
  return ref.watch(appDatabaseProvider).directoryDao.watchTags(householdId);
});

final StreamProvider<List<Debt>> debtsProvider = StreamProvider((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();
  return ref.watch(appDatabaseProvider).directoryDao.watchDebts(householdId);
});

/// Turi bo'yicha kategoriyalar.
final StreamProviderFamily<List<Category>, CategoryKind> categoriesProvider =
    StreamProvider.family((ref, kind) {
      final householdId = ref.watch(currentHouseholdIdProvider);
      if (householdId == null) return const Stream.empty();
      return ref
          .watch(appDatabaseProvider)
          .directoryDao
          .watchCategories(householdId, kind: kind);
    });

/// Oxirgi ishlatilgan kategoriyalar ID si (BR-140).
final FutureProviderFamily<List<String>, CategoryKind>
recentCategoriesProvider = FutureProvider.family((ref, kind) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const [];
  return await ref
      .watch(appDatabaseProvider)
      .directoryDao
      .recentCategoryIds(householdId, kind: kind);
});

/// BR-056: joy nomi bo'yicha takliflar (oxirgi kategoriya/hisob bilan).
final FutureProviderFamily<List<PayeeSuggestion>, String>
payeeSuggestionsProvider = FutureProvider.family((ref, prefix) async {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const [];
  return await ref
      .watch(appDatabaseProvider)
      .ledgerDao
      .recentPayees(householdId, prefix: prefix);
});

/// Amal teglari yozuvchisi (outbox bilan).
final Provider<TransactionTagWriter?> transactionTagWriterProvider = Provider((
  ref,
) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return null;
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  const ids = UuidV7Ids();
  return TransactionTagWriter(
    db,
    householdId,
    OutboxWriter(db, newId: ids.newId, now: clock.now),
    newId: ids.newId,
    now: clock.now,
  );
});

/// Domen use-case'lari uchun bog'liqliklar (byudjet tanlangan bo'lsa).
final domainDepsProvider = Provider<DomainDeps?>((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return null;
  return localDomainDeps(
    ref.watch(appDatabaseProvider),
    householdId: householdId,
    clock: ref.watch(clockProvider),
  );
});
