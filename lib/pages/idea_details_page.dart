import 'package:flutter/material.dart';

import 'request_funding_page.dart';

class IdeaDetailsPage extends StatelessWidget {
  final Map<String, dynamic> idea;

  const IdeaDetailsPage({super.key, required this.idea});

  Widget _section(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = idea['title'] ?? 'Untitled';
    final problem = idea['problem'] ?? 'No problem statement';
    final solution = idea['solution'] ?? 'No solution provided';
    final funding = idea['required_funding']?.toString() ?? 'Not specified';
    final supportType = idea['support_type'] ?? 'Not specified';
    final impact = idea['expected_impact'] ?? 'Not specified';
    final status = idea['status'] ?? 'pending';
    final createdAt = idea['created_at']?.toString() ?? '';

    final innovation = idea['innovation_score'];
    final feasibility = idea['feasibility_score'];
    final market = idea['market_score'];
    final financial = idea['financial_score'];
    final risk = idea['risk_score'];
    final impactScore = idea['impact_score'];
    final total = idea['total_score'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Status", status),
            _section("Created At", createdAt),
            _section("Problem Statement", problem),
            _section("Proposed Solution", solution),
            _section("Required Funding", funding),
            _section("Support Type", supportType),
            _section("Expected Impact", impact),

            const SizedBox(height: 24),
            const Text(
              "Evaluation Scores",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            _section("Innovation", innovation?.toString() ?? "Not evaluated"),
            _section("Feasibility", feasibility?.toString() ?? "Not evaluated"),
            _section("Market Potential", market?.toString() ?? "Not evaluated"),
            _section("Financial Viability",
                financial?.toString() ?? "Not evaluated"),
            _section("Risk Assessment", risk?.toString() ?? "Not evaluated"),
            _section("Impact", impactScore?.toString() ?? "Not evaluated"),
            _section("Total Score", total?.toString() ?? "Not evaluated"),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final ideaId = idea['id']?.toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestFundingPage(
                        ideaId: ideaId,
                        ideaTitle: title,
                      ),
                    ),
                  );
                },
                child: const Text("Request Funding for this Idea"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
