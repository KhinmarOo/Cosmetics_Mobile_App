import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final UserService _userService = UserService();
  late Future<UserModel> _userFuture;
  bool _isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserProfile();
  }

  void _refreshUserProfile() {
    setState(() {
      _userFuture = _userService.getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text("No data"));
          }

          return _buildProfileUI(user);
        },
      ),
    );
  }

  Widget _buildProfileUI(UserModel user) {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF2D1D15);
    const bgColor = Color(0xFFFFFCF2);
    const cardBgColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Account",
                style: TextStyle(
                  color: goldColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: _isUpdatingProfile ? null : () => _showEditProfile(user),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: goldColor.withValues(alpha: 0.16),
                        child: Text(
                          _initialsFor(user.name),
                          style: const TextStyle(
                            color: goldColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkBrown,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: darkBrown.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isUpdatingProfile)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: goldColor,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const Icon(
                          Icons.edit_outlined,
                          color: goldColor,
                          size: 19,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildAccountOption(
                      icon: Icons.badge_outlined,
                      title: "My Details",
                      onTap: () => _showMyDetails(user),
                    ),
                    _buildDivider(),
                    _buildAccountOption(
                      icon: Icons.notifications_none_rounded,
                      title: "Notifications",
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildAccountOption(
                      icon: Icons.help_outline_rounded,
                      title: "Help center & support",
                      onTap: _showHelpCenter,
                    ),
                    _buildDivider(),
                    _buildAccountOption(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await _userService.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _showEditProfile(UserModel user) async {
    final result = await showDialog<_ProfileEditResult>(
      context: context,
      builder: (context) => _ProfileEditDialog(user: user),
    );

    if (result == null) return;

    if (result.name.isEmpty) {
      _showMessage("Please enter your name");
      return;
    }

    if (result.email.isEmpty || !result.email.contains('@')) {
      _showMessage("Please enter a valid email");
      return;
    }

    setState(() => _isUpdatingProfile = true);

    try {
      await _userService.updateCurrentUserProfile(
        name: result.name,
        email: result.email,
        phone: result.phone,
      );

      if (!mounted) return;
      _showMessage(
        result.email.toLowerCase() == user.email.toLowerCase()
            ? "Profile updated successfully"
            : "Profile updated. Please check your email if confirmation is required.",
      );
      _refreshUserProfile();
    } catch (e) {
      if (!mounted) return;
      _showMessage("Profile update failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isUpdatingProfile = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showMyDetails(UserModel user) async {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF2D1D15);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/cosmetic_logo.png',
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.spa_outlined,
                                color: goldColor,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Beauty with me",
                              style: TextStyle(
                                color: darkBrown,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Cosmetics Shop",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: goldColor.withValues(alpha: 0.16),
                          child: Text(
                            _initialsFor(user.name),
                            style: const TextStyle(
                              color: goldColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: darkBrown,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.role.isEmpty ? "Customer" : user.role,
                                style: const TextStyle(
                                  color: goldColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.email_outlined,
                    label: "Email",
                    value: user.email.isEmpty ? "-" : user.email,
                  ),
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    label: "Phone",
                    value: user.phone.isEmpty ? "-" : user.phone,
                  ),
                  _buildDetailRow(
                    icon: Icons.verified_user_outlined,
                    label: "Account ID",
                    value: user.id.isEmpty ? "-" : user.id,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: goldColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Your account details are used for checkout, order updates, and customer support.",
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showHelpCenter() async {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF2D1D15);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: goldColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: goldColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Help Center",
                              style: TextStyle(
                                color: darkBrown,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Beauty with me support",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How can we help?",
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "For product questions, checkout issues, delivery updates, or account support, contact our shop team.",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSupportAction(
                    icon: Icons.phone_outlined,
                    title: "Call support",
                    subtitle: "09 000 000 000",
                  ),
                  _buildSupportAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Message the shop",
                    subtitle: "Ask about products, stock, or your order",
                  ),
                  _buildSupportAction(
                    icon: Icons.receipt_long_outlined,
                    title: "Order help",
                    subtitle: "Check payment, delivery, and item details",
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Common Questions",
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFaqTile(
                    question: "Are the products authentic?",
                    answer:
                        "Yes. Beauty with me focuses on authentic cosmetics and skincare products.",
                  ),
                  _buildFaqTile(
                    question: "Can I change my order after checkout?",
                    answer:
                        "Please contact support as soon as possible before the order is prepared for delivery.",
                  ),
                  _buildFaqTile(
                    question: "How do I ask about product suitability?",
                    answer:
                        "Send us the product name and your skin concern. Our shop team will guide you.",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    const darkBrown = Color(0xFF2D1D15);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: darkBrown.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportAction({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    const darkBrown = Color(0xFF2D1D15);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD4AF37)),
        title: Text(
          title,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: darkBrown.withValues(alpha: 0.58),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: darkBrown,
          size: 14,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    const darkBrown = Color(0xFF2D1D15);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: const Color(0xFFD4AF37),
        collapsedIconColor: darkBrown,
        title: Text(
          question,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(
                color: darkBrown.withValues(alpha: 0.62),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return "U";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    const darkBrown = Color(0xFF2D1D15);
    const goldColor = Color(0xFFD4AF37);

    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: goldColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: goldColor, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkBrown,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: goldColor,
        size: 14,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.6),
      indent: 20,
      endIndent: 20,
    );
  }
}

class _ProfileEditResult {
  final String name;
  final String email;
  final String phone;

  const _ProfileEditResult({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class _ProfileEditDialog extends StatefulWidget {
  final UserModel user;

  const _ProfileEditDialog({required this.user});

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _ProfileEditResult(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF2D1D15);

    return AlertDialog(
      backgroundColor: const Color(0xFFFFFCF2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        "Edit Profile",
        style: TextStyle(
          color: darkBrown,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: goldColor.withValues(alpha: 0.16),
              child: Text(
                _initialsFor(widget.user.name),
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Profile photo upload can be added after avatar storage is ready.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            _buildField(
              controller: _nameController,
              label: "Name",
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _phoneController,
              label: "Phone",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Changing email may require confirmation before your login email is fully updated.",
                style: TextStyle(color: darkBrown, fontSize: 12, height: 1.35),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: darkBrown)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor,
            foregroundColor: darkBrown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF2D1D15);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: goldColor),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: darkBrown.withValues(alpha: 0.62)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldColor, width: 1.4),
        ),
      ),
    );
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return "U";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }
}
