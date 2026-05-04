import 'package:drift/drift.dart';
import '../sqlite_database.dart';
import '../tables/attachments.dart';

part 'attachments_dao.g.dart';

@DriftAccessor(tables: [Attachments])
class AttachmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentsDaoMixin {
  AttachmentsDao(AppDatabase db) : super(db);


  Future<int> insertAttachment(AttachmentsCompanion data) =>
      into(attachments).insert(data);


  Future<List<Attachment>> getAttachmentsForItem(String inspectionItemId) {
    return (select(attachments)
          ..where((tbl) => tbl.inspectionItemId.equals(inspectionItemId))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }


  Future<Attachment?> getAttachmentById(String id) {
    return (select(attachments)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }


  Future<List<Attachment>> getPendingAttachments() {
    return (select(attachments)
          ..where((tbl) => tbl.syncStatus.equals('pending')))
        .get();
  }

  
  Future<bool> updateAttachment(
      String id, AttachmentsCompanion fields) async {
    final rows = await (update(attachments)
          ..where((tbl) => tbl.id.equals(id)))
        .write(fields);
    return rows > 0;
  }

  
  Future<void> softDelete(String id) {
    return (update(attachments)..where((tbl) => tbl.id.equals(id))).write(
      const AttachmentsCompanion(
        isDeleted: Value(true),
        syncStatus: Value('pending'),
      ),
    );
  }


  Future<int> deleteAttachment(String id) {
    return (delete(attachments)..where((tbl) => tbl.id.equals(id))).go();
  }

 
  Future<int> updateAttachmentSync(
      String id, AttachmentsCompanion fields) {
    return (update(attachments)
          ..where((tbl) => tbl.id.equals(id)))
        .write(fields);
  }


  Future<void> markSynced(String id) {
    return (update(attachments)..where((tbl) => tbl.id.equals(id))).write(
      const AttachmentsCompanion(syncStatus: Value('synced')),
    );
  }


  Future<void> insertFromCloud(Map<String, dynamic> json) async {
    final id = json['id'].toString();

    final updated = await (update(attachments)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
          AttachmentsCompanion(
            inspectionItemId:
                Value(json['inspection_item_id'].toString()),
            filePath: Value(json['file_path'] ?? ''),
            updatedAt: json['updated_at'] != null
                ? Value(DateTime.parse(json['updated_at']))
                : const Value(null),
            syncStatus: const Value('synced'),
            isDeleted: Value(json['is_deleted'] ?? false),
          ),
        );

    if (updated == 0) {
      await into(attachments).insert(
        AttachmentsCompanion.insert(
          id: id,
          inspectionItemId: json['inspection_item_id'].toString(),
          filePath: json['file_path'] ?? '',
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
