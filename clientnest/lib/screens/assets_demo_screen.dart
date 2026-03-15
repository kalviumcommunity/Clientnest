import 'package:flutter/material.dart';

class AssetsDemoScreen extends StatelessWidget {
  const AssetsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect theme brightness and current color scheme
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDarkMode = brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClientNest Assets'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Logo Section ---
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/clientnest_logo.png',
                width: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.business_center, size: 80, color: colorScheme.primary),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'CLIENTNEST',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),

            // --- Banner Section ---
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blueGrey[900] : Colors.blueGrey[100],
                    ),
                    child: Image.asset(
                      'assets/images/dashboard_banner.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode 
                                ? [Colors.black87, Colors.indigo[900]!] 
                                : [Colors.blue[100]!, Colors.blue[300]!],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Overlay to ensure text readability
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: isDarkMode ? Colors.black45 : Colors.white24,
                  ),
                  Text(
                    'Welcome to ClientNest',
                    style: textTheme.headlineMedium?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- Feature Icons Section ---
            _buildSectionTitle(context, 'Core Features'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconFeature(
                  context,
                  assetPath: 'assets/icons/client_icon.png',
                  label: 'Clients',
                  defaultIcon: Icons.people_alt,
                ),
                _buildIconFeature(
                  context,
                  assetPath: 'assets/icons/project_icon.png',
                  label: 'Projects',
                  defaultIcon: Icons.assignment,
                ),
                _buildIconFeature(
                  context,
                  assetPath: 'assets/icons/task_icon.png',
                  label: 'Tasks',
                  defaultIcon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconFeature(
    BuildContext context, {
    required String assetPath,
    required String label,
    required IconData defaultIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = MediaQuery.of(context).size.width * 0.12;

    return Column(
      children: [
        Container(
          width: iconSize + 20,
          height: iconSize + 20,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(defaultIcon, size: iconSize, color: colorScheme.secondary);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
