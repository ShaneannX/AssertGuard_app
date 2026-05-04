import 'data_access_objects/job_dao.dart';
import 'data_access_objects/inspection_items_dao.dart';
import 'data_access_objects/attachments_dao.dart';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/jobs.dart';
import 'tables/inspection_items.dart';
import 'tables/attachments.dart';



part 'sqlite_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'assetguard.db'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [Jobs, InspectionItems, Attachments],
  daos: [JobsDao, InspectionItemsDao, AttachmentsDao]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
