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
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  currentIndex: _currentIndex,
                  selectedItemColor: colorScheme.primary,
                  unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.4),
                  elevation: 0,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                  onTap: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubicEmphasized,
                    );
                  },
                  items: [
                    _buildNavItem(Icons.people_outlined, Icons.people, 'CRM'),
                    _buildNavItem(Icons.assignment_outlined, Icons.assignment, 'Nests'),
                    _buildNavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Home'),
                    _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Finance'),
                    _buildNavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Planner'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon, size: 24),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(activeIcon, size: 24),
        ),
      ),
      label: label,
    );
  }
}
