import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_evaluate_page.dart';

class AdminIdeaListPage extends StatefulWidget {
  const AdminIdeaListPage({super.key});

  @override
  State<AdminIdeaListPage> createState() => _AdminIdeaListPageState();
}

class _AdminIdeaListPageState extends State<AdminIdeaListPage> {
  bool _loading = true;
  List<dynamic> _ideas = [];

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    setState(() => _loading = true);

    try {
      final response = await _client
          .from('ideas')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _ideas = response as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _ideas = [];
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading ideas: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: All Ideas")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ideas.isEmpty
              ? const Center(child: Text("No ideas submitted yet."))
              : RefreshIndicator(
                  onRefresh: _loadIdeas,
                  child: ListView.builder(
                    itemCount: _ideas.length,
                    itemBuilder: (context, index) {
                      final idea = _ideas[index] as Map<String, dynamic>;
                      final title = idea['title'] ?? 'Untitled';
                      final createdAt =
                          idea['created_at']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            createdAt.isNotEmpty
                                ? "Created: $createdAt"
                                : "No date",
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminEvaluatePage(idea: idea),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
