import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicalSupportRequestPage extends StatefulWidget {
  const TechnicalSupportRequestPage({super.key});

  @override
  State<TechnicalSupportRequestPage> createState() =>
      _TechnicalSupportRequestPageState();
}

class _TechnicalSupportRequestPageState
    extends State<TechnicalSupportRequestPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timelineController = TextEditingController();
  final _industryController = TextEditingController();

  String? _selectedType;
  String? _selectedUrgency;

  bool _saving = false;

  final List<String> _supportTypes = [
    "Software Development",
    "Engineering Consultation",
    "Production Planning",
    "Automation Guidance",
    "Machinery Supplier Connection",
    "Leasing & Installation Support",
  ];

  final List<String> _urgencyLevels = [
    "Low",
    "Medium",
    "High",
  ];

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final user = _client.auth.currentUser;
    if (user == null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in.")),
      );
      return;
    }

    try {
      await _client.from('technical_support_requests').insert({
        'user_id': user.id,
        'support_type': _selectedType,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'urgency': _selectedUrgency,
        'preferred_timeline': _timelineController.text.trim(),
        'industry': _industryController.text.trim(),
        'status': 'pending',
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting request: $e")),
        );
      }
    }

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Technical & Machinery Support")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Support Type",
                  border: OutlineInputBorder(),
                ),
                items: _supportTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => _selectedType = v,
                validator: (v) =>
                    v == null ? "Please select a support type" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Request Title",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Urgency",
                  border: OutlineInputBorder(),
                ),
                items: _urgencyLevels
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => _selectedUrgency = v,
                validator: (v) =>
                    v == null ? "Please select urgency level" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _timelineController,
                decoration: const InputDecoration(
                  labelText: "Preferred Timeline (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _industryController,
                decoration: const InputDecoration(
                  labelText: "Industry / Sector (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
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
                      : const Text("Submit Request"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
