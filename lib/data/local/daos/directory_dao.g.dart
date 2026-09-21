// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directory_dao.dart';

// ignore_for_file: type=lint
mixin _$DirectoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $TagsTable get tags => attachedDatabase.tags;
  $DebtsTable get debts => attachedDatabase.debts;
  $QuickActionsTable get quickActions => attachedDatabase.quickActions;
  DirectoryDaoManager get managers => DirectoryDaoManager(this);
}

class DirectoryDaoManager {
  final _$DirectoryDaoMixin _db;
  DirectoryDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db.attachedDatabase, _db.debts);
  $$QuickActionsTableTableManager get quickActions =>
      $$QuickActionsTableTableManager(_db.attachedDatabase, _db.quickActions);
}
