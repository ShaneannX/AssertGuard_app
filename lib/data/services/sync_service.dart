import 'dart:async';

import 'package:assetguard_app/data/repositories/jobs_repository.dart';
import '../local_database/sqlite_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connectivity_service.dart';

class SyncService {
  final AppDatabase db;
  final supabase = Supabase.instance.client;
  final ConnectivityService connectivity;

  final _syncingController = StreamController<bool>.broadcast();
  Stream<bool> get syncing => _syncingController.stream;

  SyncService({required this.db, required this.connectivity});

  Future<void> syncJobs() async {
    final pending = await db.jobsDao.getPendingJobs();
    _syncingController.add(true);
    final cloudJobs = await supabase
        .from('jobs')
        .select(); // gets all jobs from supabase
    final localJobs = await db.jobsDao.getJobs(); // gets all jobs from local db
    final localIds = localJobs
        .map((j) => j.id)
        .toSet(); // gets local Id to see which one is missing within the local db.
    final cloudOnly = cloudJobs.where(
      (job) => !localIds.contains(job['id']),
    ); // gets all the cloud only data, so only data that the id does not exists in the local db.

    try {
      // merge with local db
      for (final job in cloudOnly) {
        try {
          await db.jobsDao.insertFromCloud(
            job,
          ); // Calls DAO to merge cloud only data into the local db.
        } catch (e) {
          print('Error to update local: $e');
        }
      }

      for (final job in pending) {
        // Then go through each job that is in the pending sync stage.
        if (job.isDeleted) {
          // check if isDeleted flag is true
          try {
            await supabase
                .from('jobs')
                .delete()
                .eq('id', job.id); // if so we delete them from Supabase
            await db.jobsDao.markSynced(
              job.id,
            ); // Then marked synced so it doesn't appear in pending anymore.
          } catch (e) {
            print('Deletion Failed for job ${job.id}: $e');
          }
          continue;
        }
        try {
          await supabase
              .from('jobs')
              .upsert(
                job.toSupabaseJson(),
              ); // Due to schema in supabase not needing isDeleted decided to format the json myself before passing to supabase.
          await db.jobsDao.markSynced(
            job.id,
          ); // after upsert, mark the sync status so it doesn't appear in pending.
        } catch (e) {
          print('Upsert failed for job ${job.id}: $e');
        }
        continue;
      }
    } finally {
      _syncingController.add(false);
    }
  }

  // similar process from above same for InspectionItems.
  Future<void> syncJobInspection() async {
    _syncingController.add(true);

    final pending = await db.inspectionItemsDao.getPendingItems();

    final cloudItems = await supabase.from('inspection_items').select();
    // final deleteEmptyJobIdItems = await db.inspectionItemsDao.deleteItemsWithEmptyJobId();
    // deleteEmptyJobIdItems;
    final localItems = await db.inspectionItemsDao.getAllItems();
    print('LOCAL ITEMS: $localItems');
    final localIds = localItems.map((i) => i.id).toSet();

    final cloudOnly = cloudItems.where(
      (item) => !localIds.contains(item['id']),
    );
    
    // print('CLOUD ONLY: $cloudOnly');
    try {
      for (final item in cloudOnly) {
        print('Syncing Cloud items');
        try {
          await db.inspectionItemsDao.insertFromCloud(item);
        } catch (e) {
          print('Error inserting inspection item from cloud: $e');
        }
        continue;
      }

      for (final item in pending) {
        if (item.isDeleted) {
          try {
            await supabase.from('inspection_items').delete().eq('id', item.id);

            await db.inspectionItemsDao.markSynced(item.id);
          } catch (e) {
            print("Deletion failed for inspection item ${item.id}: $e");
          }
        }
        try {
          // print('JOBID: $item.jobID');
          await supabase.from('inspection_items').upsert({
            // Decided to manually populate it within the service here.
            'id': item.id,
            'jobId': item.jobId,
            'description': item.description,
            'notes': item.notes,
            'createdAt': item.createdAt?.toIso8601String(),
            'updatedAt': item.updatedAt?.toIso8601String(),
          });
        } catch (e) {
          print("Creating/ Updating inspection item ${item.id} Failed: $e");
        }
      }
    } finally {
      _syncingController.add(false);
    }
  }
}
