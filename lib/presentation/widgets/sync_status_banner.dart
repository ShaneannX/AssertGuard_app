import 'package:flutter/material.dart';
import '../../data/services/sync_service.dart';

class SyncStatusBanner extends StatelessWidget {
  final SyncService sync;

  const SyncStatusBanner({super.key, required this.sync});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: sync.syncing,
      initialData: false,
      builder: (context, syncSnapshot) {
        final isSyncing = syncSnapshot.data ?? false;

        return StreamBuilder<bool>(
          stream: sync.failed,
          initialData: false,
          builder: (context, failedSnapshot) {
            final isFailed = failedSnapshot.data ?? false;
            return StreamBuilder<bool>(
              stream: sync.synced,
              initialData: false,
              builder: (context, syncedSnapshot) {
                final isSynced = syncedSnapshot.data ?? false;

                return StreamBuilder<bool>(
                  stream: sync.connectivity.onStatusChange,
                  initialData: sync.connectivity.currentStatus,
                  builder: (context, onlineSnapshot) {
                    final isOnline = onlineSnapshot.data ?? false;

                    if (isSyncing) {
                      return _banner(
                        "Syncing…",
                        Colors.blue.shade100,
                        Icons.sync,
                      );
                    }

                    if (isFailed) {
                      return _banner(
                        "Sync failed",
                        Colors.red.shade100,
                        Icons.error,
                      );
                    }

                    if (isSynced) {
                      return _banner(
                        "Synced!",
                        Colors.green.shade100,
                        Icons.check_circle,
                      );
                    }

                    if (!isOnline) {
                      return _banner(
                        "Offline Mode - Sync available when back online",
                        Colors.grey.shade100,
                        Icons.wifi_off,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _banner(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: color,
      child: Row(
        children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(text)],
      ),
    );
  }
}
