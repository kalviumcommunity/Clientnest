import 'package:flutter/material.dart';

class ScrollableViewsScreen extends StatelessWidget {
  const ScrollableViewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid columns
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'ClientNest Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section 1: Recent Clients (Horizontal ListView) ---
            _buildSectionHeader(context, "Recent Clients"),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final statuses = ['Active', 'Pending', 'Active', 'Active', 'Pending', 'Active'];
                  final names = ['Alex Johnson', 'Maria Garcia', 'Tech Solutions', 'Global Inc', 'Sarah Smith', 'Design Co'];
                  
                  return _buildClientCard(
                    context,
                    name: names[index % names.length],
                    status: statuses[index % statuses.length],
                    index: index,
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(indent: 20, endIndent: 20, thickness: 1, height: 1),
            ),

            // --- Section 2: Active Projects (GridView) ---
            _buildSectionHeader(context, "Active Projects"),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final projects = [
                    {'title': 'Website Redesign', 'status': 'In Progress', 'icon': Icons.web_rounded},
                    {'title': 'Mobile App', 'status': 'Testing', 'icon': Icons.phone_android_rounded},
                    {'title': 'Brand Identity', 'status': 'Completed', 'icon': Icons.palette_rounded},
                    {'title': 'Marketing Plan', 'status': 'Planning', 'icon': Icons.campaign_rounded},
                    {'title': 'API Integration', 'status': 'In Progress', 'icon': Icons.api_rounded},
                    {'title': 'SEO Audit', 'status': 'Ongoing', 'icon': Icons.search_rounded},
                  ];
                  
                  final project = projects[index % projects.length];
                  return _buildProjectTile(
                    context,
                    title: project['title'] as String,
                    status: project['status'] as String,
                    icon: project['icon'] as IconData,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, {required String name, required String status, required int index}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPending = status == 'Pending';

    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                name[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isPending ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTile(BuildContext context, {required String title, required String status, required IconData icon}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              status,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
