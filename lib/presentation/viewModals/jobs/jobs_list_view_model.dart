import 'package:flutter/foundation.dart';
import '../../../data/repositories/jobs_repository.dart';
import '../../../data/local_database/sqlite_database.dart';
import 'package:intl/intl.dart';
class JobsListViewModel extends ChangeNotifier {
  final JobsRepository repository;

  JobsListViewModel(this.repository);

  List<Job> _jobs = [];
  List<Job> get jobs => _jobs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Load all non-deleted jobs
  Future<void> loadJobs() async {
    _setLoading(true);

    try {
      _jobs = await repository.getAllJobs();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch jobs :  $e';
    }

    _setLoading(false);
  }

  /// Delete a job (soft delete → sync → refresh)
  Future<void> deleteJob(String id) async {
    _setLoading(true);

    try {
      await repository.deleteJob(id); // soft delete + sync
      await loadJobs();               // refresh list
    } catch (e) {
      _error = 'Failed to delete job';
    }

    _setLoading(false);
  }

  /// Manual refresh (pull-to-refresh)
  Future<void> refresh() async {
    await loadJobs();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

}
