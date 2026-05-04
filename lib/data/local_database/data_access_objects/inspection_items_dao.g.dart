// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_items_dao.dart';

// ignore_for_file: type=lint
mixin _$InspectionItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobsTable get jobs => attachedDatabase.jobs;
  $InspectionItemsTable get inspectionItems => attachedDatabase.inspectionItems;
  InspectionItemsDaoManager get managers => InspectionItemsDaoManager(this);
}

class InspectionItemsDaoManager {
  final _$InspectionItemsDaoMixin _db;
  InspectionItemsDaoManager(this._db);
  $$JobsTableTableManager get jobs =>
      $$JobsTableTableManager(_db.attachedDatabase, _db.jobs);
  $$InspectionItemsTableTableManager get inspectionItems =>
      $$InspectionItemsTableTableManager(
        _db.attachedDatabase,
        _db.inspectionItems,
      );
}
