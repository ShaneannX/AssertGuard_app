import 'package:flutter/material.dart';
import '../../../data/repositories/inspection_respository.dart';
import '../../../data/local_database/sqlite_database.dart';

class JobInspectionListViewModel extends ChangeNotifier {
  final InspectionItemsRespository repo;

  JobInspectionListViewModel(this.repo);

  List<InspectionItem> items = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load(String jobId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      items = await repo.getItemsForJob(jobId);
    } catch (e) {
      errorMessage = "Failed to load inspection items";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteItem(String id, String jobId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final delete = await repo.softDelete(id); // soft delete + sync
      delete;
      items = await repo.getItemsForJob(jobId); // refresh list
    } catch (e) {
      errorMessage = 'Failed to delete job';
    }

    isLoading = false;
    notifyListeners();
  }
}
