import 'package:assetguard_app/data/local_database/sqlite_database.dart';
import 'package:assetguard_app/data/local_database/data_access_objects/inspection_items_dao.dart';
import 'package:assetguard_app/data/repositories/inspection_respository.dart';
import 'package:assetguard_app/data/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}
class MockInspectionItemsDao extends Mock implements InspectionItemsDao {}
class MockSyncService extends Mock implements SyncService {}
class FakeInspectionItemsCompanion extends Fake implements InspectionItemsCompanion {}

void main() {
  late MockAppDatabase db;
  late MockInspectionItemsDao inspectionItemsDao;
  late MockSyncService sync;

  setUpAll(() {
    registerFallbackValue(FakeInspectionItemsCompanion());
  });

  setUp(() {
    db = MockAppDatabase();
    inspectionItemsDao = MockInspectionItemsDao();
    sync = MockSyncService();

    when(() => db.inspectionItemsDao).thenReturn(inspectionItemsDao);
  });

  test('createInspectionItems inserts pending item and triggers sync', () async {
    when(() => inspectionItemsDao.insertItem(any())).thenAnswer((_) async => 1);
    when(() => sync.syncJobInspection()).thenAnswer((_) async {});

    final repository = InspectionItemsRespository(
      db: db,
      sync: sync,
      userInfoOverride: () => {'id': 'test-user', 'name': 'Test User'},
    );

    await repository.createInspectionItems(
      jobId: 'job-123',
      description: 'Test description',
      notes: 'Test notes',
    );

    final verification = verify(() => inspectionItemsDao.insertItem(captureAny()));
    verification.called(1);
    final captured = verification.captured.single as InspectionItemsCompanion;

    expect(captured.jobId.value, 'job-123');
    expect(captured.description.value, 'Test description');
    expect(captured.notes.value, 'Test notes');
    expect(captured.syncStatus.value, 'pending');
    verify(() => sync.syncJobInspection()).called(1);
  });

  test('updateInspectionItem triggers sync when update succeeds', () async {
    when(() => inspectionItemsDao.updateItem(any(), any())).thenAnswer((_) async => true);
    when(() => sync.syncJobInspection()).thenAnswer((_) async {});

    final repository = InspectionItemsRespository(db: db, sync: sync);

    final updated = await repository.updateInspectionItem(
      id: 'item-123',
      description: 'Updated description',
      notes: 'Updated notes',
    );

    expect(updated, isTrue);
    verify(() => inspectionItemsDao.updateItem('item-123', any())).called(1);
    verify(() => sync.syncJobInspection()).called(1);
  });

  test('softDelete marks item pending and triggers sync', () async {
    when(() => inspectionItemsDao.softDelete(any())).thenAnswer((_) async {});
    when(() => sync.syncJobInspection()).thenAnswer((_) async {});

    final repository = InspectionItemsRespository(db: db, sync: sync);

    await repository.softDelete('item-123');

    verify(() => inspectionItemsDao.softDelete('item-123')).called(1);
    verify(() => sync.syncJobInspection()).called(1);
  });
}
