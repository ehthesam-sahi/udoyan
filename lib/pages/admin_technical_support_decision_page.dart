import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminTechnicalSupportDecisionPage extends StatefulWidget {
  final Map<String, dynamic> request;

  const AdminTechnicalSupportDecisionPage({super.key, required this.request});

  @override
  State<AdminTechnicalSupportDecisionPage> createState() =>
      _AdminTechnicalSupportDecisionPageState();
}

class _AdminTechnicalSupportDecisionPageState
    extends State<AdminTechnicalSupportDecisionPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedStatus;
  bool _saving = false;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final r = widget.request;
    _selectedStatus = r['status'] ?? 'pending';
    _notesController.text = r['admin_notes'] ?? '';
  }

  Future<void> _saveDecision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await _client
          .from('technical_support_requests')
          .update({
            'status': _selectedStatus,
            'admin_notes': _notesController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.request['id']);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving decision: $e")),
        );
      }
    }

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  Widget _section(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Technical Support Decision"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Title", r['title'] ?? "Untitled"),
            _section("Support Type", r['support_type'] ?? "Unknown"),
            _section("Urgency", r['urgency'] ?? "N/A"),
            _section("Preferred Timeline",
                r['preferred_timeline'] ?? "Not specified"),
            _section("Industry", r['industry'] ?? "Not specified"),
            _section("User ID", r['user_id']?.toString() ?? ""),
            _section("Created At", r['created_at']?.toString() ?? ""),
            _section("Description", r['description'] ?? "No description"),

            const SizedBox(height: 24),
            const Text(
              "Admin Decision",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "pending", child: Text("Pending")),
                      DropdownMenuItem(
                          value: "in_review", child: Text("In Review")),
                      DropdownMenuItem(
                          value: "in_progress", child: Text("In Progress")),
                      DropdownMenuItem(
                          value: "completed", child: Text("Completed")),
                      DropdownMenuItem(
                          value: "rejected", child: Text("Rejected")),
                    ],
                    onChanged: (v) => _selectedStatus = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Admin Notes (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveDecision,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Save Decision"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
