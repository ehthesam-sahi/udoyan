import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmitIdeaPage extends StatefulWidget {
  const SubmitIdeaPage({super.key});

  @override
  State<SubmitIdeaPage> createState() => _SubmitIdeaPageState();
}

class _SubmitIdeaPageState extends State<SubmitIdeaPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();
  final _fundingController = TextEditingController();
  final _supportTypeController = TextEditingController();
  final _impactController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> _submitIdea() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        setState(() => _errorMessage = "You must be logged in to submit an idea.");
        return;
      }

      final title = _titleController.text.trim();
      final problem = _problemController.text.trim();
      final solution = _solutionController.text.trim();
      final fundingText = _fundingController.text.trim();
      final supportType = _supportTypeController.text.trim();
      final impact = _impactController.text.trim();

      await _client.from('ideas').insert({
        'user_id': user.id,
        'title': title,
        'problem': problem,
        'solution': solution,
        'required_funding':
            fundingText.isEmpty ? null : double.tryParse(fundingText),
        'support_type': supportType.isEmpty ? null : supportType,
        'expected_impact': impact.isEmpty ? null : impact,
        'status': 'pending',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Idea submitted successfully!")),
      );

      Navigator.pop(context);
    } on PostgrestException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Unexpected error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _fundingController.dispose();
    _supportTypeController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Idea")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Idea Title",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _problemController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Problem Statement",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Problem statement is required"
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _solutionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Proposed Solution",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Proposed solution is required"
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fundingController,
                decoration: const InputDecoration(
                  labelText: "Required Funding (optional)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _supportTypeController,
                decoration: const InputDecoration(
                  labelText: "Support Type (optional, e.g. finance, technical)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _impactController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Expected Impact (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitIdea,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Submit Idea"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
fbasfbailfnvafawiccaw;ofvikvnain