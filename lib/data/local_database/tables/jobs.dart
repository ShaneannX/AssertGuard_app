import 'package:drift/drift.dart';

class Jobs extends Table {
  TextColumn get id => text()(); // PK

  TextColumn get userId => text()(); // Will be handled by Supbase auth user id. 

  TextColumn get title => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  TextColumn get syncStatus => text()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

