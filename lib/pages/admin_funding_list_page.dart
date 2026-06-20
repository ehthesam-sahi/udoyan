import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_funding_decision_page.dart';

class AdminFundingListPage extends StatefulWidget {
  const AdminFundingListPage({super.key});

  @override
  State<AdminFundingListPage> createState() => _AdminFundingListPageState();
}

class _AdminFundingListPageState extends State<AdminFundingListPage> {
  bool _loading = true;
  List<dynamic> _funding = [];

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadFunding();
  }

  Future<void> _loadFunding() async {
    setState(() => _loading = true);

    try {
      final response = await _client
          .from('funding')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _funding = response as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _funding = [];
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading funding: $e")),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Funding Requests")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _funding.isEmpty
              ? const Center(child: Text("No funding requests yet."))
              : RefreshIndicator(
                  onRefresh: _loadFunding,
                  child: ListView.builder(
                    itemCount: _funding.length,
                    itemBuilder: (context, index) {
                      final f = _funding[index] as Map<String, dynamic>;
                      final type = f['funding_type'] ?? "Unknown";
                      final status = f['status'] ?? "pending";
                      final amountReq =
                          f['amount_requested']?.toString() ?? "0";
                      final amountApp =
                          f['amount_approved']?.toString() ?? "—";
                      final currency = f['currency'] ?? "BDT";
                      final createdAt =
                          f['created_at']?.toString() ?? "";
                      final userId = f['user_id']?.toString() ?? "";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            type,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("Req: $amountReq $currency"),
                                ],
                              ),
                              Text("Approved: $amountApp $currency"),
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
                                    AdminFundingDecisionPage(funding: f),
                              ),
                            ).then((_) => _loadFunding());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
