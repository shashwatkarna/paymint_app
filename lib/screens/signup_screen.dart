import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  
  // Stage 1 Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Stage 2 Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  void _nextStep() {
    if (_formKey1.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep = 1);
    }
  }

  void _completeSignup() async {
    if (_formKey2.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final error = await _auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (error != null) {
          _showError(error);
          setState(() => _isLoading = false);
          return;
        }

        // Save Profile
        final user = _auth.currentUser;
        if (user != null) {
          await _userService.saveProfile(UserProfile(
            uid: user.uid,
            name: _nameController.text.trim(),
            age: int.tryParse(_ageController.text.trim()) ?? 0,
          ));
        }

        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        _showError('Failed to complete signup: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.manrope(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: _currentStep == 1 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded), 
              onPressed: () {
                _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
                setState(() => _currentStep = 0);
              }
            )
          : null,
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF03050C)),
          _buildBackgroundGlow(),
          
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStepOne(),
                _buildStepTwo(),
              ],
            ),
          ),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9))),
        ],
      ),
    );
  }

  Widget _buildStepOne() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildHeader('Create Account', 'Step 1 of 2: Login Details'),
            const SizedBox(height: 40),
            _buildLabel('Email Address'),
            _buildTextField(_emailController, 'Enter your email', Icons.email_outlined, false),
            const SizedBox(height: 20),
            _buildLabel('Password'),
            _buildTextField(_passwordController, 'Create password', Icons.lock_outline, true),
            const SizedBox(height: 20),
            _buildLabel('Confirm Password'),
            _buildTextField(_confirmPasswordController, 'Confirm password', Icons.lock_reset_rounded, true),
            const SizedBox(height: 48),
            _buildActionButton('Continue', _nextStep),
            const SizedBox(height: 24),
            
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.white10)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or continue with',
                    style: GoogleFonts.manrope(color: Colors.white24, fontSize: 13),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.white10)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Google Signup Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: GlassContainer(
                blur: 25,
                opacity: 0.1,
                borderRadius: BorderRadius.circular(20),
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
                ),
                child: InkWell(
                  onTap: () async {
                    setState(() => _isLoading = true);
                    final error = await _auth.signInWithGoogle();
                    
                    if (!context.mounted) return;
                    if (error != null) {
                      if (context.mounted) _showError(error);
                      if (mounted) setState(() => _isLoading = false);
                      return;
                    }

                    // For Google Sign-In, we might want to auto-create a profile if it doesn't exist
                    final user = _auth.currentUser;
                    if (user != null) {
                      // Check if profile exists; if not, use display name
                      final existing = await _userService.getProfile(user.uid);
                      if (existing == null) {
                        await _userService.saveProfile(UserProfile(
                          uid: user.uid,
                          name: user.displayName ?? 'New User',
                          age: 0,
                        ));
                      }
                    }

                    // Final safety check before specialized BuildContext operations
                    if (!mounted) return;
                    Navigator.popUntil(context, (route) => route.isFirst);
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Google Account',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildHeader('Complete Profile', 'Step 2 of 2: Personal Info'),
            const SizedBox(height: 40),
            _buildLabel('Full Name'),
            _buildTextField(_nameController, 'Enter your name', Icons.person_outline_rounded, false),
            const SizedBox(height: 20),
            _buildLabel('Age'),
            _buildTextField(_ageController, 'Enter your age', Icons.cake_outlined, false, isNumber: true),
            const SizedBox(height: 48),
            _buildActionButton('Complete Signup', _completeSignup),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 8),
        Text(sub, style: GoogleFonts.manrope(fontSize: 15, color: Colors.white54, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(label, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword, {bool isNumber = false}) {
    return GlassContainer(
      blur: 25,
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.emailAddress,
        style: GoogleFonts.manrope(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF0EA5E9), size: 20),
          hintStyle: GoogleFonts.manrope(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'This field is required';
          if (isNumber && int.tryParse(value) == null) return 'Enter a valid number';
          return null;
        },
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: GlassContainer(
        blur: 20,
        gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Center(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5))),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: GoogleFonts.manrope(color: Colors.white54)),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          child: Text('Sign In', style: GoogleFonts.manrope(color: const Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [const Color(0xFF0EA5E9).withValues(alpha: 0.1), const Color(0xFF0EA5E9).withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
