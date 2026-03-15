import 'package:flutter/material.dart';

class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. MediaQuery for proportional scaling
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width * 0.05;
    final double verticalPadding = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ClientNest Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 2. LayoutBuilder to switch between Mobile and Tablet layouts
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout(context, horizontalPadding, verticalPadding);
          } else {
            return _buildTabletLayout(context, horizontalPadding, verticalPadding);
          }
        },
      ),
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(BuildContext context, double hPadding, double vPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(context, isMobile: true),
          const SizedBox(height: 24),
          _buildSectionTitle('Dashboard Summary'),
          const SizedBox(height: 12),
          _buildSummaryCard(
            context,
            title: 'Total Clients',
            value: '124',
            icon: Icons.people_rounded,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            context,
            title: 'Active Projects',
            value: '18',
            icon: Icons.work_rounded,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            context,
            title: 'Completed Tasks',
            value: '456',
            icon: Icons.task_alt_rounded,
            color: Colors.greenAccent,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            context,
            title: 'Activity',
            value: '+12%',
            icon: Icons.show_chart_rounded,
            color: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  // --- Tablet Layout ---
  Widget _buildTabletLayout(BuildContext context, double hPadding, double vPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(context, isMobile: false),
          const SizedBox(height: 32),
          _buildSectionTitle('Overview'),
          const SizedBox(height: 20),
          // Grid-like layout for Tablet
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2.2,
            children: [
              _buildSummaryCard(
                context,
                title: 'Total Clients',
                value: '124',
                icon: Icons.people_rounded,
                color: Colors.blueAccent,
              ),
              _buildSummaryCard(
                context,
                title: 'Active Projects',
                value: '18',
                icon: Icons.work_rounded,
                color: Colors.orangeAccent,
              ),
              _buildSummaryCard(
                context,
                title: 'Completed Tasks',
                value: '456',
                icon: Icons.task_alt_rounded,
                color: Colors.greenAccent,
              ),
              _buildSummaryCard(
                context,
                title: 'Activity',
                value: '+12%',
                icon: Icons.show_chart_rounded,
                color: Colors.purpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Reusable UI Header ---
  Widget _buildWelcomeHeader(BuildContext context, {required bool isMobile}) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: isMobile ? size.width : size.width * 0.8, // Proportional scaling
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Admin',
            style: TextStyle(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep track of your client projects and goals.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  // --- Reusable Summary Card ---
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.15; // Proportional scaling

    return Container(
      height: cardHeight,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
