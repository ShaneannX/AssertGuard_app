import 'package:assetguard_app/data/repositories/jobs_repository.dart';
import '../local_database/sqlite_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connectivity_service.dart';

class SyncService {
  final AppDatabase db;
  final supabase = Supabase.instance.client;
  final ConnectivityService connectivity;

  SyncService({required this.db, required this.connectivity});

  Future<void> syncJobs() async {
    final pending = await db.jobsDao.getPendingJobs();
    final isOnline = await connectivity.isOnline();
    final cloudJobs = await supabase.from('jobs').select();
    final localJobs = await db.jobsDao.getJobs();
    final localIds = localJobs.map((j) => j.id).toSet();
    final cloudOnly = cloudJobs.where((job) => !localIds.contains(job['id']));

    if (isOnline) {
      // merge with local db
      for (final job in cloudOnly){
        try{
          await db.jobsDao.insertFromCloud(job);
        }catch(e){
          print('Error to update local: $e');
        }
      }

      for (final job in pending) {
        if (job.isDeleted) {
          try {
            await supabase.from('jobs').delete().eq('id', job.id);
            await db.jobsDao.markSynced(job.id);
          } catch (e) {
            print('Deletion Failed for job ${job.id}: $e');
          }
          continue;
        }
        try {
          print(job.toSupabaseJson());
          await supabase.from('jobs').upsert(job.toSupabaseJson());
          await db.jobsDao.markSynced(job.id);
        } catch (e) {
          print('Upsert failed for job ${job.id}: $e');
        }
        continue;
      }
    } else {
      return; // Skip as sync is not needed due to user being offline.
    }
  }


  Future<void> syncJobInspection() async {
    final isOnline = await connectivity.isOnline();
    if (!isOnline) return;

    final pending = await db.inspectionItemsDao.getPendingItems();

    final cloudItems = await supabase.from('inspection_items').select();

    final localItems = await db.inspectionItemsDao.getItemsForJob("");

    final localIds = localItems.map((i)=> i.id).toSet();

    final cloudOnly = cloudItems.where((item) => !localIds.contains(item['id']));

    for (final item in cloudOnly){
      try{
        await db.inspectionItemsDao.insertFromCloud(item);
      }catch(e){
        print('Error inserting inspection item from cloud: $e');
      }
      continue;
    }

    for (final item in pending){

      if (item.isDeleted){
        try{
          await supabase.from('inspection_items').delete().eq('id', item.id);

          await db.inspectionItemsDao.markSynced(item.id);
        }catch(e){
          print("Deletion failed for inspection item ${item.id}: $e");
        }
      }
      try{
      await supabase.from('inspection_items').upsert({
        'id': item.id,
        'jobId': item.jobId,
        'description': item.description,
        'notes': item.notes,
        'updatedAt': item.updatedAt?.toIso8601String,
      });
    }catch(e){
      print("Creating/ Updating inspection item ${item.id} Failed: $e");
    }
    }
    
  }
}
