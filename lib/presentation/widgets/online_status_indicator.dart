import 'package:flutter/material.dart';
import '../../data/services/connectivity_service.dart';

const _iconPadding = EdgeInsets.symmetric(horizontal: 12);

class OnlineStatusIndicator extends StatelessWidget {
  const OnlineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.instance.onStatusChange,
      initialData: ConnectivityService.instance.currentStatus,
      builder: (context, snapshot) {
        final online = snapshot.data ?? false;

        return Tooltip(
          message: online ? 'Online' : 'Offline',
          child: Padding(
            padding: _iconPadding,
            child: Icon(
              online ? Icons.wifi : Icons.wifi_off,
              color: online ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        );
      },
    );
  }
}
