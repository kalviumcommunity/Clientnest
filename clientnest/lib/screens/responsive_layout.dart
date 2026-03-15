import 'package:flutter/material.dart';

class ResponsiveLayoutScreen extends StatelessWidget {
  const ResponsiveLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect screen width
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. Header Section
            Container(
              width: double.infinity,
              height: 150,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Header Section',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 3 & 5. Main Content Area (Responsive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMainContent(context, isLargeScreen),
            ),

            // 4. Footer Section
            Container(
              width: double.infinity,
              height: 80,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Footer Section',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isLargeScreen) {
    List<Widget> panels = [
      Expanded(
        flex: isLargeScreen ? 1 : 0,
        child: Container(
          height: isLargeScreen ? 300 : 150,
          width: isLargeScreen ? null : double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Left Panel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16, height: 16),
      Expanded(
        flex: isLargeScreen ? 1 : 0,
        child: Container(
          height: isLargeScreen ? 300 : 150,
          width: isLargeScreen ? null : double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Right Panel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ];

    if (isLargeScreen) {
      return Row(children: panels);
    } else {
      // For small screens, remove Expanded to avoid height constraint issues in SingleChildScrollView
      // or wrap with a fixed height. Removing flex 1 for small screens.
      return Column(
        children: panels.map((w) {
          if (w is Expanded) return w.child;
          return w;
        }).toList(),
      );
    }
  }
}
