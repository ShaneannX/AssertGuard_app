import 'package:flutter/material.dart';
import 'package:assetguard_app/presentation/widgets/online_status_indicator.dart';
import 'package:assetguard_app/presentation/widgets/sync_status_banner.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/sync_service.dart';
import '../../../data/repositories/inspection_respository.dart';
import '../../viewModals/job_and_inspection_items_view_model.dart';
import 'edit_inspection_item_screen.dart';
import 'create_inspection_item_screen.dart';
import '../../../data/local_database/local_database_instance.dart';

final syncService = SyncService(db: db, connectivity: ConnectivityService.instance);
final inspectionRepository = InspectionItemsRespository(
  db: db,
  sync: syncService,
);

class InspectionItemsListScreen extends StatefulWidget {
  final String jobId;

  const InspectionItemsListScreen({super.key, required this.jobId});

  @override
  State<InspectionItemsListScreen> createState() =>
      _InspectionItemsListScreenState();
}

class _InspectionItemsListScreenState extends State<InspectionItemsListScreen> {
  late JobInspectionListViewModel vm;
Future<void> _confirmDelete(
    BuildContext context,
    String inspectionId,
    String description,
    String jobId
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Job: $description'),
          content: const Text('Are you sure you want to delete this Inspection Item?'),
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
       vm.deleteItem(inspectionId, jobId);
    }
  }
  @override
  void initState() {
    super.initState();
    vm = JobInspectionListViewModel(inspectionRepository);
    vm.addListener(() {
      if (mounted) setState(() {});
    });
    vm.load(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspection Items"),
        actions: const [OnlineStatusIndicator()],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "addItemFab",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateInspectionItemScreen(jobId: widget.jobId),
                ),
              );
              vm.load(widget.jobId);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "secondFab",
            onPressed: () {
              syncService.syncJobInspection();
            },
            child: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Column(
        children: [
          SyncStatusBanner(sync: syncService),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? Center(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        itemCount: vm.items.length,
                        itemBuilder: (_, i) {
                          final item = vm.items[i];
                          return ListTile(
                            title: Text('Description: ${item.description}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notes: ${item.notes ?? "No notes"}'),
                                const SizedBox(height: 4),
                                Text('Created: ${item.createdAt.toLocal()}'),
                                Text(
                                  'Updated: ${item.updatedAt?.toLocal() ?? "Never updated"}',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async => await _confirmDelete(
                                    context,
                                    item.id,
                                    item.description,
                                    item.jobId,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditInspectionItemScreen(
                                    inspectionItemId: item.id,
                                  ),
                                ),
                              ).then((_) => vm.load(widget.jobId));
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
    );
  }
}
