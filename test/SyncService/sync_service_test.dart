import 'dart:async';

import 'package:assetguard_app/data/local_database/sqlite_database.dart';
import 'package:assetguard_app/data/local_database/data_access_objects/inspection_items_dao.dart';
import 'package:assetguard_app/data/local_database/data_access_objects/job_dao.dart';
import 'package:assetguard_app/data/services/connectivity_service.dart';
import 'package:assetguard_app/data/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAppDatabase extends Mock implements AppDatabase {}
class MockJobsDao extends Mock implements JobsDao {}
class MockInspectionItemsDao extends Mock implements InspectionItemsDao {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockAppDatabase db;
  late MockJobsDao jobsDao;
  late MockInspectionItemsDao inspectionItemsDao;
  late MockConnectivityService connectivity;
  late MockSupabaseClient supabase;

  setUp(() {
    db = MockAppDatabase();
    jobsDao = MockJobsDao();
    inspectionItemsDao = MockInspectionItemsDao();
    connectivity = MockConnectivityService();
    supabase = MockSupabaseClient();

    when(() => db.jobsDao).thenReturn(jobsDao);
    when(() => db.inspectionItemsDao).thenReturn(inspectionItemsDao);
    when(() => connectivity.onStatusChange).thenAnswer((_) => const Stream<bool>.empty());
  });

  test('syncJobs returns immediately when offline', () async {
    when(() => connectivity.isOnline()).thenAnswer((_) async => false);

    final service = SyncService(db: db, connectivity: connectivity, supabase: supabase);

    await service.syncJobs();

    verifyNever(() => db.jobsDao.getPendingJobs());
    verifyNever(() => db.jobsDao.getJobs());
    verifyNever(() => inspectionItemsDao.getPendingItems());
  });

  test('connectivity offline event emits offline and unsynced state', () async {
    final controller = StreamController<bool>.broadcast();
    when(() => connectivity.onStatusChange).thenAnswer((_) => controller.stream);

    final service = SyncService(db: db, connectivity: connectivity, supabase: supabase);

    final offlineEmitted = expectLater(service.offline, emits(true));
    final syncedEmitted = expectLater(service.synced, emits(false));

    controller.add(false);
    await Future.wait([offlineEmitted, syncedEmitted]);

    await controller.close();
  });
}
