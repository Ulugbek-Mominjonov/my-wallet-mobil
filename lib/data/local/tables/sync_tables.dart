// Deklarativ sxema: getter'larni faqat drift generatori o'qiydi (ish
// vaqtida chaqirilmaydi) — qoplama hisobidan tashqari; sxema
// database_test'da tekshiriladi.
// coverage:ignore-file
import 'package:drift/drift.dart';

// Serverdagi sinxron jadvallarning lokal nusxasi (contracts/api.md, E10).
// Ustun nomlari va qiymatlari serverdagi bilan bir xil: pull qatori
// (snake_case JSON) to'g'ridan-to'g'ri yoziladi. Pul — eng kichik birlikda
// butun son, sana va oy — ISO matn (`2026-09-01`), enum — server qiymati.
// Lokal FK yo'q: pull tartibi (row_version) havola qilingan qatordan oldin
// kelishi mumkin — butunlik serverda.

/// Byudjet ichidagi barcha sinxron jadvallar uchun umumiy ustunlar.
mixin SyncedRow on Table {
  /// UUIDv7 — klient yaratadi (ADR-07).
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get createdBy => text().nullable()();

  /// Server maydonlari — lokal yangi qatorda sinxrongacha bo'sh.
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Soft delete (tombstone) — ekranlar `deleted_at IS NULL` bilan o'qiydi.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Oxirgi ma'lum server versiyasi (push'da `base_version`); 0 — serverda
  /// hali yo'q.
  IntColumn get rowVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Byudjet sozlamalari — faqat pull (o'zgartirish RPC orqali).
@DataClassName('HouseholdRow')
class Households extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get baseCurrency => text().withDefault(const Constant('UZS'))();
  TextColumn get timezone =>
      text().withDefault(const Constant('Asia/Tashkent'))();
  TextColumn get personalFundMode =>
      text().withDefault(const Constant('percent'))();

  /// Serverda `numeric(5, 2)` (10.00 = 10%); domenda bazis punktga o'giriladi.
  RealColumn get personalFundPercent =>
      real().withDefault(const Constant(10))();
  IntColumn get personalFundFixedAmount =>
      integer().withDefault(const Constant(0))();
  IntColumn get personalFundDay => integer().withDefault(const Constant(5))();
  TextColumn get personalFundSourceAccountId => text().nullable()();
  BoolColumn get autoOpenMonth => boolean().withDefault(const Constant(true))();
  BoolColumn get strictMonthLock =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get onboardedAt => dateTime().nullable()();
  IntColumn get rowVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AccountRow')
@TableIndex(name: 'accounts_household', columns: {#householdId})
class Accounts extends Table with SyncedRow {
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get currency => text().withDefault(const Constant('UZS'))();
  IntColumn get openingBalance => integer().withDefault(const Constant(0))();
  TextColumn get openingDate => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

@DataClassName('CategoryRow')
@TableIndex(name: 'categories_household', columns: {#householdId})
class Categories extends Table with SyncedRow {
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  IntColumn get monthShift => integer().withDefault(const Constant(0))();
  TextColumn get systemCode => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

@DataClassName('RecurringRuleRow')
@TableIndex(name: 'recurring_rules_household', columns: {#householdId})
class RecurringRules extends Table with SyncedRow {
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get accountId => text().nullable()();

  /// NULL — summa o'zgaruvchan.
  IntColumn get amount => integer().nullable()();
  IntColumn get dayOfMonth => integer()();
  BoolColumn get autoPay => boolean().withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get debtId => text().nullable()();
  TextColumn get startMonth => text().nullable()();
  TextColumn get endMonth => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('CategoryLimitRow')
@TableIndex(name: 'category_limits_household', columns: {#householdId})
class CategoryLimits extends Table with SyncedRow {
  TextColumn get categoryId => text()();
  IntColumn get amount => integer()();
  BoolColumn get alert80 =>
      boolean().named('alert_80').withDefault(const Constant(true))();
  BoolColumn get alert100 =>
      boolean().named('alert_100').withDefault(const Constant(true))();
}

@DataClassName('QuickActionRow')
@TableIndex(name: 'quick_actions_household', columns: {#householdId})
class QuickActions extends Table with SyncedRow {
  TextColumn get name => text()();
  IntColumn get amount => integer()();
  TextColumn get categoryId => text()();
  TextColumn get accountId => text()();
  TextColumn get payee => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('TagRow')
@TableIndex(name: 'tags_household', columns: {#householdId})
class Tags extends Table with SyncedRow {
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
}

@DataClassName('DebtRow')
@TableIndex(name: 'debts_household', columns: {#householdId})
class Debts extends Table with SyncedRow {
  TextColumn get name => text()();
  TextColumn get direction => text()();
  TextColumn get currency => text().withDefault(const Constant('UZS'))();
  IntColumn get total => integer()();
  IntColumn get paidBefore => integer().withDefault(const Constant(0))();
  IntColumn get monthlyPayment => integer().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

@DataClassName('GoalRow')
@TableIndex(name: 'goals_household', columns: {#householdId})
class Goals extends Table with SyncedRow {
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('UZS'))();
  IntColumn get target => integer()();
  IntColumn get savedManual => integer().withDefault(const Constant(0))();
  IntColumn get monthlyContribution => integer().nullable()();
  TextColumn get deadline => text().nullable()();
  TextColumn get accountId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get achievedAt => dateTime().nullable()();
}

/// Oy holati (BR-150) — faqat pull; ID yo'q, tombstone yo'q.
@DataClassName('MonthRow')
class Months extends Table {
  TextColumn get householdId => text()();
  TextColumn get month => text()();
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get closedBy => text().nullable()();
  IntColumn get rowVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {householdId, month};
}

@DataClassName('PlannedItemRow')
@TableIndex(name: 'planned_items_month', columns: {#householdId, #budgetMonth})
@TableIndex(name: 'planned_items_debt', columns: {#debtId})
class PlannedItems extends Table with SyncedRow {
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get accountId => text().nullable()();

  /// NULL — summa noma'lum.
  IntColumn get plannedAmount => integer().nullable()();
  TextColumn get dueDate => text()();
  TextColumn get budgetMonth => text()();
  BoolColumn get autoPay => boolean().withDefault(const Constant(false))();
  TextColumn get debtId => text().nullable()();
  TextColumn get recurringRuleId => text().nullable()();
  TextColumn get systemCode => text().nullable()();

  /// Server hisoblaydi (bog'langan amallar); lokal — taxmin (E12 `settlePlan`).
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  DateTimeColumn get settledAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  DateTimeColumn get skippedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

@DataClassName('TransactionRow')
@TableIndex(name: 'transactions_month', columns: {#householdId, #budgetMonth})
@TableIndex(
  name: 'transactions_list',
  columns: {#householdId, #occurredOn, #id},
)
@TableIndex(name: 'transactions_account', columns: {#accountId})
@TableIndex(name: 'transactions_to_account', columns: {#toAccountId})
@TableIndex(name: 'transactions_planned', columns: {#plannedItemId})
@TableIndex(name: 'transactions_debt', columns: {#debtId})
class Transactions extends Table with SyncedRow {
  TextColumn get kind => text()();
  TextColumn get accountId => text()();
  TextColumn get toAccountId => text().nullable()();
  IntColumn get amount => integer()();
  IntColumn get toAmount => integer().nullable()();
  IntColumn get amountBase => integer()();

  /// Qo'lda kurs (serverda `numeric(18, 6)`) — faqat ko'rsatish/E29.
  RealColumn get fxRate => real().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get payee => text().nullable()();
  TextColumn get occurredOn => text()();
  TextColumn get budgetMonth => text()();
  TextColumn get budgetMonthSource =>
      text().withDefault(const Constant('auto'))();
  TextColumn get plannedItemId => text().nullable()();
  TextColumn get debtId => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
}

@DataClassName('TransactionTagRow')
@TableIndex(name: 'transaction_tags_transaction', columns: {#transactionId})
class TransactionTags extends Table with SyncedRow {
  TextColumn get transactionId => text()();
  TextColumn get tagId => text()();
}

@DataClassName('AttachmentRow')
@TableIndex(name: 'attachments_transaction', columns: {#transactionId})
class Attachments extends Table with SyncedRow {
  TextColumn get transactionId => text()();
  TextColumn get storagePath => text()();
  TextColumn get mime => text()();
  IntColumn get sizeBytes => integer()();
}
