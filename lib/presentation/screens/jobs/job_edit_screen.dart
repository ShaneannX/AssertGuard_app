import 'package:flutter/material.dart';
import 'package:assetguard_app/presentation/widgets/online_status_indicator.dart';
import '../../viewModals/jobs/job_edit_view_model.dart';
import '../../../data/repositories/jobs_repository.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/sync_service.dart';
import '../../../data/local_database/local_database_instance.dart';

final syncService = SyncService(db: db, connectivity: ConnectivityService.instance);
final jobsRepository = JobsRepository(db: db, syncService: syncService);

class JobEditScreen extends StatefulWidget {
  final String jobId;

  const JobEditScreen({super.key, required this.jobId});

  @override
  State<JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends State<JobEditScreen> {
  late JobEditViewModel vm;

  @override
  void initState() {
    super.initState();

    vm = JobEditViewModel(jobsRepository);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await vm.loadJob(widget.jobId);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Job"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, vm.jobId, vm.jobTitle),
          ),
          const OnlineStatusIndicator(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title Field
            TextField(
              controller: TextEditingController(text: vm.jobTitle)
                ..selection = TextSelection.collapsed(offset: vm.jobTitle.length),
              decoration: const InputDecoration(labelText: "Job Title"),
              onChanged: (value) {
                vm.jobTitle = value;
                setState(() {});
              },
            ),

            const SizedBox(height: 20),

            // Updated At
            Text(
              "Last Updated: ${vm.formatDate(vm.updatedAt)}",
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isSaving
                    ? null
                    : () async {
                        await vm.updateJob();
                        if (mounted) Navigator.pop(context);
                      },
                child: vm.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    // Delete is handled in JobsListScreen via vm.deleteJob(jobId)
    Navigator.pop(context);
  }
}
