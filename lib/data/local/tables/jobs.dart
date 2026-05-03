import 'package:drift/drift.dart';
import 'users.dart';

class Jobs extends Table {
  TextColumn get id => text()(); // PK

  TextColumn get userId => text().references(Users, #id)(); // FK → Users.id

  TextColumn get title => text()();

  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
