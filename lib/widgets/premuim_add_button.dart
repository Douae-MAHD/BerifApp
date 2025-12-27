import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumAddButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const PremiumAddButton({super.key, required this.onTap, required this.label});

  @override
  State<PremiumAddButton> createState() => _PremiumAddButtonState();
}

class _PremiumAddButtonState extends State<PremiumAddButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Animation de pulsation douce et continue
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.heavyImpact(); // Retour haptique fort
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0, // Effet d'écrasement au clic
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFB71C1C)], // Dégradé rouge vif
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                // Ombre portée éclatante (Halo)
                BoxShadow(
                  color: const Color(0xFFD32F2F).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}