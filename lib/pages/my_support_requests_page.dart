import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MySupportRequestsPage extends StatefulWidget {
  const MySupportRequestsPage({super.key});

  @override
  State<MySupportRequestsPage> createState() => _MySupportRequestsPageState();
}

class _MySupportRequestsPageState extends State<MySupportRequestsPage> {
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

    final user = _client.auth.currentUser;
    if (user == null) {
      setState(() {
        _requests = [];
        _loading = false;
      });
      return;
    }

    try {
      final response = await _client
          .from('support_requests')
          .select()
          .eq('user_id', user.id)
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
      appBar: AppBar(title: const Text("My Support Requests")),
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
