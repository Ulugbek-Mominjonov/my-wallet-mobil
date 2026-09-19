import 'package:meta/meta.dart';
import 'package:wallet_domain/src/repositories/repositories.dart';

/// Use-case'lar bog'liqliklari (ilovada Riverpod provider'laridan).
@immutable
final class DomainDeps {
  const new({
    required this.households,
    required this.accounts,
    required this.categories,
    required this.plans,
    required this.transactions,
    required this.quickActions,
    required this.transactor,
    required this.ids,
    required this.clock,
  });

  final HouseholdRepository households;
  final AccountRepository accounts;
  final CategoryRepository categories;
  final PlannedItemRepository plans;
  final TransactionRepository transactions;
  final QuickActionRepository quickActions;
  final Transactor transactor;
  final IdGenerator ids;
  final Clock clock;
}
