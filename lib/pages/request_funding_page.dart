import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestFundingPage extends StatefulWidget {
  final String? ideaId;
  final String? ideaTitle;

  const RequestFundingPage({
    super.key,
    this.ideaId,
    this.ideaTitle,
  });

  @override
  State<RequestFundingPage> createState() => _RequestFundingPageState();
}

class _RequestFundingPageState extends State<RequestFundingPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedType;

  final List<String> _fundingTypes = [
    "Private Investment",
    "Angel Funding",
    "Equity Partnership",
    "Loan Support",
  ];

  bool _saving = false;

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
      await _client.from('funding').insert({
        'user_id': user.id,
        'idea_id': widget.ideaId,          // may be null (independent request)
        'support_request_id': null,       // reserved for future use
        'funding_type': _selectedType,
        'amount_requested':
            double.tryParse(_amountController.text.trim()) ?? 0,
        'currency': 'BDT',
        'status': 'pending',
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting funding request: $e")),
        );
      }
    }

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.ideaTitle != null
        ? "Request Funding: ${widget.ideaTitle}"
        : "Request Funding";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.ideaTitle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Linked Idea: ${widget.ideaTitle}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Funding Type",
                  border: OutlineInputBorder(),
                ),
                items: _fundingTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => _selectedType = v,
                validator: (v) =>
                    v == null ? "Please select a funding type" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Amount Requested (BDT)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Amount is required";
                  }
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) {
                    return "Enter a valid positive amount";
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
                      : const Text("Submit Funding Request"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
