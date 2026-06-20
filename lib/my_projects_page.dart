import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  bool _loading = true;
  String? _errorMessage;
  List<dynamic> _ideas = [];

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "You must be logged in to view your projects.";
          _loading = false;
        });
        return;
      }

      final response = await _client
          .from('ideas')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _ideas = response as List<dynamic>;
        _loading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Unexpected error: $e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Projects"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadIdeas,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : _ideas.isEmpty
                    ? ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "You have not submitted any ideas yet.",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _ideas.length,
                        itemBuilder: (context, index) {
                          final idea = _ideas[index] as Map<String, dynamic>;
                          final title = idea['title'] ?? 'Untitled';
                          final status = idea['status'] ?? 'pending';
                          final createdAt = idea['created_at'];

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
                                  Text("Status: $status"),
                                  if (createdAt != null)
                                    Text("Created: $createdAt"),
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
