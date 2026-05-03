import 'package:drift/drift.dart';
import 'inspection_items.dart';

class Attachments extends Table {
  TextColumn get id => text()(); // PK

  TextColumn get inspectionItemId =>
      text().references(InspectionItems, #id)(); // FK → InspectionItems.id

  TextColumn get filePath => text()();

  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
