import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final String? message;
  final String? method;

  const DetailsScreen({super.key, this.message, this.method});

  @override
  Widget build(BuildContext context) {
    // Resolve arguments from either constructor or ModalRoute
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final displayMessage = message ?? (routeArgs is String ? routeArgs : null);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Details Screen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (displayMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    displayMessage,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (method != null) ...[
                Text(
                  'Method: $method',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 32),
              ],
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate back home
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
