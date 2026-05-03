import 'package:drift/drift.dart';
import 'jobs.dart';

class InspectionItems extends Table {
  TextColumn get id => text()(); // PK

  TextColumn get jobId => text().references(Jobs, #id)(); // FK → Jobs.id

  TextColumn get description => text()();
  TextColumn get notes => text().nullable()();

  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
