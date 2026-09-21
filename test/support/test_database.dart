import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_wallet/data/local/database.dart';

/// Xotiradagi baza; oqimlar darhol yopiladi (vidjet testlarida "pending
/// timer" qolmasin — drift yopishni odatda keyingi siklga qoldiradi).
AppDatabase testDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);
