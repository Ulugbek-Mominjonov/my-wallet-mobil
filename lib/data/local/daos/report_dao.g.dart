// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_dao.dart';

// ignore_for_file: type=lint
mixin _$ReportDaoMixin on DatabaseAccessor<AppDatabase> {
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $PlannedItemsTable get plannedItems => attachedDatabase.plannedItems;
  $CategoryLimitsTable get categoryLimits => attachedDatabase.categoryLimits;
  $MonthsTable get months => attachedDatabase.months;
  ReportDaoManager get managers => ReportDaoManager(this);
}

class ReportDaoManager {
  final _$ReportDaoMixin _db;
  ReportDaoManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$PlannedItemsTableTableManager get plannedItems =>
      $$PlannedItemsTableTableManager(_db.attachedDatabase, _db.plannedItems);
  $$CategoryLimitsTableTableManager get categoryLimits =>
      $$CategoryLimitsTableTableManager(
        _db.attachedDatabase,
        _db.categoryLimits,
      );
  $$MonthsTableTableManager get months =>
      $$MonthsTableTableManager(_db.attachedDatabase, _db.months);
}
