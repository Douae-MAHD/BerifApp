import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Modèles
import '../../models/equipe.dart';
import '../../models/technicien.dart';

// Providers
import '../../providers/equipe_provider.dart';

// Formulaire
import 'AddEquipeForm.dart';

class GestionEquipesScreen extends ConsumerWidget {
  const GestionEquipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipesAsync = ref.watch(allEquipesProvider);

    // Statistiques pour les KPIs du haut
    final totalEquipes = ref.watch(equipeCountProvider).asData?.value ?? 0;
    final equipesDispo = ref.watch(equipesDisponiblesProvider).asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text("Gestion des Équipes",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- SECTION 1 : KPIs ÉQUIPES ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildKpiSmall(totalEquipes.toString(), "Total", Colors.white, Colors.black),
                _buildKpiSmall(equipesDispo.toString(), "Disponibles", const Color(0xFFE8F5E9), const Color(0xFF43A047)),
                _buildKpiSmall((totalEquipes - equipesDispo).toString(), "Occupées", const Color(0xFFFFF3E0), const Color(0xFFFB8C00)),
              ],
            ),
          ),

          // --- SECTION 2 : LISTE DES ÉQUIPES ---
          Expanded(
            child: equipesAsync.when(
              data: (equipes) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: equipes.length,
                itemBuilder: (context, index) {
                  return _EquipeCard(equipe: equipes[index]);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
              error: (err, _) => Center(child: Text("Erreur : $err")),
            ),
          ),
        ],
      ),

      // --- BOUTON D'AJOUT PREMIUM ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEquipeForm(context, null),
        backgroundColor: const Color(0xFF2D3142),
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: Text("CRÉER UNE ÉQUIPE", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- WIDGETS INTERNES ---

  Widget _buildKpiSmall(String val, String label, Color bg, Color txt) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(val, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: txt)),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: txt.withOpacity(0.7), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showEquipeForm(BuildContext context, Equipe? equipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEquipeForm(equipe: equipe),
    );
  }
}

class _EquipeCard extends ConsumerWidget {
  final Equipe equipe;
  const _EquipeCard({required this.equipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute les membres de CETTE équipe en temps réel
    final membresAsync = ref.watch(membresEquipeProvider(equipe.id!));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 5),
            title: Text(equipe.nomEquipe,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
            subtitle: _buildStatusChip(equipe.disponibilite),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2D3142)),
                  onPressed: () => _showEditForm(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)),
                  onPressed: () => _showDeleteDialog(context, ref),
                ),
              ],
            ),
          ),
          const Divider(indent: 20, endIndent: 20, height: 1),

          // --- LISTE DES MEMBRES ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.engineering_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("MEMBRES DE L'ÉQUIPE",
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 12),
                membresAsync.when(
                  data: (membres) {
                    if (membres.isEmpty) {
                      return Text("Aucun technicien affecté",
                          style: GoogleFonts.poppins(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey));
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: membres.map((m) => _buildTechBadge(m)).toList(),
                    );
                  },
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, __) => const Text("Erreur de chargement"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechBadge(Technicien t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 14, color: Color(0xFF2D3142)),
          const SizedBox(width: 6),
          Text("${t.prenom} ${t.nom}",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D3142))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool dispo) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: dispo ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dispo ? "DISPONIBLE" : "EN MISSION",
        style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: dispo ? const Color(0xFF43A047) : const Color(0xFFE53935)
        ),
      ),
    );
  }

  void _showEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEquipeForm(equipe: equipe),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Supprimer l'équipe ?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Voulez-vous vraiment supprimer l'équipe '${equipe.nomEquipe}' ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              await ref.read(equipeServiceProvider).deleteEquipe(equipe.id!);
              Navigator.pop(context);
            },
            child: const Text("SUPPRIMER", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}