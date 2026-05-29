import 'package:flutter/material.dart';

import '../../../services/user_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  static const Color _backgroundColor = Color(0xFFFFFCF2);
  static const Color _cardColor = Color(0xFFFFE4E4);
  static const Color _goldColor = Color(0xFFE6B31E);
  static const Color _textColor = Color(0xFF2D1D15);
  static const Color _inputBorderColor = Color(0xFFC7A17A);

  final UserService _userService = UserService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveCustomer() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showMessage("Please input name");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showMessage("Please input a valid email");
      return;
    }
    if (phone.isEmpty) {
      _showMessage("Please input phone number");
      return;
    }
    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters");
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _userService.createAdminUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (!mounted) return;
      _showMessage("Customer saved successfully");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed to save customer: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textColor,
        title: const Text("Add Customer"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 42, 22, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          decoration: BoxDecoration(
            color: _cardColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Customer",
                style: TextStyle(
                  color: _textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _buildInput(
                label: "Admin Name",
                hint: "Input name",
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              _buildInput(
                label: "Email",
                hint: "Input email",
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildInput(
                label: "Phone",
                hint: "Input phone no.",
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _buildInput(
                label: "Password",
                hint: "Input password",
                controller: _passwordController,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 44),
              GestureDetector(
                onTap: _isSaving ? null : _saveCustomer,
                child: Container(
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: const LinearGradient(
                      colors: [_goldColor, Color(0xFFF7F1E3), _goldColor],
                    ),
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: _textColor,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Save Customer",
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !_isSaving,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: _textColor.withValues(alpha: 0.35),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: _goldColor, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _inputBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: _inputBorderColor,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: _inputBorderColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
