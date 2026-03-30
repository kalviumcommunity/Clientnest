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
import 'package:clientnest/screens/splash_screen.dart';
import 'package:clientnest/screens/landing_page.dart';
import 'package:clientnest/screens/login_screen.dart'    as feature_login;
import 'package:clientnest/screens/signup_screen.dart'   as feature_signup;
import 'screens/main_screen_wrapper.dart';
import 'screens/nav_demo_home_screen.dart';
import 'screens/details_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/scrollable_views.dart';
import 'screens/user_input_form.dart';
import 'screens/state_management_demo.dart';
import 'screens/responsive_dashboard.dart';
import 'screens/assets_demo_screen.dart';
import 'screens/animation_demo_screen.dart';
import 'screens/firebase_status_screen.dart';
import 'firebase_options.dart';
import 'package:clientnest/utils/go_router_refresh_stream.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if it hasn't been initialized yet
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully.');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // We continue so the app can at least show an error state later if needed
  }
  
  runApp(const ClientNestApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
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
    GoRoute(
      path: '/scrollable-dashboard',
      builder: (context, state) => const ScrollableViewsScreen(),
    ),
    GoRoute(
      path: '/add-client',
      builder: (context, state) => const UserInputForm(),
    ),
    GoRoute(
      path: '/activity-tracker',
      builder: (context, state) => const StateManagementDemo(),
    ),
    GoRoute(
      path: '/responsive-dashboard',
      builder: (context, state) => const ResponsiveDashboard(),
    ),
    GoRoute(
      path: '/assets-demo',
      builder: (context, state) => const AssetsDemoScreen(),
    ),
    GoRoute(
      path: '/animation-demo',
      builder: (context, state) => const AnimationDemoScreen(),
    ),
    GoRoute(
      path: '/firebase-status',
      builder: (context, state) => const FirebaseStatusScreen(),
    ),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoingToSecuredRoute = state.uri.path == '/home';
    final isGoingToAuthRoute = state.uri.path == '/login' || 
                               state.uri.path == '/signup' || 
                               state.uri.path == '/landing';

    // Prevent unauthenticated access to secure routes
    if (user == null && isGoingToSecuredRoute) {
      return '/landing';
    }
    // Prevent authenticated access to auth routes
    if (user != null && isGoingToAuthRoute) {
      return '/home';
    }

    return null; // No redirect needed
  },
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
