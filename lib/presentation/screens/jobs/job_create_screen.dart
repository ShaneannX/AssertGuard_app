import 'package:flutter/material.dart';
import 'package:assetguard_app/presentation/widgets/online_status_indicator.dart';
import 'package:assetguard_app/presentation/widgets/sync_status_banner.dart';
import '../../viewModals/jobs/job_create_view_model.dart';
import '../../../data/repositories/jobs_repository.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/sync_service.dart';
import '../../../data/local_database/local_database_instance.dart';

final syncService = SyncService(db: db, connectivity: ConnectivityService.instance);
final jobsRepository = JobsRepository(db: db, syncService: syncService);

class JobCreateScreen extends StatefulWidget {
  const JobCreateScreen({super.key});

  @override
  State<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends State<JobCreateScreen> {
  late CreateJobViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = CreateJobViewModel(jobsRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Job"),
        actions: const [OnlineStatusIndicator()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SyncStatusBanner(sync: syncService),
            const SizedBox(height: 16),
            // Title field
            TextField(
              decoration: const InputDecoration(labelText: "Job Title"),
              onChanged: (value) {
                vm.setTitle(value);
                setState(() {});
              },
            ),

            const SizedBox(height: 20),

            // Error message
            if (vm.error != null)
              Text(
                vm.error!,
                style: const TextStyle(color: Colors.red),
              ),

            const Spacer(),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isSaving
                    ? null
                    : () async {
                        await vm.createJob();

                        if (!mounted) return;

                        // If creation succeeded, pop back
                        if (vm.error == null) {
                          Navigator.pop(context);
                        } else {
                          setState(() {});
                        }
                      },
                child: vm.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Job"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
