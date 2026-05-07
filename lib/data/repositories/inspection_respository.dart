import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local_database/sqlite_database.dart';
import '../services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InspectionItemsRespository {
  final AppDatabase db;
  final SyncService sync;
  final Map<String, String> Function()? userInfoOverride;

  InspectionItemsRespository({
    required this.db,
    required this.sync,
    this.userInfoOverride,
  });

  Map<String, String> _getUserInfo() {
    if (userInfoOverride != null) {
      return userInfoOverride!();
    }

    final user = Supabase.instance.client.auth.currentUser!;
    return {
      'id': user.id,
      'name': user.userMetadata?['full_name'] ?? 'Unknown',
    };
  }

  // Create new Inspection items
  Future<void> createInspectionItems({
    required String jobId,
    required String description,
    String? notes,
  }) async {
    final id = const Uuid().v4();

    final user = _getUserInfo();

    await db.inspectionItemsDao.insertItem(
      InspectionItemsCompanion.insert(
        id: id,
        jobId: jobId,
        description: description,
        notes: Value(notes),
        createdAt: DateTime.now(),
        createdBy: user['id']!,
        syncStatus: 'pending',
      ),
    );
    await sync.syncJobInspection();
  }

  // Read all jobs
  Future<List<InspectionItem>> getItemsForJob(String jobId) {
    return db.inspectionItemsDao.getItemsForJob(jobId);
  }

  // Read only one inspection items
  Future<InspectionItem?> getItem(String id) {
    return db.inspectionItemsDao.getItemById(id);
  }

  Future<bool> updateInspectionItem({
    required String id,
    required String description,
    String? notes,
  }) async {
    final updated = await db.inspectionItemsDao.updateItem(
      id,
      InspectionItemsCompanion(
        description: Value(description),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );

    if (updated) {
      await sync.syncJobInspection();
    }
    return updated;
  }
  // SOFT DELETE
  Future<void> softDelete(String id) async {
    await db.inspectionItemsDao.softDelete(id);
    await sync.syncJobInspection();
  }

  // HARD DELETE
  Future<void> deleteItem(String id) async {
    await db.inspectionItemsDao.deleteItem(id);
  }

  // SYNC: insert/update from cloud
  Future<void> insertFromCloud(Map<String, dynamic> json) async {
    await db.inspectionItemsDao.insertFromCloud(json);
  }

  // SYNC: mark as synced
  Future<void> markSynced(String id) async {
    await db.inspectionItemsDao.markSynced(id);
  }

  // SYNC: get pending
  Future<List<InspectionItem>> getPendingItems() {
    return db.inspectionItemsDao.getPendingItems();
  }
}
