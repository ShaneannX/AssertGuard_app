import 'dart:async';
import 'package:assetguard_app/data/repositories/jobs_repository.dart';
import '../local_database/sqlite_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connectivity_service.dart';

class SyncService {
  final AppDatabase db;
  final supabase = Supabase.instance.client;
  final ConnectivityService connectivity;

  // STREAMS
  final _syncingController = StreamController<bool>.broadcast();
  Stream<bool> get syncing => _syncingController.stream;

  final _failedController = StreamController<bool>.broadcast();
  Stream<bool> get failed => _failedController.stream;

  final _syncedController = StreamController<bool>.broadcast();
  Stream<bool> get synced => _syncedController.stream;

  final _offlineController = StreamController<bool>.broadcast();
  Stream<bool> get offline => _offlineController.stream;

  bool _isSyncing = false;

  SyncService({required this.db, required this.connectivity}) {
    connectivity.onStatusChange.listen((isOnline) async {
      if (isOnline) {
  
        _failedController.add(false);
        _offlineController.add(false);
        final hasPendingJobs = (await db.jobsDao.getPendingJobs()).isNotEmpty;
        final hasPendingItems =
            (await db.inspectionItemsDao.getPendingItems()).isNotEmpty;

        if ((hasPendingJobs || hasPendingItems) && !_isSyncing) {
          await syncJobs();
          await syncJobInspection();
        }
      } else {
        _offlineController.add(true);

        _failedController.add(false);
        _syncedController.add(false);
      }
    });
  }

  Future<void> syncJobs() async {
    if (!(await connectivity.isOnline())) return;

    _isSyncing = true;
    _syncingController.add(true);

    bool success = true;

    final pending = await db.jobsDao.getPendingJobs();
    final cloudJobs = await supabase.from('jobs').select();
    final localJobs = await db.jobsDao.getJobs();
    final localIds = localJobs.map((j) => j.id).toSet();
    final cloudOnly = cloudJobs.where((job) => !localIds.contains(job['id']));

    try {
      for (final job in cloudOnly) {
        try {
          await db.jobsDao.insertFromCloud(job);
        } catch (e) {
          print('Error inserting cloud job: $e');
          success = false;
        }
      }

      for (final job in pending) {
        if (job.isDeleted) {
          try {
            await supabase.from('jobs').delete().eq('id', job.id);
            await db.jobsDao.markSynced(job.id);
            await db.jobsDao.softDelete(job.id);
          } catch (e) {
            print('Deletion failed for job ${job.id}: $e');
            success = false;
          }
          continue;
        }

        try {
          await supabase.from('jobs').upsert(job.toSupabaseJson());
          await db.jobsDao.markSynced(job.id);
        } catch (e) {
          print('Upsert failed for job ${job.id}: $e');
          success = false;
        }
      }
    } finally {
      _syncingController.add(false);
      _isSyncing = false;

      if (success) {
        _syncedController.add(true);
        _failedController.add(false);
      } else {
        _syncedController.add(false);
        _failedController.add(true);
      }

    }
  }

  Future<void> syncJobInspection() async {
    if (!(await connectivity.isOnline())) return;

    _isSyncing = true;
    _syncingController.add(true);

    bool success = true;

    final pending = await db.inspectionItemsDao.getPendingItems();
    final cloudItems = await supabase.from('inspection_items').select();
    final localItems = await db.inspectionItemsDao.getAllItems();
    final localIds = localItems.map((i) => i.id).toSet();
    final cloudOnly = cloudItems.where(
      (item) => !localIds.contains(item['id']),
    );

    try {
      for (final item in cloudOnly) {
        try {
          await db.inspectionItemsDao.insertFromCloud(item);
        } catch (e) {
          print('Error inserting cloud inspection item: $e');
          success = false;
        }
      }

      for (final item in pending) {
        if (item.isDeleted) {
          try {
            await supabase.from('inspection_items').delete().eq('id', item.id);
            await db.inspectionItemsDao.markSynced(item.id);
            await db.inspectionItemsDao.softDelete(item.id);
          } catch (e) {
            print('Deletion failed for inspection item ${item.id}: $e');
            success = false;
          }
          continue;
        }

        try {
          await supabase.from('inspection_items').upsert({
            'id': item.id,
            'jobId': item.jobId,
            'description': item.description,
            'notes': item.notes,
            'createdAt': item.createdAt.toIso8601String(),
            'updatedAt': item.updatedAt?.toIso8601String(),
          });
          await db.inspectionItemsDao.markSynced(item.id);
        } catch (e) {
          print('Upsert failed for inspection item ${item.id}: $e');
          success = false;
        }
      }
    } finally {
      _syncingController.add(false);
      _isSyncing = false;

      if (success) {
        _syncedController.add(true);
        _failedController.add(false);
      } else {
        _syncedController.add(false);
        _failedController.add(true);
      }

    }
  }
}
