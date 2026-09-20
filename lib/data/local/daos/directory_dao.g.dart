// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directory_dao.dart';

// ignore_for_file: type=lint
mixin _$DirectoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  DirectoryDaoManager get managers => DirectoryDaoManager(this);
}

class DirectoryDaoManager {
  final _$DirectoryDaoMixin _db;
  DirectoryDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
}
