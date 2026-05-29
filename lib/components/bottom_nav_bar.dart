import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ), // ဘေးထောင့် ဝိုင်းဝိုင်းလေး
        border: Border(
          top: BorderSide(
            color: Color(0xFFD4AF37),
            // width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround, // အကွာအဝေး ညီညီညာညာခွဲရန်
        children: [
          _buildNavItem(index: 0, icon: Icons.home_filled, label: 'Home'),
          _buildNavItem(
            index: 1,
            icon: Icons.all_inbox_rounded,
            label: 'Product',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.favorite_border_rounded,
            label: 'Wishlist',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.shopping_cart_outlined,
            label: 'Cart',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.person_outline_rounded,
            label: 'Account',
          ),
        ],
      ),
    );
  }

  // Nav Item တစ်ခုချင်းစီကို ပုံဖော်မည့် Widget Function
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;
    const inactiveColor = Color(0xFFD4AF37);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque, // ကွက်လပ်နှိပ်ရင်လည်း အလုပ်လုပ်စေရန်
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // နှိပ်ထားတဲ့ Item ဖြစ်ရင် ရွှေရောင် Gradient နောက်ခံပြမယ်
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFD4AF37),
                    Color(0xFFF7F1E3),
                    Color(0xFFD4AF37),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null, // မနှိပ်ထားရင် ဘာအရောင်မှ မရှိ (White နောက်ခံအတိုင်း)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // နေရာအကျယ်ကြီး မယူစေရန်
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF2D1D15)
                  : inactiveColor.withValues(alpha: 0.72),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2D1D15)
                    : inactiveColor.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
