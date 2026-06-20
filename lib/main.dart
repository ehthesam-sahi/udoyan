import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pages
import 'pages/dashboard_page.dart';
import 'welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DIRECT Supabase initialization (recommended for production)
  await Supabase.initialize(
    url: 'https://ktkpebqzvpnegsnuuqdd.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_qX77H3qWpHrzXtoyKzsddA_vzd05U7H',
  );

  runApp(const UdoyanApp());
}

class UdoyanApp extends StatelessWidget {
  const UdoyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Udoyan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  Session? _session;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _session = client.auth.currentSession;

    client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
        _loading = false;
      });
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session != null) {
      return const DashboardPage();
    }
    return const WelcomePage();
  }
}
