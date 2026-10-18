import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../home/presentation/screens/home_screen.dart';
import '../expense/presentation/screens/add_expense_screen.dart';
import '../groups/presentation/screens/groups_list_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeScreen(
        onProfileTap: () => _onTabTapped(3),
        onAddExpenseTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const AddExpenseScreen(),
            ),
          );
        },
        onSettleUpTap: () {
          // Settle up modal in Step 7
        },
      ),
      const GroupsListScreen(),
      const _PlaceholderScreen(title: 'Spends Analytics (Step 8)'),
      const _PlaceholderScreen(title: 'Profile & Pay Me QR (Step 7)'),
    ];

    final navBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final navBorderColor = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(
            top: BorderSide(color: navBorderColor, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              label: 'Home',
              icon: Icons.dashboard_rounded,
              isSelected: _currentIndex == 0,
              onTap: () => _onTabTapped(0),
            ),
            _NavItem(
              label: 'Groups',
              icon: Icons.group_work_rounded,
              isSelected: _currentIndex == 1,
              onTap: () => _onTabTapped(1),
            ),
            _NavItem(
              label: 'Spends',
              icon: Icons.pie_chart_rounded,
              isSelected: _currentIndex == 2,
              onTap: () => _onTabTapped(2),
            ),
            _NavItem(
              label: 'Profile',
              icon: Icons.person_rounded,
              isSelected: _currentIndex == 3,
              onTap: () => _onTabTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedColor = isDark ? AppColors.mint : AppColors.textLightPrimary;
    final unselectedColor = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCockpitGradientStart : AppColors.cockpitGradientStart,
      body: Center(
        child: Text(
          title,
          style: AppTypography.screenTitle.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
