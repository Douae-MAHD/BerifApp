import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_provider.dart'; // Import crucial pour selectedMonthProvider et monthlyStatsProvider

void showAdminYearModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // Permet de voir l'arrondi du container
    builder: (_) => const _YearCalendarModal(),
  );
}

class _YearCalendarModal extends ConsumerWidget {
  const _YearCalendarModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> months = [
      "Jan", "Fév", "Mar", "Avr", "Mai", "Juin",
      "Juil", "Août", "Sept", "Oct", "Nov", "Déc"
    ];

    // 1. On écoute les statistiques projetées (calculées dans client_provider.dart)
    final monthlyStats = ref.watch(monthlyStatsProvider);

    // 2. On écoute le mois actuellement sélectionné
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Barre de drag supérieure
          const SizedBox(height: 12),
          Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)
              )
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                    "Calendrier Annuel",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3142)
                    )
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.black)
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, i) {
                final monthIndex = i + 1;

                // Récupération des données du mois (avec fallback si vide)
                final data = monthlyStats[monthIndex] ?? {
                  'clients': <String>{},
                  'travaux': 0,
                  'statut': 'termine'
                };

                // Logique de couleur du point de statut
                Color statusColor = const Color(0xFF388E3C); // Vert (Terminé)
                if (data['statut'] == 'non_assigne') {
                  statusColor = const Color(0xFFD32F2F); // Rouge
                } else if (data['statut'] == 'assigne') {
                  statusColor = const Color(0xFFF57C00); // Orange
                }

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + (i * 30)),
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: GestureDetector(
                      onTap: () {
                        // MISE À JOUR DU MOIS ET FERMETURE
                        ref.read(selectedMonthProvider.notifier).state = monthIndex;
                        Navigator.pop(context);
                      },
                      child: _MonthCard(
                        name: months[i],
                        isCurrent: monthIndex == selectedMonth,
                        // On compte les clients uniques dans le Set
                        clientCount: (data['clients'] as Set).length.toString(),
                        travauxCount: data['travaux'].toString(),
                        statusColor: statusColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final String name;
  final bool isCurrent;
  final String clientCount;
  final String travauxCount;
  final Color statusColor;

  const _MonthCard({
    required this.name,
    required this.isCurrent,
    required this.clientCount,
    required this.travauxCount,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.white : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isCurrent ? const Color(0xFFD32F2F) : Colors.transparent,
            width: 2
        ),
        boxShadow: [
          BoxShadow(
              color: isCurrent
                  ? const Color(0xFFD32F2F).withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5)
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              name,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isCurrent ? const Color(0xFFD32F2F) : const Color(0xFF2D3142)
              )
          ),
          const SizedBox(height: 8),
          _smallInfo(Icons.people_alt_rounded, clientCount),
          const SizedBox(height: 4),
          _smallInfo(Icons.assignment_rounded, travauxCount),
          const SizedBox(height: 10),
          // Point indicateur de statut
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: statusColor.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1
                  )
                ]
            ),
          )
        ],
      ),
    );
  }

  Widget _smallInfo(IconData icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
            value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600
            )
        ),
      ],
    );
  }
}