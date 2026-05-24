import 'package:flutter/material.dart';
import 'package:project/screen/authentication/signup.dart';
import 'package:project/screen/user/main_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/widgets/dashboard_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final supabase = Supabase.instance.client;
  // Controller များကို UI အဆင်သင့်ဖြစ်စေရန် ကြိုတင်ကြေညာထားခြင်း
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // သတ်မှတ်ထားသော အရောင်များ
  static const Color goldColor = Color(0xFFE6B31E);
  static const Color inputBorderColor = Color(0xFFC7A17A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // (၁) နောက်ခံ Gradient သတ်မှတ်ခြင်း
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF554518),
              Color(0xFF262116),
              Color(0xFF262116),
              Color(0xFF262116),
              Color(0xFF554518), // အောက်ဘက် အမည်းရောင်သန်းသောအရောင်
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                Image.asset(
                "assets/images/cosmetic_logo.png",
                width: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                "Beauty with me.",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC7A17A),
                ),
              ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Expanded(
                      child: Divider(
                        color: goldColor,
                        thickness: 0.8,
                        indent: 120,
                        endIndent: 10,
                      ),
                    ),
                    Text(
                      "Your Journey to Elegant",
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: goldColor,
                        thickness: 0.8,
                        indent: 10,
                        endIndent: 120,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    prefixIcon: const Icon(Icons.email_outlined, color: goldColor, size: 22),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: inputBorderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: inputBorderColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // (၆) Password Input Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // စာလုံးများ ဖျောက်ထားရန်
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline, color: goldColor, size: 22),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: inputBorderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: inputBorderColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // (၇) Forgot Password? စာသား
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Forgot password နှိပ်ရင် လုပ်မယ့်အလုပ်
                    },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // (၈) LOG IN Button (ရွှေရောင် Gradient ဖြင့်)
                GestureDetector(
                  onTap: () async {
                    try {
                      final AuthResponse res = await supabase.auth.signInWithPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      if (res.user != null) {
                        // Role ကို စစ်မယ်
                        final data = await supabase.from('users').select('user_role').eq('user_id', res.user!.id).single();
                        String role = data['user_role'];

                        if (role == 'admin') {
                          // Admin Dashboard သို့ ပို့မယ် (AdminDashboard() screen ကို အစ်မဆောက်ထားရမယ်)
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
                        } else {
                          // User ဆို MainLayout သို့ ပို့မယ်
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainLayout()));
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE6B31E), // ရွှေဝါရောင် ဖျော့
                          Color(0xFFF7F1E3),
                          Color(0xFFE6B31E), // ရွှေအိုရောင် ရင့်
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "LOG IN",
                        style: TextStyle(
                          color: Color(0xFF2D1D15), // စာသားကို နောက်ခံနှင့်လိုက်ဖက်အောင် ညိုမှောင်ရောင် သုံးထားပါတယ်
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // (၉) Don't have an account? SignUp.. စာသား
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context ,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );// SignUp Page သို့ သွားရန် ရေးရမည့်နေရာ
                      },
                      child: const Text(
                        "SignUp..",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}