import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);
    final authService = AuthService();

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Theme.of(context).scaffoldBackgroundColor),
          _buildBackgroundGlow(),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(context),
                SliverList(
                  delegate: SliverChildListDelegate([
                    profileAsync.when(
                      data: (profile) => _buildProfileSection(context, ref, profile, authService.currentUser?.email ?? ''),
                      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                      error: (e, s) => Center(child: Text('Error loading profile', style: GoogleFonts.manrope(color: Colors.redAccent))),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Preferences'),
                    _buildThemeToggle(ref, themeMode),
                    _buildCurrencySelector(context, ref, currency),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Support'),
                    _buildSettingTile(Icons.help_outline_rounded, 'Help Center', 'FAQs and troubleshooting', null),
                    _buildSettingTile(Icons.security_rounded, 'Privacy Policy', 'How we handle your data', null),
                    const SizedBox(height: 32),
                    _buildSignOutButton(context, authService),
                    const SizedBox(height: 48),
                    _buildVersionInfo(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref, UserProfile? profile, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        blur: 25,
        opacity: 0.08,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)]),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile?.name ?? 'User', 
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email, style: GoogleFonts.manrope(color: Colors.white54, fontSize: 13)),
                    if (profile != null)
                      Text('Age: ${profile.age}', style: GoogleFonts.manrope(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
                onPressed: () => _showEditProfileDialog(context, ref, profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserProfile? profile) {
    if (profile == null) return;
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Edit Profile', style: GoogleFonts.manrope(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white54)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age', labelStyle: TextStyle(color: Colors.white54)),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newProfile = UserProfile(
                uid: profile.uid,
                name: nameController.text.trim(),
                age: int.tryParse(ageController.text.trim()) ?? profile.age,
                currency: profile.currency,
              );
              await UserService().saveProfile(newProfile);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(WidgetRef ref, ThemeMode currentMode) {
    return _buildSettingTile(
      Icons.dark_mode_rounded, 
      'Dark Mode', 
      currentMode == ThemeMode.dark ? 'Enabled' : 'Disabled',
      Switch(
        value: currentMode == ThemeMode.dark,
        onChanged: (v) {
          ref.read(themeProvider.notifier).toggle(v);
        },
        activeThumbColor: const Color(0xFF8B5CF6),
        activeTrackColor: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, WidgetRef ref, String currentCurrency) {
    return _buildSettingTile(
      Icons.currency_exchange_rounded, 
      'Currency', 
      currentCurrency,
      IconButton(
        icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white38),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF1E1E1E),
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: ['INR', 'USD', 'EUR', 'GBP'].map((c) => ListTile(
                title: Text(c, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  ref.read(currencyProvider.notifier).setCurrency(c);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: Text('Settings', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6), letterSpacing: 1.2)),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, Widget? trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GlassContainer(
        blur: 15,
        opacity: 0.05,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          leading: Icon(icon, color: Colors.white70),
          title: Text(title, style: GoogleFonts.manrope(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: GoogleFonts.manrope(color: Colors.white38, fontSize: 12)),
          trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthService authService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: TextButton(
        onPressed: () async {
          await authService.signOut();
          if (context.mounted) Navigator.pop(context);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Text('Sign Out Account', style: GoogleFonts.manrope(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text('PayMint v1.0.0', style: GoogleFonts.manrope(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      bottom: -50,
      left: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [const Color(0xFF8B5CF6).withValues(alpha: 0.1), const Color(0xFF8B5CF6).withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
