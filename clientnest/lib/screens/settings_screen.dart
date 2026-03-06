import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../core/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final user = authService.currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          if (user != null)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? Text(user.displayName?.substring(0, 1).toUpperCase() ?? 'U', style: TextStyle(color: Theme.of(context).primaryColor))
                    : null,
              ),
              title: Text(user.displayName ?? 'Freelancer', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user.email ?? ''),
            ),
          const Divider(height: 32),
          
          const Text('Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          // Availability Toggle (Firebase-backed)
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getUserStream(),
            builder: (context, snapshot) {
               bool isAvailable = false;
               if (snapshot.hasData && snapshot.data!.exists) {
                 final data = snapshot.data!.data() as Map<String, dynamic>?;
                 if (data != null && data.containsKey('isAvailable')) {
                   isAvailable = data['isAvailable'] as bool;
                 }
               }
               return SwitchListTile(
                 title: const Text('Open for New Work'),
                 subtitle: const Text('Let clients know you are available.'),
                 secondary: Icon(
                   isAvailable ? Icons.check_circle_outline : Icons.do_not_disturb_alt,
                   color: isAvailable ? Colors.green : Colors.grey,
                 ),
                 value: isAvailable,
                 onChanged: (bool value) async {
                   await firestoreService.updateAvailability(value);
                 },
               );
            },
          ),
          
          const Divider(height: 32),
          const Text('App Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          
          // Theme Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            value: isDark,
            onChanged: (bool value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
            },
          ),
          
          const Divider(height: 32),
          
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}
