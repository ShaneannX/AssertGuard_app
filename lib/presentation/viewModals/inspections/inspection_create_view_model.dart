import 'package:flutter/material.dart';
import '../../../data/repositories/inspection_respository.dart';

class CreateInspectionItemViewModel extends ChangeNotifier {
  final InspectionItemsRespository repository;

  CreateInspectionItemViewModel(this.repository);

  final descriptionController = TextEditingController();
  final notesController = TextEditingController();


  bool isLoading = false;
  bool created = false;
  String? errorMessage;

  // Create inspection item
  Future<void> createItem({
    required String jobId,

  }) async {
    final description = descriptionController.text.trim();
    final notes = notesController.text.trim();


    if (description.isEmpty) {
      errorMessage = "Description is required";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await repository.createInspectionItems(
        jobId: jobId,
        description: description,
        notes: notes.isEmpty ? null : notes,
      );

      created = true;
    } catch (e) {
      errorMessage = "Failed to create inspection item";
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
