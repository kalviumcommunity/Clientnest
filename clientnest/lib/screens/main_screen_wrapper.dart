import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clientnest/screens/dashboard_screen.dart';
import 'projects_screen.dart';
import 'clients_screen.dart';
import 'payments_screen.dart';
import 'calendar_screen.dart';
import 'package:clientnest/widgets/premium_background.dart';
import 'package:clientnest/core/theme/nest_design_system.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import 'package:clientnest/screens/projects/create_project_screen.dart';

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper>
    with TickerProviderStateMixin {
  int _currentIndex = 2; // Default to Dashboard (Home)
  late PageController _pageController;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'CRM',
    ),
    _NavItem(
      icon: Icons.rocket_outlined,
      activeIcon: Icons.rocket_launch_rounded,
      label: 'Nests',
    ),
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Finance',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Plan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
    );
  }

  final List<Widget> _screens = const [
    ClientsScreen(),
    ProjectsScreen(),
    DashboardScreen(),
    PaymentsScreen(),
    CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;

    return Scaffold(
      extendBody: true,
      body: PremiumBackground(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          physics: const BouncingScrollPhysics(),
          children: _screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 12 : 20,
            0,
            isCompact ? 12 : 20,
            16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: NestDesignSystem.darkSurface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (index) => _buildNavButton(
                  context,
                  index,
                  colorScheme,
                  isCompact,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 1 || _currentIndex == 2
          ? Padding(
              padding: const EdgeInsets.only(bottom: 74, right: 0),
              child: PrimaryButton(
                label: _currentIndex == 1 ? 'Add Nest' : 'New Project',
                onTap: () {
                  if (_currentIndex == 1) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const CreateProjectScreen(),
                    );
                  } else {
                    // Similar for Dashboard if needed
                  }
                },
                icon: Icons.add_rounded,
              ),
            )
          : null,
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    int index,
    ColorScheme colorScheme,
    bool isCompact,
  ) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutQuart,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? NestDesignSystem.accent.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey('nav_icon_${index}_$isSelected'),
                  size: 22,
                  color: isSelected
                      ? NestDesignSystem.accent
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected
                    ? NestDesignSystem.accent
                    : colorScheme.onSurface.withValues(alpha: 0.3),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
