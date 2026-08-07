import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
class FloatingCreateButton extends StatefulWidget {
  const FloatingCreateButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<FloatingCreateButton> createState() => _FloatingCreateButtonState();
}

class _FloatingCreateButtonState extends State<FloatingCreateButton> {
  bool _pressed = false;

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 60,
        width: 60,
        transform: Matrix4.identity()..scale(_pressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(_pressed ? AppRadius.md : AppRadius.pill),
          boxShadow: AppColors.glow(opacity: _pressed ? 0.2 : 0.45),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}