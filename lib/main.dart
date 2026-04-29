import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/services/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/setup_screen.dart';
import 'features/dashboard/screens/observer_dashboard.dart';
import 'features/dashboard/services/status_provider.dart';
import 'core/notification_service.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
      ],
      child: const PulsePointApp(),
    ),
  );
}

class PulsePointApp extends StatelessWidget {
  const PulsePointApp({super.key});

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);
    final auth = Provider.of<AuthState>(context);
    final themeColor = statusProvider.themeColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PulsePoint',
      themeMode: auth.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          primary: themeColor,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Midnight Slate
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B), // Dark Slate
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const _Router(),
    );
  }
}

/// Three-step router:
///   1. Not authenticated  → LoginScreen
///   2. Authenticated, no  profile → SetupScreen
///   3. Authenticated + profile set → ObserverDashboard
class _Router extends StatelessWidget {
  const _Router();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    if (!auth.isSetupComplete) {
      return const SetupScreen();
    }

    return const ObserverDashboard();
  }
}
