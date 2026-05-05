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
}
