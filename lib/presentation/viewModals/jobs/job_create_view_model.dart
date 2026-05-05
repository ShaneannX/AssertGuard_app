import 'package:flutter/foundation.dart';
import '../../../data/repositories/jobs_repository.dart';
import 'package:intl/intl.dart';

class CreateJobViewModel extends ChangeNotifier {
  final JobsRepository repository;
  String title = "";
  
  CreateJobViewModel(this.repository);

  bool isSaving = false;
  String? _error;
  String? get error => _error;

  void setTitle(String value){
    title = value;
    notifyListeners();
  }

  Future<void> createJob() async {
    if (title.trim().isEmpty) return;

    isSaving = true;
    notifyListeners();
    try{
      await repository.createJob(title: title);
    } catch(e){
      _error = 'Error: Unable to update Job: $title. Error message: $e';
    }
    isSaving = false;
    notifyListeners();
  }

  String formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

}