import 'package:flutter/material.dart';
import 'dart:ui';
import '../features/dashboard/dashboard_screen.dart';
import 'projects_screen.dart';
import 'clients_screen.dart';
import 'payments_screen.dart';
import 'calendar_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/client_provider.dart';
import '../providers/project_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/time_tracker_provider.dart';
import '../shared/widgets/premium_background.dart';

class MainScreenWrapper extends StatefulWidget {
  const MainScreenWrapper({super.key});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _currentIndex = 2; // Default to Dashboard (Home)
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Trigger initial data fetch when main wrapper is built (user is authenticated)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint('MainScreenWrapper: Fetching data for all providers...');
        context.read<ClientProvider>().fetchClients();
        context.read<ProjectProvider>().fetchProjects();
        context.read<InvoiceProvider>().fetchInvoices();
        context.read<TimeTrackerProvider>().init();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    return Scaffold(
      extendBody: true,
      body: PremiumBackground(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          physics: const BouncingScrollPhysics(),
          children: _screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.65),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    currentIndex: _currentIndex,
                    selectedItemColor: colorScheme.primary,
                    unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.4),
                    elevation: 0,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    onTap: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubicEmphasized,
                      );
                    },
                    items: [
                      _buildNavItem(Icons.people_outlined, Icons.people, 'CRM', _currentIndex == 0),
                      _buildNavItem(Icons.assignment_outlined, Icons.assignment, 'Nests', _currentIndex == 1),
                      _buildNavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Home', _currentIndex == 2),
                      _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Finance', _currentIndex == 3),
                      _buildNavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Planner', _currentIndex == 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12, 
          vertical: 8
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? activeIcon : icon, 
          size: isSelected ? 26 : 24,
        ),
      ),
      label: label,
    );
  }
}
