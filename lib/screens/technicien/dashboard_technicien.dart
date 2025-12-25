import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // ✅ Pour formater les dates
import '../../providers/travail_provider.dart';
import '../../models/travail.dart';
import 'suivi_travail_screen.dart';
class DashboardTechnicien extends ConsumerWidget {
  const DashboardTechnicien({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // 📡 Écoute du flux Firebase
    final travauxAsync = ref.watch(travauxStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Fond gris très léger pour faire ressortir les cartes
      appBar: AppBar(
        title: const Text("Mon Tableau de Bord"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: travauxAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur de connexion : $err")),
        data: (listeTravaux) {
          // 📊 CALCULS DES STATISTIQUES
          final int total = listeTravaux.length;
          final int termines = listeTravaux.where((t) => t.statut == 'termine').length;
          print("📊 Travaux reçus UI: ${listeTravaux.length}");
          for (var t in listeTravaux) {
            print("➡ ${t.commentaire} | statut=${t.statut}");
          }
          // ✅ MODIFICATION : On affiche les travaux En cours ET En attente
          final listAffiche = listeTravaux.where((t) =>
              ['en_cours', 'en_attente'].contains(t.statut)
          ).toList();

          final int performance = total == 0 ? 0 : (termines / total * 100).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECTION PROFIL ---
                _buildProfileHeader(colorScheme, termines, total, performance),
                const SizedBox(height: 24),

                // --- CARTES DE STATISTIQUES ---
                Row(
                  children: [
                    Expanded(child: _buildStatCard("$total", "Total", Icons.work_outline, Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard("$termines", "Terminés", Icons.check_circle_outline, Colors.teal)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard("$performance%", "Perf.", Icons.emoji_events_outlined, Colors.orange)),
                  ],
                ),
                const SizedBox(height: 32),

                // --- TITRE LISTE ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Travaux à réaliser",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${listAffiche.length}",
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- LISTE DYNAMIQUE ---
                if (listAffiche.isEmpty)
                  _buildEmptyState()
                else
                  ...listAffiche.map((travail) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildWorkCard(context, travail),
                  )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget si aucun travail n'est trouvé
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("Aucun travail prévu pour le moment",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Header avec Jauge de progression
  Widget _buildProfileHeader(ColorScheme colorScheme, int termines, int total, int performance) {
    double progress = total == 0 ? 0 : termines / total;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFD32F2F),
                child: Text("JD", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 12),
            Text("Jean Dupont", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
            const Text("Chef d'équipe", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Taux de complétion", style: TextStyle(fontWeight: FontWeight.w500)),
                Text("$performance%", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.red.shade50,
                  color: Colors.red.shade600
              ),
            ),
            const SizedBox(height: 8),
            Text("$termines / $total travaux terminés",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  // Carte de travail individuelle
  Widget _buildWorkCard(BuildContext context, Travail travail) {
    // Formatage de la date (ex: 22 déc. 2025)
    String dateLabel = "Date non définie";
    if (travail.datePlanifiee != null) {
      dateLabel = DateFormat('dd MMM yyyy', 'fr_FR').format(travail.datePlanifiee!);
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                        travail.commentaire ?? "Intervention Maintenance",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    )
                ),
                _buildStatusBadge(travail.statut),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today_outlined, "Prévu le: ", dateLabel),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.label_outline, "Type: ", travail.typeId), // ✅ Utilisation de typeId
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuiviTravailScreen(travail: travail)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Détails de l'intervention"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Badge dynamique selon le statut
  Widget _buildStatusBadge(String statut) {
    Color color;
    String label;

    switch (statut) {
      case 'en_cours':
        color = Colors.blue.shade600;
        label = "EN COURS";
        break;
      case 'en_attente':
        color = Colors.orange.shade700;
        label = "EN ATTENTE";
        break;
      case 'termine':
        color = Colors.teal;
        label = "TERMINÉ";
        break;
      default:
        color = Colors.grey;
        label = statut.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey.shade600),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
    ]);
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 12),
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
      ]),
    );
  }
}