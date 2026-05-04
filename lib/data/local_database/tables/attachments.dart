import 'package:drift/drift.dart';
import 'inspection_items.dart';

class Attachments extends Table {
  TextColumn get id => text()(); // PK

  TextColumn get inspectionItemId =>
      text().references(InspectionItems, #id)(); // FK for InspectionItems.id

  TextColumn get filePath => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  TextColumn get syncStatus => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}
