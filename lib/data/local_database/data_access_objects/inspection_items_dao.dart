import 'package:drift/drift.dart';
import '../sqlite_database.dart';
import '../tables/inspection_items.dart';

part 'inspection_items_dao.g.dart';

@DriftAccessor(tables: [InspectionItems])
class InspectionItemsDao extends DatabaseAccessor<AppDatabase>
    with _$InspectionItemsDaoMixin {
  InspectionItemsDao(AppDatabase db) : super(db);

  // CREATE
  Future<int> insertItem(InspectionItemsCompanion item) =>
      into(inspectionItems).insert(item);

  // READ all inspection items for the job due to FK constraint. 
  Future<List<InspectionItem>> getItemsForJob(String jobId) {
    return (select(inspectionItems)
          ..where((tbl) => tbl.jobId.equals(jobId))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  // READ single item
  Future<InspectionItem?> getItemById(String id) {
    return (select(inspectionItems)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // READ pending items (for sync) in sync service. 
  Future<List<InspectionItem>> getPendingItems() {
    return (select(inspectionItems)
          ..where((tbl) => tbl.syncStatus.equals('pending')))
        .get();
  }

  // UPDATE item.
  Future<bool> updateItem(String id, InspectionItemsCompanion fields) async {
    final rows = await (update(inspectionItems)
          ..where((tbl) => tbl.id.equals(id)))
        .write(fields);
    return rows > 0;
  }

  // SOFT DELETE - Marking the deleted flag as true. 
  Future<void> softDelete(String id) {
    return (update(inspectionItems)..where((tbl) => tbl.id.equals(id))).write(
      const InspectionItemsCompanion(
        isDeleted: Value(true),
        syncStatus: Value('pending'),
      ),
    );
  }

  // HARD DELETE - If need to delete it off the local_db (However when getting all, i made sure to retrieve data that are not meant to be deleted. Also, deleted databases are deleted in Supabase. )
  Future<int> deleteItem(String id) {
    return (delete(inspectionItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  // UPDATE (Sync)
  Future<int> updateItemSync(String id, InspectionItemsCompanion fields) {
    return (update(inspectionItems)
          ..where((tbl) => tbl.id.equals(id)))
        .write(fields);
  }

  // MARK AS SYNCED
  Future<void> markSynced(String id) {
    return (update(inspectionItems)..where((tbl) => tbl.id.equals(id))).write(
      const InspectionItemsCompanion(syncStatus: Value('synced')),
    );
  }

  // INSERT OR UPDATE FROM CLOUD
  Future<void> insertFromCloud(Map<String, dynamic> json) async {
    final id = json['id'].toString();

    final updated = await (update(inspectionItems)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
          InspectionItemsCompanion(
            jobId: Value(json['job_id'].toString()),
            description: Value(json['description'] ?? ''),
            notes: Value(json['notes']),
            createdBy: Value(json['created_by'] ?? 'Unknown'),
            updatedAt: json['updated_at'] != null
                ? Value(DateTime.parse(json['updated_at']))
                : const Value(null),
            syncStatus: const Value('synced'),
            isDeleted: Value(json['is_deleted'] ?? false),
          ),
        );

    if (updated == 0) {
      await into(inspectionItems).insert(
        InspectionItemsCompanion.insert(
          id: id,
          jobId: json['job_id'].toString(),
          description: json['description'] ?? '',
          notes: Value(json['notes']),
          createdBy: json['created_by'] ?? 'Unknown',
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: json['updated_at'] != null
              ? Value(DateTime.parse(json['updated_at']))
              : const Value(null),
          syncStatus: 'synced',
          isDeleted: Value(json['is_deleted'] ?? false),
        ),
      );
    }
  }
}
