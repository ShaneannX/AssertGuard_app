import 'package:drift/drift.dart';
import 'jobs.dart';

class InspectionItems extends Table {
  TextColumn get id => text()(); // PK

  TextColumn get jobId => text().references(Jobs, #id)(); // FK for jobs.id

  TextColumn get description => text()();
  TextColumn get notes => text().nullable()();

  TextColumn get createdBy => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  TextColumn get syncStatus => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}
