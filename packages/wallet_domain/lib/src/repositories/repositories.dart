import 'package:wallet_domain/src/entities/account.dart';
import 'package:wallet_domain/src/entities/category.dart';
import 'package:wallet_domain/src/entities/debt.dart';
import 'package:wallet_domain/src/entities/directory_items.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/entities/goal.dart';
import 'package:wallet_domain/src/entities/household.dart';
import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/entities/transaction.dart';
import 'package:wallet_domain/src/value_objects/currency.dart';
import 'package:wallet_domain/src/value_objects/fx_rate.dart';
import 'package:wallet_domain/src/value_objects/local_date.dart';
import 'package:wallet_domain/src/value_objects/month_key.dart';

// Repository interfeyslari — joriy (tanlangan) byudjet doirasida.
// Implementatsiya — ilovaning data qatlamida (E13: drift + outbox). Yozuv va
// outbox mutatsiyasi bitta lokal tranzaksiyada (`Transactor`).

abstract interface class HouseholdRepository {
  Future<Household> current();

  /// BR-150: oy yopilganmi.
  Future<bool> isMonthClosed(MonthKey month);
}

abstract interface class AccountRepository {
  Future<Account?> byId(String id);

  /// 👤 Shaxsiy fond hisobi (byudjetda bitta — BR-020).
  Future<Account> personalFund();
}

abstract interface class CategoryRepository {
  Future<Category?> byId(String id);

  /// "O'zim uchun" tizim kategoriyasi (BR-033).
  Future<Category> allocationCategory();

  /// BR-003: shu turdagi, o'chirilmagan, normallashtirilgan nomi bir xil
  /// kategoriya (`trim + lowercase`).
  Future<Category?> byName(CategoryKind kind, String name);

  Future<void> save(Category category);
}

abstract interface class PlannedItemRepository {
  Future<PlannedItem?> byId(String id);
  Future<void> save(PlannedItem item);
}

abstract interface class TransactionRepository {
  Future<Transaction?> byId(String id);
  Future<void> save(Transaction transaction);
}

abstract interface class QuickActionRepository {
  Future<QuickAction?> byId(String id);
}

abstract interface class DebtRepository {
  Future<Debt?> byId(String id);

  /// BR-003: o'chirilmagan, normallashtirilgan nomi bir xil qarz.
  Future<Debt?> byName(String name);
  Future<void> save(Debt debt);
}

abstract interface class GoalRepository {
  Future<Goal?> byId(String id);

  /// BR-003: o'chirilmagan, normallashtirilgan nomi bir xil maqsad.
  Future<Goal?> byName(String name);
  Future<void> save(Goal goal);
}

abstract interface class CategoryLimitRepository {
  /// Kategoriyaning amaldagi (o'chirilmagan) limiti — bittadan (BR-130).
  Future<CategoryLimit?> forCategory(String categoryId);
  Future<void> save(CategoryLimit limit);
}

/// BR-191: valyuta kurslari (lokal nusxa — `exchange_rates`).
abstract interface class FxRateRepository {
  /// Sanadagi yoki undan oldingi eng yaqin kurs; yo'q bo'lsa — `null`.
  Future<FxRate?> rate(Currency from, Currency to, LocalDate on);
}

/// Bir nechta yozuv — bitta lokal tranzaksiyada (hammasi yoki hech biri).
abstract interface class Transactor {
  Future<T> run<T>(Future<T> Function() action);
}

/// UUIDv7 (ADR-07: klient yaratadi — offline).
abstract interface class IdGenerator {
  String newId();
}

/// "Bugun" — byudjet vaqt zonasida (BR-002); `now` — UTC.
abstract interface class Clock {
  LocalDate today();
  DateTime now();
}
