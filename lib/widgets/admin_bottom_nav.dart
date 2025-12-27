import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      height: 85, // Légèrement augmenté pour le texte
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (index) {
          final isActive = currentIndex == index;
          return GestureDetector(
            onTap: () {
              if (!isActive) {
                HapticFeedback.lightImpact();
                onTap(index);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animation de l'icône
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFD32F2F).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _items[index].icon,
                      color: isActive ? const Color(0xFFD32F2F) : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),

                  // Animation du texte (Apparition fluide)
                  AnimatedClipRect(
                    open: isActive,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _items[index].label,
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Un petit widget utilitaire pour animer l'apparition du texte proprement
class AnimatedClipRect extends StatelessWidget {
  final Widget child;
  final bool open;

  const AnimatedClipRect({super.key, required this.child, required this.open});

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.center,
      heightFactor: open ? 1.0 : 0.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: open ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const List<_NavItem> _items = [
  _NavItem(Icons.grid_view_rounded, 'Board'),
  _NavItem(Icons.people_rounded, 'Clients'),
  _NavItem(Icons.assignment_rounded, 'Travaux'),
  _NavItem(Icons.group_work_rounded, 'Équipes'),
  _NavItem(Icons.engineering_rounded, 'Techs'),
];