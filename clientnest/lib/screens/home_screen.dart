import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../core/theme/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
             backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                 ? Text(user?.displayName?.substring(0, 1).toUpperCase() ?? 'U', style: TextStyle(color: Theme.of(context).primaryColor))
                 : null,
          ),
        ),
        actions: [
          // Theme Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!isDark);
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Hello, ${user?.displayName?.split(' ')[0] ?? 'Freelancer'}! 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Here is your daily overview.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards Row
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _SummaryCard(
                    title: 'Active Tasks',
                    count: '12',
                    icon: Icons.assignment_rounded,
                    color: Colors.blueAccent,
                    onTap: () => context.push('/tasks'), // Assuming route exists or will be added
                  ),
                  const SizedBox(width: 16),
                  _SummaryCard(
                    title: 'Pending',
                    count: '\$1,250',
                    icon: Icons.payments_rounded,
                    color: Colors.orangeAccent,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _SummaryCard(
                    title: 'Clients',
                    count: '8',
                    icon: Icons.people_rounded,
                    color: Colors.purpleAccent,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Recent Activity / Upcoming Deadlines
            _SectionHeader(title: 'Upcoming Deadlines', icon: Icons.timer_outlined),
            const SizedBox(height: 16),
            
            _TaskTile(
              title: 'Website Redesign',
              client: 'Acme Corp',
              date: 'Tomorrow, 5:00 PM',
              priority: 'High',
              color: Colors.redAccent,
            ),
            _TaskTile(
              title: 'Mobile App Icon',
              client: 'StartupX',
              date: 'Wed, 12 Feb',
              priority: 'Medium',
              color: Colors.orange,
            ),
            _TaskTile(
              title: 'Backend API Fixes',
              client: 'Techy Inc',
              date: 'Fri, 14 Feb',
              priority: 'Low',
              color: Colors.green,
            ),

            const SizedBox(height: 32),
             _SectionHeader(title: 'Quick Actions', icon: Icons.bolt_outlined),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(
                   child: _QuickActionButton(
                     label: 'New Task',
                     icon: Icons.add_task_rounded,
                     color: Theme.of(context).primaryColor,
                     onTap: () {},
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: _QuickActionButton(
                     label: 'New Client',
                     icon: Icons.person_add_rounded,
                     color: Colors.teal,
                     onTap: () {},
                   ),
                 ),
               ],
             ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final String client;
  final String date;
  final String priority;
  final Color color;

  const _TaskTile({
    required this.title,
    required this.client,
    required this.date,
    required this.priority,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  client,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                   color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                   fontSize: 12,
                   fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
