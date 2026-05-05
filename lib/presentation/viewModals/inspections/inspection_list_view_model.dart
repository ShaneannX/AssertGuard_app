import 'package:flutter/material.dart';
import '../../../data/repositories/inspection_respository.dart';
import '../../../data/local_database/sqlite_database.dart';

class InspectionItemViewViewModel extends ChangeNotifier {
  final InspectionItemsRespository repository;

  InspectionItemViewViewModel(this.repository);
  InspectionItem? item;
  bool isLoading = false;
  String? errorMessage;

  List<InspectionItem> items = [];

  Future<void> loadAll(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      items = await repository.getItemsForJob(id);
    } catch (e) {
      errorMessage = "Failed to load inspection items";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadItem(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      item = await repository.getItem(id);

      if (item == null) {
        errorMessage = "Inspection item not found";
      }
    } catch (e) {
      errorMessage = "Failed to load inspection item";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteItem() async {
    if (item == null) return;

    await repository.softDelete(item!.id);
  }
}
