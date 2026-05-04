import '../local_database/sqlite_database.dart';
import '../services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Map<String, String> _getUserInfo() {
  final user = Supabase.instance.client.auth.currentUser!;
  return {'id': user.id, 'name': user.userMetadata?['full_name'] ?? 'Unknown'};
}

extension JobMapper on Job {

  Map<String, dynamic> toSupabaseJson() {
    final user = _getUserInfo();
    return {
      'id': id,
      'title': title,
      'userId': user['id'],
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      // DO NOT include isDeleted
      // DO NOT include syncStatus
    };
  }
}
class JobsRepository {
  final AppDatabase db;
  final SyncService syncService;
  JobsRepository({required this.db, required this.syncService});
  
  // CREATE
  Future<void> createJob({
    required String title,

  }) async {
    final id = const Uuid().v4();
    final user = _getUserInfo();

    await db.jobsDao.insertJob(
      JobsCompanion.insert(
        id: id,
        title: title,
        userId: user['id']!,
        createdAt: DateTime.now(),
        syncStatus: 'pending',
      ),
    );

    // Try to sync immediately
    await syncService.syncJobs();
  }

  // READ ALL
  Future<List<Job>> getAllJobs() async {
    await syncService.syncJobs();
    return db.jobsDao.getJobs();
  }

  // READ ONE
  Future<Job?> getJobById(String id) async {
    final jobs = await db.jobsDao.getJobs();
    for (final job in jobs){
      if (job.id == id){
        return job;
      }
    }
    return null;
  }

  // UPDATE
  Future<void> updateJob(
    String id, {
    String? title,
  }) async {
 
    await db.jobsDao.updateJob(
      id,
      JobsCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );

    await syncService.syncJobs();
  }

  // DELETE
  Future<void> deleteJob(String id) async {
    await db.jobsDao.softDelete(id); // Marks the delete flag to be true and sync status to 'pending'
    await syncService.syncJobs();
  }

  // FORCE SYNC (manual button)
  Future<void> syncNow() async {
    await syncService.syncJobs();
  }
}

