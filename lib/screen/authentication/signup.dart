import 'package:flutter/material.dart';
import 'package:project/screen/authentication/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  static const Color goldColor = Color(0xFFD4AF37);
  static const Color inputBorderColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF554518),
              Color(0xFF262116),
              Color(0xFF262116),
              Color(0xFF262116),
              Color(0xFF554518),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Image.asset(
                  'assets/images/cosmetic_logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 15),

                const Text(
                  "Beauty with me.",
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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
                        indent: 10,
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
                        endIndent: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                _buildUnderlineTextField(
                  controller: _nameController,
                  hintText: "User Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),

                _buildUnderlineTextField(
                  controller: _emailController,
                  hintText: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                _buildUnderlineTextField(
                  controller: _phoneController,
                  hintText: "Phone",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),

                _buildUnderlineTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 45),
                GestureDetector(
                  onTap: () async {
                    if (_passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Password သည် အနည်းဆုံး ၆ လုံး ဖြစ်ရမည်။",
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      print("စတင် Sign up လုပ်နေပါပြီ...");
                      final AuthResponse res = await supabase.auth.signUp(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      if (res.user != null) {
                        print("Auth အောင်မြင်သွားပြီ၊ Data ထည့်နေပါတယ်...");
                        await supabase.from('users').insert({
                          'user_id': res.user!.id,
                          'user_name': _nameController.text,
                          'user_email': _emailController.text,
                          'user_phone': _phoneController.text,
                          'user_role': 'user',
                        });
                        print("Database ထဲ Data ရောက်သွားပါပြီ!");

                        // အောင်မြင်ရင် Login စာမျက်နှာကို သွားမယ်
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    } catch (e) {
                      print("$e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
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
                          Color(0xFFE6B31E),
                          Color(0xFFF7F1E3),
                          Color(0xFFE6B31E),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: Color(0xFF2D1D15),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?  ",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Login..",
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

  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: goldColor, size: 22),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor, width: 1.8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
