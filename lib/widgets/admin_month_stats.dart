import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Pour le nom du mois
import '../providers/client_provider.dart'; // Import pour les nouveaux providers
import 'admin_year_modal.dart';

class AdminMonthStats extends ConsumerStatefulWidget {
  const AdminMonthStats({super.key});

  @override
  ConsumerState<AdminMonthStats> createState() => _AdminMonthStatsState();
}

class _AdminMonthStatsState extends ConsumerState<AdminMonthStats> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 1. On écoute le mois sélectionné (1-12)
    final selectedMonth = ref.watch(selectedMonthProvider);

    // 2. On écoute les stats filtrées pour ce mois
    final stats = ref.watch(statsForSelectedMonthProvider);

    // 3. On génère le nom du mois dynamiquement (ex: "janvier 2025")
    final String monthName = DateFormat('MMMM yyyy', 'fr_FR')
        .format(DateTime(DateTime.now().year, selectedMonth));

    return GestureDetector(
      onTap: () => showAdminYearModal(context),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              // Header : Affiche le mois sélectionné avec l'icône de déploiement
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      monthName.capitalize(), // Utilise l'extension capitalize en bas
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xFF2D3142),
                      )
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.unfold_more_rounded, size: 18, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 20),
              // Tuiles de statistiques
              Row(
                children: [
                  _StatTile(
                    value: "${stats['total']}",
                    label: "Total",
                    color: Colors.grey.shade100,
                    textColor: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    value: "${stats['non_assigne']}",
                    label: "Non assigné",
                    color: const Color(0xFFFFEBEE),
                    textColor: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    value: "${stats['assigne']}",
                    label: "Assigné",
                    color: const Color(0xFFFFF3E0),
                    textColor: const Color(0xFFF57C00),
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    value: "${stats['termine']}",
                    label: "Terminé",
                    color: const Color(0xFFE8F5E9),
                    textColor: const Color(0xFF388E3C),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor),
            ),
            const SizedBox(height: 2),
            FittedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension pour mettre la première lettre en majuscule (ex: décembre -> Décembre)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}