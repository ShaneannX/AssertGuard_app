import 'package:assetguard_app/data/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:assetguard_app/data/repositories/jobs_repository.dart';
import 'package:assetguard_app/data/local_database/sqlite_database.dart';
import 'package:assetguard_app/data/local_database/data_access_objects/job_dao.dart';

// Mocks
class MockDb extends Mock implements AppDatabase {}
class MockJobsDao extends Mock implements JobsDao {}
class MockSync extends Mock implements SyncService {}

// Fake for Drift companion
class FakeJobsCompanion extends Fake implements JobsCompanion {}

void main() {
  late MockDb db;
  late MockJobsDao jobsDao;
  late MockSync sync;

  setUpAll(() {
    registerFallbackValue(FakeJobsCompanion());
  });

  setUp(() {
    db = MockDb();
    jobsDao = MockJobsDao();
    sync = MockSync();

    when(() => db.jobsDao).thenReturn(jobsDao);
  });

  test('createJob sets syncStatus to pending and triggers sync', () async {
    when(() => jobsDao.insertJob(any())).thenAnswer((_) async => 1);
    when(() => sync.syncJobs()).thenAnswer((_) async {});

    final repo = JobsRepository(
      db: db,
      syncService: sync,
      userInfoOverride: () => {
        'id': 'test-user',
        'name': 'Test User',
      },
    );

    await repo.createJob(title: 'Job 1');

    final verification = verify(() => jobsDao.insertJob(captureAny()));
    verification.called(1);

    final captured = verification.captured.single as JobsCompanion;

    expect(captured.title.value, 'Job 1');
    expect(captured.userId.value, 'test-user');
    expect(captured.syncStatus.value, 'pending');

    verify(() => sync.syncJobs()).called(1);
  });

  test('updateJob updates fields and triggers sync', () async {
    when(() => jobsDao.updateJob(any(), any())).thenAnswer((_) async => true);
    when(() => sync.syncJobs()).thenAnswer((_) async {});

    final repo = JobsRepository(
      db: db,
      syncService: sync,
      userInfoOverride: () => {
        'id': 'test-user',
        'name': 'Test User',
      },
    );

    await repo.updateJob(
      'job-123',
      title: 'Updated Title',
    );

    verify(() => jobsDao.updateJob('job-123', any())).called(1);
    verify(() => sync.syncJobs()).called(1);
  });

  test('deleteJob performs soft delete and triggers sync', () async {
    when(() => jobsDao.softDelete(any())).thenAnswer((_) async {});
    when(() => sync.syncJobs()).thenAnswer((_) async {});

    final repo = JobsRepository(
      db: db,
      syncService: sync,
      userInfoOverride: () => {
        'id': 'test-user',
        'name': 'Test User',
      },
    );

    await repo.deleteJob('job-123');

    verify(() => jobsDao.softDelete('job-123')).called(1);
    verify(() => sync.syncJobs()).called(1);
  });

  test('getAllJobs triggers sync then returns jobs', () async {
    when(() => sync.syncJobs()).thenAnswer((_) async {});
    when(() => jobsDao.getJobs()).thenAnswer((_) async => []);

    final repo = JobsRepository(
      db: db,
      syncService: sync,
      userInfoOverride: () => {
        'id': 'test-user',
        'name': 'Test User',
      },
    );

    final result = await repo.getAllJobs();

    expect(result, isA<List<Job>>());
    verify(() => sync.syncJobs()).called(1);
    verify(() => jobsDao.getJobs()).called(1);
  });

  test('getJobById returns matching job', () async {
    final job = Job(
      id: 'job-123',
      title: 'Test Job',
      userId: 'test-user',
      createdAt: DateTime.now(),
      updatedAt: null,
      syncStatus: 'pending',
      isDeleted: false,
    );

    when(() => jobsDao.getJobs()).thenAnswer((_) async => [job]);

    final repo = JobsRepository(
      db: db,
      syncService: sync,
      userInfoOverride: () => {
        'id': 'test-user',
        'name': 'Test User',
      },
    );

    final result = await repo.getJobById('job-123');

    expect(result, isNotNull);
    expect(result!.id, 'job-123');
  });
}
