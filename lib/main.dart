import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notification Service
  await NotificationService.init();
  
  // Initialize Firebase with the manually generated options to avoid CLI dependency
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: PayMintApp(),
    ),
  );
}

class PayMintApp extends ConsumerWidget {
  const PayMintApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'PayMint',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF8B5CF6),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF03050C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
          surface: const Color(0xFF060E20),
          onSurface: const Color(0xFFDEE5FF),
          onSurfaceVariant: const Color(0xFFA3AAC4),
        ),
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme.copyWith(
            displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
            headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
            labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, letterSpacing: 0.8),
          ).apply(
            bodyColor: const Color(0xFFDEE5FF),
            displayColor: Colors.white,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// AuthWrapper: Manages the high-level application state based on authentication.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = AuthService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            ),
          );
        }
        
        if (snapshot.hasData) {
          // User is signed in
          return const DashboardScreen();
        }
        
        // User is not signed in
        return const WelcomeScreen();
      },
    );
  }
}
