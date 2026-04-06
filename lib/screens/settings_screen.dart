import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background System
          Container(color: const Color(0xFF03050C)),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    const Color(0xFF8B5CF6).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(context),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Preferences'),
                    _buildSettingTile(Icons.notifications_active_rounded, 'Push Notifications', 'Manage alerts and reminders', true),
                    _buildSettingTile(Icons.currency_exchange_rounded, 'Currency', 'USD (\$)', false),
                    _buildSettingTile(Icons.dark_mode_rounded, 'Theme', 'System (Dark)', false),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Support'),
                    _buildSettingTile(Icons.help_outline_rounded, 'Help Center', 'FAQs and troubleshooting', false),
                    _buildSettingTile(Icons.security_rounded, 'Privacy Policy', 'How we handle your data', false),
                    const SizedBox(height: 40),
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
        title: Text(
          'Settings',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PayMint User', style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Free Tier Plan', style: GoogleFonts.manrope(color: Colors.white54, fontSize: 13)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.edit_note_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF8B5CF6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, bool isSwitch) {
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
          trailing: isSwitch 
              ? Switch(
                  value: true, 
                  onChanged: (v) {}, 
                  activeThumbColor: const Color(0xFF8B5CF6), // Replaced deprecated activeColor
                  activeTrackColor: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                )
              : const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text('PayMint v1.0.0 (Premium Build)', style: GoogleFonts.manrope(color: Colors.white24, fontSize: 12)),
          const SizedBox(height: 8),
          Text('Designed with ❤️ by Antigravity', style: GoogleFonts.manrope(color: Colors.white10, fontSize: 10)),
        ],
      ),
    );
  }
}
