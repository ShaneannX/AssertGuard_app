import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()(); // PK
  TextColumn get name => text()();
  TextColumn get email => text()();

  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
