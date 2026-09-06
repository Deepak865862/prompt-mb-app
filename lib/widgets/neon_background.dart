import 'package:flutter/material.dart';
import '../config/theme.dart';

class NeonBackground extends StatelessWidget {
  final Widget child;

  const NeonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        // Deep dark background with a subtle neon gradient glow
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBg,
            Color(0xFF1A0B2E), // Dark purple tint
            AppTheme.darkBg,
          ],
        ),
      ),
      child: child,
    );
  }
}
