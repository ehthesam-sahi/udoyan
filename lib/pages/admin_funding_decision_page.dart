import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminFundingDecisionPage extends StatefulWidget {
  final Map<String, dynamic> funding;

  const AdminFundingDecisionPage({super.key, required this.funding});

  @override
  State<AdminFundingDecisionPage> createState() =>
      _AdminFundingDecisionPageState();
}

class _AdminFundingDecisionPageState extends State<AdminFundingDecisionPage> {
  final _formKey = GlobalKey<FormState>();
  final _approvedAmountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedStatus;

  bool _saving = false;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    final f = widget.funding;

    _approvedAmountController.text =
        f['amount_approved']?.toString() ?? '';

    _notesController.text = f['notes'] ?? '';

    _selectedStatus = f['status'] ?? 'pending';
  }

  Future<void> _saveDecision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await _client
          .from('funding')
          .update({
            'amount_approved': double.tryParse(
                    _approvedAmountController.text.trim()),
            'status': _selectedStatus,
            'notes': _notesController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.funding['id']);

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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.funding;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Funding Decision"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Funding Type", f['funding_type'] ?? "Unknown"),
            _section("Requested Amount",
                "${f['amount_requested'] ?? 0} ${f['currency'] ?? 'BDT'}"),
            _section("User ID", f['user_id'] ?? ""),
            _section("Idea ID", f['idea_id']?.toString() ?? "Independent"),
            _section("Created At", f['created_at']?.toString() ?? ""),

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
                          value: "approved", child: Text("Approved")),
                      DropdownMenuItem(
                          value: "rejected", child: Text("Rejected")),
                      DropdownMenuItem(
                          value: "in_progress",
                          child: Text("In Progress")),
                      DropdownMenuItem(
                          value: "completed", child: Text("Completed")),
                    ],
                    onChanged: (v) => _selectedStatus = v,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _approvedAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Approved Amount (BDT)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (_selectedStatus == "approved" ||
                          _selectedStatus == "in_progress" ||
                          _selectedStatus == "completed") {
                        if (v == null || v.isEmpty) {
                          return "Approved amount required";
                        }
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) {
                          return "Enter a valid amount";
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Notes (optional)",
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
