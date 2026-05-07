import 'package:flutter_test/flutter_test.dart';
import 'package:assetguard_app/data/local_database/sqlite_database.dart';

void main() {
  test('Job serialises and deserialises correctly', () {
    final job = Job(
      id: '123',
      title: 'Test Job',
      userId: 'user-1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      syncStatus: 'pending',
      isDeleted: false
    );

    final json = job.toJson();
    final restored = Job.fromJson(json);

    expect(restored.id, job.id);
    expect(restored.title, job.title);
    expect(restored.userId, job.userId);
    expect(restored.syncStatus, 'pending');
    expect(restored.isDeleted, false);
  });
}
