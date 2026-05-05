import 'package:flutter/material.dart';
import '../../../data/repositories/inspection_respository.dart';
import '../../../data/local_database/sqlite_database.dart';

class EditInspectionItemViewModel extends ChangeNotifier {
  final InspectionItemsRespository repository;

  EditInspectionItemViewModel(this.repository);

  final descriptionController = TextEditingController();
  final notesController = TextEditingController();

  InspectionItem? item;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  bool updated = false;

  Future<void> loadItem(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      item = await repository.getItem(id);

      if (item == null) {
        errorMessage = "Inspection item not found";
      } else {
        descriptionController.text = item!.description;
        notesController.text = item!.notes ?? "";
      }
    } catch (e) {
      errorMessage = "Failed to load inspection item";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (item == null) return;

    final description = descriptionController.text.trim();
    final notes = notesController.text.trim();

    if (description.isEmpty) {
      errorMessage = "Description is required";
      notifyListeners();
      return;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await repository.updateInspectionItem(
        id: item!.id,
        description: description,
        notes: notes.isEmpty ? null : notes,
      );

      updated = success;
    } catch (e) {
      errorMessage = "Failed to update inspection item";
    }

    isSaving = false;
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
