import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import '../widgets/glass_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background System
          Container(color: const Color(0xFF03050C)),
          Positioned(
            top: -50,
            right: -50,
            child: _buildOrb(const Color(0xFF8B5CF6), 0.15),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: _buildOrb(const Color(0xFF0EA5E9), 0.1),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              // Animated Logo
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.8, end: 1.0),
                                duration: const Duration(seconds: 2),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(scale: value, child: child);
                                },
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                'PayMint',
                                style: GoogleFonts.outfit(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GlassContainer(
                                blur: 15,
                                opacity: 0.05,
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Text(
                                    'Smart Bill Management with\nIntelligent Reminders',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 60),
                              
                              // Action Buttons
                              _buildPrimaryButton(context),
                              const SizedBox(height: 16),
                              _buildGoogleButton(context),
                              const SizedBox(height: 20),
                              _buildLoginButton(context),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(Color color, double opacity) {
    return Container(
      width: 350,
      height: 350,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return GlassButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      ),
      text: 'Get Started',
      gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return GlassButton(
      onPressed: () async {
        final AuthService auth = AuthService();
        final error = await auth.signInWithGoogle();
        if (context.mounted && error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error, style: GoogleFonts.outfit(color: Colors.white)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      text: 'Continue with Google',
      customIcon: const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 20),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ),
      child: Text(
        'I already have an account',
        style: GoogleFonts.outfit(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
