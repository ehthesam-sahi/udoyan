import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSupportRequestsPage extends StatefulWidget {
  const AdminSupportRequestsPage({super.key});

  @override
  State<AdminSupportRequestsPage> createState() =>
      _AdminSupportRequestsPageState();
}

class _AdminSupportRequestsPageState extends State<AdminSupportRequestsPage> {
  bool _loading = true;
  List<dynamic> _requests = [];

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);

    try {
      final response = await _client
          .from('support_requests')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _requests = response as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _requests = [];
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading support requests: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Support Requests")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text("No support requests yet."))
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final req = _requests[index] as Map<String, dynamic>;
                      final type = req['support_type'] ?? "Unknown";
                      final desc = req['description'] ?? "";
                      final createdAt =
                          req['created_at']?.toString() ?? "";
                      final userId = req['user_id']?.toString() ?? "";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(type),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(desc),
                              if (createdAt.isNotEmpty)
                                Text(
                                  "Created: $createdAt",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (userId.isNotEmpty)
                                Text(
                                  "User: $userId",
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
