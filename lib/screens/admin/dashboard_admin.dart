import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/client_provider.dart';
import '../../widgets/admin_client_card.dart';
import '../../widgets/admin_kpi_grid.dart';
import '../../widgets/admin_month_stats.dart';

class DashboardAdminScreen extends ConsumerWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. On écoute le mois sélectionné (celui choisi dans le calendrier)
    final selectedMonth = ref.watch(selectedMonthProvider);

    // 2. On utilise le provider qui filtre les clients selon ce mois sélectionné
    final clientsDueAsync = ref.watch(clientsDueForMonthProvider);

    // 3. On génère le nom du mois à afficher en fonction du mois sélectionné
    final String monthName = DateFormat('MMMM', 'fr_FR')
        .format(DateTime(DateTime.now().year, selectedMonth));

    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFFD32F2F),
        onRefresh: () async {
          // Force le rafraîchissement des données Firebase
          ref.invalidate(allClientsProvider);
          return await ref.read(allClientsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // --- BLOC STATISTIQUES MENSUELLES (Cliquable) ---
            const AdminMonthStats(),
            const SizedBox(height: 24),

            // --- GRILLE DES KPI (Techniciens, Clients, etc.) ---
            const AdminKpiGrid(),
            const SizedBox(height: 32),

            // --- TITRE DYNAMIQUE (Mis à jour selon le mois choisi) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Maintenance de ${StringExtension(monthName).capitalize()}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3142)
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- LISTE DES CLIENTS DU MOIS SÉLECTIONNÉ ---
            clientsDueAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Erreur de chargement : $err", textAlign: TextAlign.center),
                ),
              ),
              data: (clients) {
                if (clients.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.event_available_outlined, size: 50, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          "Aucune maintenance prévue\npour le mois de ${monthName.toLowerCase()}.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                // Affiche les cartes clients filtrées pour le mois sélectionné
                return Column(
                  children: clients.map((c) => AdminClientCard(client: c,isManagementMode: false,)).toList(),
                );
              },
            ),

            // Espace pour ne pas être caché par la bottom navigation bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// Extension PRIVEÉ pour éviter les conflits avec d'autres fichiers
extension _StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}