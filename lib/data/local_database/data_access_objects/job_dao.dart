import 'package:drift/drift.dart';
import '../sqlite_database.dart';
import '../tables/jobs.dart';

part 'job_dao.g.dart';

@DriftAccessor(tables: [Jobs])
class JobsDao extends DatabaseAccessor<AppDatabase> with _$JobsDaoMixin {
  JobsDao(AppDatabase db) : super(db);

  // CREATE
  Future<int> insertJob(JobsCompanion job) => into(jobs).insert(job);

  // READ
  Future<List<Job>> getJobs() =>
      (select(jobs)..where((tbl) => tbl.isDeleted.equals(false))).get();

  // READ pending (for sync)
  Future<List<Job>> getPendingJobs() =>
      (select(jobs)..where((tbl) => tbl.syncStatus.equals('pending'))).get();

  // UPDATE (UI) returns Future<bool>
  Future<bool> updateJob(String id, JobsCompanion updatedFields) async {
    final rowsAffected = await (update(
      jobs,
    )..where((tbl) => tbl.id.equals(id))).write(updatedFields);
    return rowsAffected > 0;
  }

  // Mark job as deleted

  Future<void> softDelete(String id) {
    return (update(jobs)..where((tbl) => tbl.id.equals(id))).write(
      JobsCompanion(isDeleted: Value(true), syncStatus: Value('pending')),
    );
  }

  // Deletes job
  Future<int> deleteJob(String id) {
    return (delete(jobs)..where((tbl) => tbl.id.equals(id))).go();
  }

  // UPDATE (Sync) → returns Future<int>
  Future<int> updateJobSync(String id, JobsCompanion updatedFields) {
    return (update(
      jobs,
    )..where((tbl) => tbl.id.equals(id))).write(updatedFields);
  }

  // MARK AS SYNCED
  Future<void> markSynced(String id) =>
      (update(jobs)..where((tbl) => tbl.id.equals(id))).write(
        const JobsCompanion(syncStatus: Value('synced')),
      );
  // function to help merge cloud db with local db to adhere to offline first. 
  Future<void> insertFromCloud(Map<String, dynamic> json) async {
    final id = json['id'] as String;

    // 1. Try UPDATE first
    final updated = await (update(jobs)..where((tbl) => tbl.id.equals(id)))
        .write(
          JobsCompanion(
            userId: Value(json['userId'] ?? 'Unknown'),
            title: Value(json['title']),
            updatedAt: json['updatedAt'] != null // only should be at updates. 
                ? Value(DateTime.parse(json['updatedAt']))
                : const Value(null),
            syncStatus: const Value('synced'),
            isDeleted: Value(false),
          ),
        );

    // 2. If no rows updated make sure to try INSERT
    if (updated == 0) {
      await into(jobs).insert(
        JobsCompanion.insert(
          id: id,
          userId: json['userId'] ?? 'Unknown',
          title: json['title'],
          createdAt: DateTime.parse(json['createdAt']), // created should only be at creation.
          syncStatus: 'synced',
          isDeleted: Value(false),
        ),
      );
    }
  }
}
