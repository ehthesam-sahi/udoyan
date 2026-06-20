import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyFundingPage extends StatefulWidget {
  const MyFundingPage({super.key});

  @override
  State<MyFundingPage> createState() => _MyFundingPageState();
}

class _MyFundingPageState extends State<MyFundingPage> {
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

    final user = _client.auth.currentUser;
    if (user == null) {
      setState(() {
        _funding = [];
        _loading = false;
      });
      return;
    }

    try {
      final response = await _client
          .from('funding')
          .select()
          .eq('user_id', user.id)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Funding")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _funding.isEmpty
              ? const Center(child: Text("No funding records yet."))
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

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            "$type ($status)",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Requested: $amountReq $currency"),
                              Text("Approved: $amountApp $currency"),
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
