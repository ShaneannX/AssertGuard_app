import 'package:flutter/material.dart';
import 'package:assetguard_app/presentation/widgets/online_status_indicator.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/sync_service.dart';
import '../../../data/repositories/inspection_respository.dart';
import '../../viewModals/inspections/inspection_create_view_model.dart';
import '../../../data/local_database/local_database_instance.dart';

final syncService = SyncService(db: db, connectivity: ConnectivityService.instance);
final inspectionRepository = InspectionItemsRespository (db: db, sync: syncService);

class CreateInspectionItemScreen extends StatefulWidget {
  final String jobId;

  const CreateInspectionItemScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<CreateInspectionItemScreen> createState() => _CreateInspectionItemScreenState();
}

class _CreateInspectionItemScreenState extends State<CreateInspectionItemScreen> {
  late CreateInspectionItemViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = CreateInspectionItemViewModel(inspectionRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Inspection Item"),
        actions: const [OnlineStatusIndicator()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Description field
            TextField(
              controller: vm.descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              onChanged: (_) => setState(() {}),
              maxLines: 2,
            ),

            const SizedBox(height: 20),

            // Notes field
            TextField(
              controller: vm.notesController,
              decoration: const InputDecoration(labelText: "Notes (optional)"),
              onChanged: (_) => setState(() {}),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // Error message
            if (vm.errorMessage != null)
              Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const Spacer(),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        await vm.createItem(
                          jobId: widget.jobId,
                        );

                        if (!mounted) return;

                        if (vm.created) {
                          Navigator.pop(context);
                        } else {
                          setState(() {});
                        }
                      },
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Inspection Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
