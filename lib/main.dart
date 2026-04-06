import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/notification_service.dart';
import 'screens/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with explicit options for Cross-platform stability
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize Local Notifications
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: PayMintApp(),
    ),
  );
}

class PayMintApp extends StatelessWidget {
  const PayMintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PayMint',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060E20),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
          secondary: const Color(0xFFC59AFF),
          surface: const Color(0xFF1E293B),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
