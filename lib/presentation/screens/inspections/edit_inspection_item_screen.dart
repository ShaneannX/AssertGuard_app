import 'package:flutter/material.dart';
import '../../../data/local_database/local_database_instance.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/sync_service.dart';
import '../../../data/repositories/inspection_respository.dart';
import '../../viewModals/inspections/inspection_edit_view_model.dart';

final connectivity = ConnectivityService();
final syncService = SyncService(db: db, connectivity: connectivity);
final inspectionRepository = InspectionItemsRespository(
  db: db,
  sync: syncService,
);

class EditInspectionItemScreen extends StatefulWidget {
  final String inspectionItemId;

  const EditInspectionItemScreen({super.key, required this.inspectionItemId});

  @override
  State<EditInspectionItemScreen> createState() =>
      _EditInspectionItemScreenState();
}

class _EditInspectionItemScreenState extends State<EditInspectionItemScreen> {
  late EditInspectionItemViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = EditInspectionItemViewModel(inspectionRepository);
    vm.loadItem(widget.inspectionItemId).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Inspection Item")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // DESCRIPTION INPUT
                  TextField(
                    controller: vm.descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 20),

                  // NOTES INPUT
                  TextField(
                    controller: vm.notesController,
                    decoration: const InputDecoration(
                      labelText: "Notes (optional)",
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 20),

                  if (vm.errorMessage != null)
                    Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),

                  const Spacer(),

                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vm.isSaving
                          ? null
                          : () async {
                              await vm.saveChanges();
                              if (!mounted) return;

                              if (vm.updated) {
                                Navigator.pop(context, true);
                              } else {
                                setState(() {});
                              }
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
