import 'package:flutter/material.dart';
import 'package:assetguard_app/data/local/sqlite_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text('AssetGuard Debug Tests')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                // Insert into SQLite
                // await db.into(db.jobs).insert(
                //   JobsCompanion.insert(
                //     id: 'job_test',
                //     userId: 'user_1',
                //     title: 'SQLite Test Job',
                //     createdBy: 'system',
                //     updatedBy: 'system',
                //     createdAt: DateTime.now(),
                //     updatedAt: DateTime.now(),
                //     syncStatus: 'pending',
                //   ),
                // );

                final result = await db.select(db.jobs).get();
                print('SQLite OK — rows: ${result.length}');
                print(result);
              } catch (e) {
                print('SQLite ERROR: $e');
              }
            },
            child: const Text('Test SQLite'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await supabase
                    .from('users')
                    .select()
                    .limit(1);

                print('Supabase OK — $response');
              } catch (e) {
                print('Supabase ERROR: $e');
              }
            },
            child: const Text('Test Supabase'),
          ),
        ],
      ),
    );
  }
}
