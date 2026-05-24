import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}


class _AccountPageState extends State<AccountPage>{

  final UserService _userService = UserService();
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserProfile(); // Screen စဖွင့်တာနဲ့ Data လှမ်းယူမယ်
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
    
    // (၁) Scaffold ရဲ့ body မှာ FutureBuilder ကို အရင်ထည့်ပါ
    body: FutureBuilder<UserModel>(
      future: _userService.getUserProfile(), // Service ကနေ Data ခေါ်တယ်
      builder: (context, snapshot) {
        // (၂) Data စောင့်နေချိန်
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // (၃) Error တက်ခဲ့ရင်
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        // (၄) Data အောင်မြင်စွာရလာရင် (ဒီနေရာမှာ အစ်မရဲ့ မူလ UI ကို ပြန်ထည့်မယ်)
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return _buildProfileUI(user); // ဒီ Function ထဲမှာ မူလ UI ကို ထည့်ပေးမယ်
        }
        return const Center(child: Text("No data"));
      },
    ),
  );
  }
  Widget _buildProfileUI(UserModel user) {

    // Figma ဒီဇိုင်းထဲက အရောင်ကုဒ်များ
    const Color goldColor = Color(0xFFD4AF37);
    const Color darkBrown = Color(0xFF2D1D15);
    const Color bgColor = Color(0xFFFFFCF2);
    const Color cardBgColor = Color(0xFFFFFFFF);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // (၁) စာမျက်နှာ ခေါင်းစဉ် - Account
              const Text(
                "Account",
                style: TextStyle(
                  color: goldColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // (၂) Profile Card (အဝိုင်းပုံစံ Avatar နှင့် နာမည်၊ အီးမေးလ်)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: darkBrown,
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // Name & Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: darkBrown.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // ညာဘက်မြှားခလုတ်
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: darkBrown,
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // (၃) Settings / Options List 
              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                      onTap: () {
                        // TODO: My Details သို့သွားရန်
                      },
                    ),
                    _buildDivider(),
                    _buildAccountOption(
                      icon: Icons.notifications_none_rounded,
                      title: "Notifecations", // Figma ထဲက စာလုံးပေါင်းအတိုင်း ရေးပေးထားပါတယ်ဗျာ
                      onTap: () {
                        // TODO: Notifications သို့သွားရန်
                      },
                    ),
                    _buildDivider(),
                    _buildAccountOption(
                      icon: Icons.help_outline_rounded,
                      title: "Help center & support",
                      onTap: () {
                        // TODO: Help Center သို့သွားရန်
                      },
                    ),
                    _buildDivider(),
                    _buildAccountOption(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      onTap: () async {
                        await _userService.signOut(); // ခုနက လုပ်ထားတဲ့ function
                        
                        // အရေးကြီးဆုံးအပိုင်း - အရင် Screen အဟောင်းတွေကို အကုန်ဖြတ်ထုတ်ပြီး Login screen ကို ပြန်ပို့တာ
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        }
                      },
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

  // List Tile တစ်ခုချင်းစီ ဆောက်ပေးမယ့် Helper Function
  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    const Color darkBrown = Color(0xFF2D1D15);
    
    return ListTile(
      leading: Icon(icon, color: darkBrown, size: 22),
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
        color: darkBrown,
        size: 14,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  // Tiles ကြားထဲက မျဉ်းကြောင်းတားပေးမည့် Widget
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.6), // ကြည့်ရသက်သာအောင် အဖြူလိုင်းဖျော့ဖျော့လေး သုံးထားပါတယ်
      indent: 20,
      endIndent: 20,
    );
  }
}