import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_technical_support_decision_page.dart';

class AdminTechnicalSupportRequestsPage extends StatefulWidget {
  const AdminTechnicalSupportRequestsPage({super.key});

  @override
  State<AdminTechnicalSupportRequestsPage> createState() =>
      _AdminTechnicalSupportRequestsPageState();
}

class _AdminTechnicalSupportRequestsPageState
    extends State<AdminTechnicalSupportRequestsPage> {
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
          .from('technical_support_requests')
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
          SnackBar(content: Text("Error loading technical requests: $e")),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'in_review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Admin: Technical & Machinery Support")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text("No technical support requests yet."))
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final r = _requests[index] as Map<String, dynamic>;

                      final type = r['support_type'] ?? "Unknown";
                      final title = r['title'] ?? "Untitled";
                      final urgency = r['urgency'] ?? "N/A";
                      final status = r['status'] ?? "pending";
                      final timeline =
                          r['preferred_timeline'] ?? "Not specified";
                      final createdAt =
                          r['created_at']?.toString() ?? "";
                      final userId = r['user_id']?.toString() ?? "";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Type: $type"),
                              Text("Urgency: $urgency"),
                              Text("Timeline: $timeline"),
                              Text(
                                "Status: $status",
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminTechnicalSupportDecisionPage(
                                  request: r,
                                ),
                              ),
                            ).then((_) => _loadRequests());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
