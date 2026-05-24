// import 'package:flutter/material.dart';
// import './screen/authentication/login.dart';
// import './screen/user/main_layout.dart';
// import './screen/authentication/splash.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import './screen/admin/widgets/dashboard_card.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://miemtrpxitefxjtrwnvc.supabase.co',
//     anonKey: 'sb_publishable_EOziOLsCOENo-QFJQfNykw_LFohPQt1',
//   );
//   runApp(const MyApp());
// }

// final supabase = Supabase.instance.client;

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // main.dart ထဲမှာ MaterialApp ရဲ့ home နေရာမှာ ဒီလိုလေး ထည့်ပါ
//       home: StreamBuilder<AuthState>(
//         stream: Supabase.instance.client.auth.onAuthStateChange,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data?.session != null) {
//             // HomeScreen ကို တိုက်ရိုက်မခေါ်ဘဲ Navigation ပါတဲ့ Layout ကို ခေါ်ပါ
//             return const MainLayout(); 
//           } else {
//             return const AdminDashboard();
//           }
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import './screen/admin/admin_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: const AdminDashboardScreen(),
    );
  }
}