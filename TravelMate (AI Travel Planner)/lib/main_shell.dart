import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/home/home_screen.dart';
import 'features/trip_planner/screens/my_trips_screen.dart';
import 'features/expense_tracker/screens/expense_overview_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'core/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyTripsScreen(),
    const ExpenseOverviewScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavData(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavData(Icons.card_travel_rounded, Icons.card_travel_outlined, 'My Trips'),
    _NavData(Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Expenses'),
    _NavData(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E35) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0x18FFFFFF) : Colors.black.withOpacity(0.06), width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.6 : 0.05), blurRadius: 30, offset: const Offset(0, -8)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.asMap().entries.map((e) {
              return _NavItem(
                data: e.value,
                index: e.key,
                currentIndex: currentIndex,
                onTap: () => onTap(e.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavData(this.activeIcon, this.inactiveIcon, this.label);
}

class _NavItem extends StatelessWidget {
  final _NavData data;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: context.isDarkMode
                      ? const [Color(0x22F39C12), Color(0x222E86DE)]
                      : [AppColorsLight.primary.withOpacity(0.12), AppColorsLight.primary.withOpacity(0.04)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? data.activeIcon : data.inactiveIcon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected
                    ? (context.isDarkMode ? AppColors.accent : AppColorsLight.primary)
                    : context.textHint,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? (context.isDarkMode ? AppColors.accent : AppColorsLight.primary)
                    : context.textHint,
              ),
              child: Text(data.label),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? (context.isDarkMode
                        ? AppColors.primaryGradient
                        : const LinearGradient(colors: [AppColorsLight.primary, AppColorsLight.teal]))
                    : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
