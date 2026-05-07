import 'package:flutter/material.dart';
import 'package:assetguard_app/presentation/widgets/online_status_indicator.dart';
import '../screens/jobs/job_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local_database/local_database_instance.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/sync_service.dart';

final syncService = SyncService(db: db, connectivity: ConnectivityService.instance);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: const [OnlineStatusIndicator()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Spacer(),

            // JOBS BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JobsListScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("Jobs", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!mounted) return;

                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("Logout", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
