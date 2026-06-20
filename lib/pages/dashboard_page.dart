import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pages
import 'profile_edit_page.dart';
import 'my_projects_page.dart';
import 'support_request_page.dart';
import 'my_support_requests_page.dart';
import 'admin_idea_list_page.dart';
import 'admin_support_requests_page.dart';
import 'admin_funding_list_page.dart';
import 'my_funding_page.dart';
import 'request_funding_page.dart';
import '../submit_idea_page.dart';

// Module 5: Technical Support
import 'technical_support_request_page.dart';
import 'my_technical_support_requests_page.dart';
import 'admin_technical_support_requests_page.dart';

// Widgets
import '../widgets/quick_action.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        await client.from('profiles').insert({
          'id': user.id,
          'name': null,
          'role': null,
          'phone': null,
          'avatar_url': null,
        });

        profile = {
          'name': null,
          'role': null,
          'phone': null,
          'avatar_url': null,
        };
      } else {
        profile = response;
      }
    } catch (e) {
      print("PROFILE LOAD ERROR: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = profile?['name'] ?? "Add your name";
    final role = profile?['role'] ?? "Add your role";
    final phone = profile?['phone'] ?? "Add phone";
    final avatarUrl = profile?['avatar_url'];
    final isAdmin = role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Udoyan", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditPage()),
              );
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminIdeaListPage(),
                  ),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.support_agent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminSupportRequestsPage(),
                  ),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.account_balance),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminFundingListPage(),
                  ),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.build_circle_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminTechnicalSupportRequestsPage(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await client.auth.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search ideas, support, mentors...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person,
                            size: 32, color: Colors.green)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(role,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                        Text(user?.email ?? "",
                            style: const TextStyle(fontSize: 14)),
                        Text(phone, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Quick Actions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                QuickAction(
                  icon: Icons.lightbulb_outline,
                  label: "Submit Idea",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubmitIdeaPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                QuickAction(
                  icon: Icons.support_agent_outlined,
                  label: "Request Support",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupportRequestPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                QuickAction(
                  icon: Icons.analytics_outlined,
                  label: "My Projects",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyProjectsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                QuickAction(
                  icon: Icons.list_alt_outlined,
                  label: "My Support Requests",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MySupportRequestsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                QuickAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "My Funding",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyFundingPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                QuickAction(
                  icon: Icons.request_page_outlined,
                  label: "Request Funding",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestFundingPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                QuickAction(
                  icon: Icons.build_outlined,
                  label: "Technical Support",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const TechnicalSupportRequestPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                QuickAction(
                  icon: Icons.engineering_outlined,
                  label: "My Technical Requests",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MyTechnicalSupportRequestsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
