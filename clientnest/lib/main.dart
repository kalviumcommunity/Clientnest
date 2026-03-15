import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'services/auth_service.dart';
import 'providers/client_provider.dart';
import 'providers/project_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/time_tracker_provider.dart';

// Features
import 'features/auth/splash_screen.dart';
import 'features/auth/landing_page.dart';
import 'features/auth/login_screen.dart'    as feature_login;
import 'features/auth/signup_screen.dart'   as feature_signup;
import 'screens/main_screen_wrapper.dart';
import 'screens/nav_demo_home_screen.dart';
import 'screens/details_screen.dart';
import 'screens/responsive_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ClientNestApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth-wrapper',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const feature_login.LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const feature_signup.SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScreenWrapper(),
    ),
    // ── Navigation Demo routes ──────────────────────────────────────────────
    GoRoute(
      path: '/nav-demo',
      builder: (context, state) => const NavDemoHomeScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => DetailsScreen(
        message: (state.extra as Map<String, dynamic>?)?['message'] as String?,
        method:  (state.extra as Map<String, dynamic>?)?['method']  as String?,
      ),
    ),
    GoRoute(
      path: '/responsive',
      builder: (context, state) => const ResponsiveLayoutScreen(),
    ),
  ],
);

class ClientNestApp extends StatelessWidget {
  const ClientNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => TimeTrackerProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'ClientNest',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('AuthWrapper: Building...');
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        debugPrint('AuthWrapper Stream: State=${snapshot.connectionState}, HasData=${snapshot.hasData}, HasError=${snapshot.hasError}');
        
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Authentication Error', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/auth-wrapper'),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verifying session...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          debugPrint('AuthWrapper: User is ${user?.uid ?? "null"}');
          if (user == null) {
            return const LandingPage();
          }
          return const MainScreenWrapper();
        }
        
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
