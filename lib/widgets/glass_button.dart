import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final Widget? customIcon;
  final Color? color;
  final List<Color>? gradientColors;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.customIcon,
    this.color,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: GlassContainer(
        blur: 20,
        opacity: gradientColors != null ? 1.0 : (color != null ? 0.2 : 0.1),
        gradient: gradientColors != null 
          ? LinearGradient(colors: gradientColors!) 
          : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.fromBorderSide(
          BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (customIcon != null) ...[
                customIcon!,
                const SizedBox(width: 12),
              ] else if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 12),
              ],
              Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
