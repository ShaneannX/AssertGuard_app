import 'job_edit_screen.dart';
import 'job_create_screen.dart';
import '../inspections/create_inspection_item_screen.dart';
import '../inspections/view_inspection_item_screen.dart';
import 'package:flutter/material.dart';
import '../../viewModals/jobs/jobs_list_view_model.dart';
import '../../../data/repositories/jobs_repository.dart'; // Drift Job model
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/sync_service.dart';
import '../../../data/local_database/local_database_instance.dart';

final connectivity = ConnectivityService();
final syncService = SyncService(db: db, connectivity: connectivity);
final jobsRepository = JobsRepository(db: db, syncService: syncService);

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  JobsListScreenState createState() => JobsListScreenState();
}

class JobsListScreenState extends State<JobsListScreen> {
  late JobsListViewModel vm;

  Future<void> _confirmDelete(
    BuildContext context,
    String jobId,
    String jobTitle,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Job: $jobTitle'),
          content: const Text('Are you sure you want to delete this job?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await vm.deleteJob(jobId);
    }
  }

  @override
  void initState() {
    super.initState();
    vm = JobsListViewModel(jobsRepository);
    vm.addListener(_onVmChanged);
    vm.loadJobs();
  }

  @override
  void dispose() {
    vm.removeListener(_onVmChanged);
    vm.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    setState(() {}); // rebuild UI when ViewModel notifies
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Dashboard')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'syncButton',
            tooltip: 'Sync jobs',
            onPressed: () => syncService.syncJobInspection(),
            child: const Icon(Icons.sync),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addButton',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobCreateScreen()),
              );
              vm.loadJobs();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: vm.refresh, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(child: Text(vm.error!));
    }

    if (vm.jobs.isEmpty) {
      return Center(child: Text('No jobs found'));
    }

    return ListView.builder(
      itemCount: vm.jobs.length,
      itemBuilder: (_, i) {
        final job = vm.jobs[i];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InspectionItemsListScreen(jobId: job.id),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT SIDE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Created on: ${vm.formatDate(job.createdAt)}",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                // RIGHT SIDE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobEditScreen(jobId: job.id),
                              ),
                            );
                            vm.loadJobs();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async =>
                              await _confirmDelete(context, job.id, job.title),
                        ),
                        
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CreateInspectionItemScreen(jobId: job.id),
                              ),
                            );
                            vm.loadJobs();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
