import 'package:wallet_domain/src/entities/account.dart';
import 'package:wallet_domain/src/entities/category.dart';
import 'package:wallet_domain/src/entities/directory_items.dart';
import 'package:wallet_domain/src/entities/household.dart';
import 'package:wallet_domain/src/entities/planned_item.dart';
import 'package:wallet_domain/src/entities/transaction.dart';
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
