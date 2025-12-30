import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/travail.dart';
import '../../models/suivi_travail.dart';
import '../../models/client.dart';
import '../../models/equipe.dart';
import '../../providers/client_provider.dart';
import '../../providers/travail_provider.dart';
import '../../providers/equipe_provider.dart';
import '../admin/add_travail_form.dart'; // Import pour la modification

class DetailsTravailScreen extends ConsumerWidget {
  final Travail travail;

  const DetailsTravailScreen({super.key, required this.travail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📡 Données dynamiques
    final suiviAsync = ref.watch(dernierSuiviProvider(travail.id!));
    final clients = ref.watch(allClientsProvider).asData?.value ?? [];
    final equipes = ref.watch(allEquipesProvider).asData?.value ?? [];

    // 🔍 Mapping Client
    final client = clients.firstWhere(
          (c) => c.id == travail.clientId,
      orElse: () => Client(id: travail.clientId, nomClient: "Inconnu", adresse: "", ville: "N/C", telephone: "", email: "", typeContrat: "", periodiciteMaintenance: "", secteur: ""),
    );

    // 🔍 Mapping Equipe
    final equipe = equipes.firstWhere(
          (e) => e.id == travail.equipeId,
      orElse: () => Equipe(id: '', nomEquipe: "Non assignée", disponibilite: true),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Détails de l'intervention",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        // --- BOUTONS D'ACTIONS ---
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () => _showEditForm(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(client, equipe),
            const SizedBox(height: 16),
            _buildProgressionCard(),
            const SizedBox(height: 16),

            // --- PARTIE DYNAMIQUE (REMARQUES + PDF) ---
            suiviAsync.when(
              data: (suivi) => Column(
                children: [
                  _buildTechnicianReportCard(suivi),
                  const SizedBox(height: 16),
                  if (suivi != null && suivi.pdfUrl != null && suivi.pdfUrl!.isNotEmpty)
                    _buildPremiumPdfButton(context, suivi.pdfUrl!),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur : $e")),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIQUE ACTIONS ---

  void _showEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTravailForm(travail: travail),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer la mission ?"),
        content: const Text("Voulez-vous vraiment supprimer ce travail ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(travailServiceProvider).deleteTravail(travail.id!);
              if (context.mounted) {
                Navigator.pop(context); // Fermer dialogue
                Navigator.pop(context); // Retour à la liste
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildHeaderCard(Client client, Equipe equipe) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.business, color: Colors.red)),
            title: Text(client.nomClient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(client.ville, style: const TextStyle(color: Colors.grey)),
            trailing: _badgeStatut(travail.statut),
          ),
          const Divider(height: 30),
          _infoRow(Icons.settings_outlined, "Type d'intervention", travail.typeId),
          _infoRow(Icons.groups_outlined, "Équipe assignée", equipe.nomEquipe),
          _infoRow(Icons.calendar_today_outlined, "Date prévue",
              travail.datePlanifiee != null ? DateFormat('dd MMM yyyy', 'fr_FR').format(travail.datePlanifiee!) : "Non planifiée"),
        ],
      ),
    );
  }

  Widget _buildProgressionCard() {
    int step = travail.statut == 'termine' ? 3 : (travail.statut == 'en_cours' ? 2 : 1);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Réalisation terrain", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepItem("1", "Assigné", step >= 1),
              _stepLine(step >= 2),
              _stepItem("2", "En cours", step >= 2),
              _stepLine(step >= 3),
              _stepItem("3", "Terminé", step >= 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianReportCard(SuiviTravail? suivi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.comment_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              const Text("Rapport du technicien", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              if (suivi != null)
                Text(DateFormat('dd/MM HH:mm').format(suivi.dateSuivi), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suivi?.commentaire ?? "Aucun rapport transmis.",
            style: TextStyle(color: suivi == null ? Colors.grey : Colors.black87, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPdfButton(BuildContext context, String url) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () => _handlePdfOpening(context, url),
        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
        label: const Text("TÉLÉCHARGER LE RAPPORT PDF",
            style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _handlePdfOpening(BuildContext context, String url) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 20),
                  Text("Chargement du document...",
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final Uri uri = Uri.parse(url);
      await Future.delayed(const Duration(seconds: 1));
      if (await canLaunchUrl(uri)) {
        if (context.mounted) Navigator.pop(context);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _badgeStatut(String s) {
    Color col = s == 'termine' ? Colors.green : (s == 'en_cours' ? Colors.blue : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(s.toUpperCase(), style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(IconData i, String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(i, size: 18, color: Colors.grey),
      const SizedBox(width: 12),
      Text("$l : ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _stepItem(String n, String l, bool a) => Column(children: [
    CircleAvatar(
        radius: 14,
        backgroundColor: a ? const Color(0xFF4285F4) : Colors.grey.shade200,
        child: a ? const Icon(Icons.check, size: 14, color: Colors.white) : Text(n, style: const TextStyle(fontSize: 10, color: Colors.grey))
    ),
    const SizedBox(height: 8),
    Text(l, style: TextStyle(fontSize: 10, color: a ? Colors.black : Colors.grey, fontWeight: a ? FontWeight.bold : FontWeight.normal)),
  ]);

  Widget _stepLine(bool a) => Expanded(child: Container(height: 2, color: a ? const Color(0xFF4285F4) : Colors.grey.shade200, margin: const EdgeInsets.only(bottom: 22)));
}