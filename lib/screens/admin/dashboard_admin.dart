import 'dart:ui'; // ✅ Obligatoire pour le flou (BackdropFilter)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Assurez-vous d'avoir ajouté google_fonts dans pubspec.yaml
import 'package:intl/intl.dart';
import '../../providers/client_provider.dart';
import '../../services/auth_service.dart'; // ✅ Import de votre service (où se trouve authServiceProvider)
import '../../widgets/admin_client_card.dart';
import '../../widgets/admin_kpi_grid.dart';
import '../../widgets/admin_month_stats.dart';

class DashboardAdminScreen extends ConsumerWidget {
  const DashboardAdminScreen({super.key});

  // Méthode de déconnexion centralisée
  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment quitter l'application ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authServiceProvider).logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final clientsDueAsync = ref.watch(clientsDueForMonthProvider);

    final String monthName = DateFormat('MMMM', 'fr_FR')
        .format(DateTime(DateTime.now().year, selectedMonth));

    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Permet au contenu de passer sous l'AppBar floutée
      backgroundColor: const Color(0xFFF8F9FA), // Un gris très léger pour le fond
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7), // Transparent avec opacité
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Effet de flou moderne
            child: Container(color: Colors.transparent),
          ),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tableau de Bord",
              style: GoogleFonts.poppins(
                color: const Color(0xFF2D3142),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 22),
              onPressed: () => _handleLogout(context, ref),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        displacement: 100, // Pour que l'indicateur apparaisse sous l'AppBar
        color: const Color(0xFFD32F2F),
        onRefresh: () async {
          ref.invalidate(allClientsProvider);
          return await ref.read(allClientsProvider.future);
        },
        child: ListView(
          // ✅ Padding top de 100 pour ne pas cacher le début du contenu par l'AppBar
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const AdminMonthStats(),
            const SizedBox(height: 24),
            const AdminKpiGrid(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Maintenance de ${monthName.capitalize()}",
                style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D3142)
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  child: Text("Erreur : $err", textAlign: TextAlign.center),
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
                          "Aucune maintenance prévue pour ${monthName.toLowerCase()}.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: clients.map((c) => AdminClientCard(client: c, isManagementMode: false)).toList(),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
