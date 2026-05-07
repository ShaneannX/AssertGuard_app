import 'package:flutter_test/flutter_test.dart';
import 'package:assetguard_app/data/local_database/sqlite_database.dart';

void main() {
  test('InspectionItem serialises and deserialises correctly', () {
    final item = InspectionItem(
      id: 'item-123',
      jobId: 'job-123',
      description: 'Inspect the ladder',
      notes: 'Needs new bolts',
      createdBy: 'user-1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      syncStatus: 'pending',
      isDeleted: false,
    );

    final json = item.toJson();
    final restored = InspectionItem.fromJson(json);

    expect(restored.id, item.id);
    expect(restored.jobId, item.jobId);
    expect(restored.description, item.description);
    expect(restored.notes, item.notes);
    expect(restored.createdBy, item.createdBy);
    expect(restored.createdAt, item.createdAt);
    expect(restored.updatedAt, item.updatedAt);
    expect(restored.syncStatus, item.syncStatus);
    expect(restored.isDeleted, item.isDeleted);
  });
}
