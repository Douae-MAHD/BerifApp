import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/travail.dart';
import '../../services/suivi_service.dart';
import '../shared/pdf_viewer_page.dart';

class SuiviTravailScreen extends StatefulWidget {
  final Travail travail;

  const SuiviTravailScreen({super.key, required this.travail});

  @override
  State<SuiviTravailScreen> createState() => _SuiviTravailScreenState();
}

class _SuiviTravailScreenState extends State<SuiviTravailScreen> {
  late int currentStatus;
  final SuiviService _suiviService = SuiviService();
  String? _localPdfPath;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialisation du statut local au démarrage
    if (widget.travail.statut == 'termine') {
      currentStatus = 3;
    } else if (widget.travail.statut == 'en_cours') {
      currentStatus = 2;
    } else {
      currentStatus = 1;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // --- LOGIQUE MÉTIER ---

  void _changerStatutLocal(int step) {
    setState(() {
      currentStatus = step;
    });
  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une remarque"),
        content: TextField(
          controller: _notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Saisissez les détails de l'intervention...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  void _enregistrerIntervention() async {
    String nouveauStatutStr = "en_attente";
    if (currentStatus == 2) nouveauStatutStr = "en_cours";
    if (currentStatus == 3) nouveauStatutStr = "termine";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _suiviService.mettreAJourStatut(
        travailId: widget.travail.id!,
        nouveauStatut: nouveauStatutStr,
        commentaire: _notesController.text.isEmpty
            ? "Mise à jour statut : $nouveauStatutStr"
            : _notesController.text,
        equipeId: widget.travail.equipeId ?? "Non assignée",
        localPath: _localPdfPath,
      );

      if (!mounted) return;
      Navigator.pop(context); // Fermer le spinner

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Intervention enregistrée avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'enregistrement : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _localPdfPath = result.files.single.path;
      });
    }
  }

  // --- INTERFACE (UI) ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String dateLabel = widget.travail.datePlanifiee != null
        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(widget.travail.datePlanifiee!)
        : "Date non définie";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("Suivi d'intervention"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(colorScheme, dateLabel),
            const SizedBox(height: 24),
            _buildProgressionSection(colorScheme),
            const SizedBox(height: 24),
            _buildSectionHeader("Notes & Remarques"),
            _buildNotesCard(colorScheme),
            const SizedBox(height: 24),
            _buildSectionHeader("Documents attachés"),
            _buildPdfSection(colorScheme),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: _enregistrerIntervention,
                icon: const Icon(Icons.save),
                label: const Text("ENREGISTRER L'INTERVENTION"),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE COMPOSANTS ---

  Widget _buildInfoCard(ColorScheme colorScheme, String dateLabel) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.red.shade50, child: const Icon(Icons.business, color: Colors.red)),
                const SizedBox(width: 15),
                Expanded(child: Text(widget.travail.commentaire, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(height: 30),
            _buildDetailRow(Icons.settings, "Type", widget.travail.typeId),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.calendar_today, "Prévu le", dateLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionSection(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Sélectionner l'état actuel", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStep(1, "En attente", currentStatus >= 1),
                _buildConnector(currentStatus >= 2),
                _buildStep(2, "En cours", currentStatus >= 2),
                _buildConnector(currentStatus >= 3),
                _buildStep(3, "Terminé", currentStatus >= 3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive) {
    return InkWell(
      onTap: () => _changerStatutLocal(number),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isActive ? Colors.blue.shade600 : Colors.grey.shade300,
            child: Text("$number", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20), color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
    );
  }

  Widget _buildPdfSection(ColorScheme colorScheme) {
    return Column(
      children: [
        if (_localPdfPath != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("PDF prêt à l'envoi"),
              subtitle: const Text("Appuyer pour visualiser"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PDFViewerPage(path: _localPdfPath!))),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _pickPDF,
          icon: const Icon(Icons.upload_file),
          label: const Text("JOINDRE UN RAPPORT PDF"),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }

  Widget _buildNotesCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: ListTile(
        leading: Icon(
            Icons.edit_note,
            color: _notesController.text.isEmpty ? Colors.blue : Colors.green
        ),
        title: Text(
            _notesController.text.isEmpty
                ? "Ajouter une remarque"
                : "Remarque ajoutée",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
        ),
        subtitle: _notesController.text.isNotEmpty
            ? Text(_notesController.text, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: _showNotesDialog,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5, top: 10),
      child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}