import 'package:flutter/foundation.dart';
import '../../../data/repositories/jobs_repository.dart';
import 'package:intl/intl.dart';

class JobEditViewModel extends ChangeNotifier {
  final JobsRepository repository;
  late String jobId = "";
  String jobTitle = "";
  DateTime? updatedAt;

  JobEditViewModel(this.repository);
  String? _error;
  String? get error => _error;
  bool isLoading = false;
  bool isSaving = false;

  Future<void> loadJob(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final job = await repository.getJobById(id);
      jobId = job!.id;
      jobTitle = job.title;
      updatedAt = job.updatedAt;
    } catch (e) {
      _error = 'Error: Unable to load jobId: $jobId. Error message: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateJob() async {
    isSaving = true;
    notifyListeners();
    try {
      await repository.updateJob(jobId, title: jobTitle);
    } catch (e) {
      _error = 'Error: Unable to update jobId: $jobId. Error message: $e';
    }
    isSaving = false;
    notifyListeners();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
