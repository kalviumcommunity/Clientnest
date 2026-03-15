import 'package:flutter/material.dart';

/// StateManagementDemo
/// 
/// A screen demonstrating local state management in Flutter using StatefulWidget and setState().
/// Simulations of a Client Activity Tracker for the ClientNest application.
class StateManagementDemo extends StatefulWidget {
  const StateManagementDemo({super.key});

  @override
  State<StateManagementDemo> createState() => _StateManagementDemoState();
}

class _StateManagementDemoState extends State<StateManagementDemo> {
  // 1. State Variable
  int _activityCount = 0;

  // 2. State Modification Functions
  void _incrementActivity() {
    setState(() {
      _activityCount++;
    });
  }

  void _decrementActivity() {
    if (_activityCount > 0) {
      setState(() {
        _activityCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Dynamic Logic: Determine background color based on activity count
    final counterBgColor = _activityCount >= 5 
        ? Colors.greenAccent.withOpacity(0.3) 
        : colorScheme.surfaceVariant.withOpacity(0.5);
    
    final accentColor = _activityCount >= 5 ? Colors.green : colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Client Activity Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Activity Info Section ---
              const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Tracking activities for Active Client',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // --- Counter Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: counterBgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: accentColor.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Completed Activities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_activityCount',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    if (_activityCount >= 5) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars_rounded, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Goal Reached!',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // --- Action Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Temporarily wrap in Expanded for better sizing on various screens
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _decrementActivity,
                        icon: const Icon(Icons.remove_rounded),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.red.withOpacity(0.1)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _incrementActivity,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Activity'),
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
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // --- Footer Note ---
              Text(
                'Activities reset every 24 hours',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
