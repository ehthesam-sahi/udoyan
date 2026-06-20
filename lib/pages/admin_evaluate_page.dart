import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminEvaluatePage extends StatefulWidget {
  final Map<String, dynamic> idea;

  const AdminEvaluatePage({super.key, required this.idea});

  @override
  State<AdminEvaluatePage> createState() => _AdminEvaluatePageState();
}

class _AdminEvaluatePageState extends State<AdminEvaluatePage> {
  final _formKey = GlobalKey<FormState>();

  final _innovation = TextEditingController();
  final _feasibility = TextEditingController();
  final _market = TextEditingController();
  final _financial = TextEditingController();
  final _risk = TextEditingController();
  final _impact = TextEditingController();
  final _notes = TextEditingController();

  bool _saving = false;

  SupabaseClient get _client => Supabase.instance.client;

  Widget _scoreField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "Required";
          final n = int.tryParse(v);
          if (n == null || n < 0 || n > 10) return "Enter a value between 0–10";
          return null;
        },
      ),
    );
  }

  Future<void> _saveEvaluation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final user = _client.auth.currentUser;

    final innovation = int.parse(_innovation.text);
    final feasibility = int.parse(_feasibility.text);
    final market = int.parse(_market.text);
    final financial = int.parse(_financial.text);
    final risk = int.parse(_risk.text);
    final impact = int.parse(_impact.text);

    final total =
        innovation + feasibility + market + financial + risk + impact;

    try {
      await _client
          .from('ideas')
          .update({
            'innovation_score': innovation,
            'feasibility_score': feasibility,
            'market_score': market,
            'financial_score': financial,
            'risk_score': risk,
            'impact_score': impact,
            'total_score': total,
            'evaluation_notes': _notes.text.trim(),
            'evaluated_by': user?.id,
            'evaluated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.idea['id']);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving evaluation: $e")),
        );
      }
    }

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final idea = widget.idea;

    return Scaffold(
      appBar: AppBar(title: Text("Evaluate: ${idea['title']}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _scoreField("Innovation", _innovation),
              _scoreField("Feasibility", _feasibility),
              _scoreField("Market Potential", _market),
              _scoreField("Financial Viability", _financial),
              _scoreField("Risk Assessment", _risk),
              _scoreField("Impact", _impact),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Evaluation Notes (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveEvaluation,
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
                      : const Text("Save Evaluation"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
