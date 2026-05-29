import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './screen/admin/admin_dashboard.dart';
import './screen/admin/category.dart';
import './screen/admin/offer_list.dart';
import './screen/admin/order_list.dart';
import './screen/admin/product_list.dart';
import './screen/admin/user_list.dart';
import './screen/authentication/login.dart';
import './screen/authentication/splash.dart';
import './screen/user/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://miemtrpxitefxjtrwnvc.supabase.co',
    anonKey: 'sb_publishable_EOziOLsCOENo-QFJQfNykw_LFohPQt1',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/user': (context) => const MainLayout(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/category': (context) => const CategoryScreen(),
        '/admin/products': (context) => const ProductListScreen(),
        '/admin/offers': (context) => const OfferListScreen(),
        '/admin/orders': (context) => const OrderListScreen(),
        '/admin/users': (context) => const UserListScreen(),
      },
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return const AuthGate();
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String> _getUserRole(String userId) async {
    final data = await Supabase.instance.client
        .from('users')
        .select('user_role')
        .eq('user_id', userId)
        .maybeSingle();

    return data?['user_role']?.toString() ?? 'user';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String>(
          future: _getUserRole(session.user.id),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError) {
              return const LoginScreen();
            }

            if (roleSnapshot.data == 'admin') {
              return const AdminDashboardScreen();
            }

            return const MainLayout();
          },
        );
      },
    );
  }
}
