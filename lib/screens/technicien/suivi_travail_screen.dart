import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../models/travail.dart';
import '../../services/suivi_service.dart';

class SuiviTravailScreen extends StatefulWidget {
  final Travail travail;
  const SuiviTravailScreen({super.key, required this.travail});

  @override
  State<SuiviTravailScreen> createState() => _SuiviTravailScreenState();
}

class _SuiviTravailScreenState extends State<SuiviTravailScreen> {
  late int currentStatus;
  final SuiviService _suiviService = SuiviService();
  final String _baseUrl = 'http://10.20.60.149:8000'; // Ton IP PC

  String? _localPdfPath;
  Map<String, dynamic>? resultAnalyse;
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
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

  void _changerStatutLocal(int step) => setState(() => currentStatus = step);

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une remarque"),
        content: TextField(
          controller: _notesController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: "Détails de l'intervention...", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          FilledButton(onPressed: () { setState(() {}); Navigator.pop(context); }, child: const Text("Valider")),
        ],
      ),
    );
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) setState(() => _localPdfPath = result.files.single.path);
  }

  // ✅ APPEL IA CORRIGÉ
  Future<Map<String, dynamic>> analyzePdf(String localPath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/analyze'));
      request.files.add(await http.MultipartFile.fromPath('indices_pdf', localPath));
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        return jsonDecode(respStr);
      } else {
        throw Exception('Erreur serveur IA ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion IA');
    }
  }

  void _enregistrerIntervention() async {
    String nouveauStatutStr = currentStatus == 3 ? "termine" : (currentStatus == 2 ? "en_cours" : "en_attente");

    setState(() => _isProcessing = true);
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)));

    try {
      Map<String, dynamic>? analyseResult;

      // 1. Analyse IA (unique appel)
      if (_localPdfPath != null) {
        analyseResult = await analyzePdf(_localPdfPath!);
      }

      // 2. Mise à jour Service avec le résultat passé en paramètre
      await _suiviService.mettreAJourStatut(
        travailId: widget.travail.id!,
        nouveauStatut: nouveauStatutStr,
        commentaire: _notesController.text.isEmpty ? "Mise à jour statut : $nouveauStatutStr" : _notesController.text,
        equipeId: widget.travail.equipeId ?? "Non assignée",
        localPath: _localPdfPath,
        analyseResult: analyseResult, // ✅ TRANSMISSION DU RÉSULTAT
      );

      if (!mounted) return;
      Navigator.pop(context); // Fermer loader

      setState(() {
        resultAnalyse = analyseResult;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Enregistré avec succès !"), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String dateLabel = widget.travail.datePlanifiee != null ? DateFormat('dd MMMM yyyy', 'fr_FR').format(widget.travail.datePlanifiee!) : "Date non définie";

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
            const SizedBox(height: 24),
            if (resultAnalyse != null) _buildAnalyseResult(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _enregistrerIntervention,
                icon: const Icon(Icons.save),
                label: Text(_isProcessing ? "ENREGISTREMENT..." : "ENREGISTRER L'INTERVENTION"),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS UI GARDÉS À L'IDENTIQUE ---

  Widget _buildAnalyseResult() {
    final details = resultAnalyse?['details'] ?? [];
    final bool isConforme = resultAnalyse?['resultat_global'] == "Conforme";
    return Card(
      elevation: 0,
      color: isConforme ? Colors.green.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isConforme ? Colors.green.shade200 : Colors.red.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Résultat IA : ${resultAnalyse?['resultat_global']}", style: TextStyle(fontWeight: FontWeight.bold, color: isConforme ? Colors.green.shade900 : Colors.red.shade900)),
            const Divider(),
            ...List.generate(details.length, (i) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text("• ${details[i]['indice']}: ${details[i]['statut']}", style: const TextStyle(fontSize: 12)))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme cs, String dl) => Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)), child: Padding(padding: const EdgeInsets.all(20.0), child: Column(children: [Row(children: [CircleAvatar(backgroundColor: Colors.red.shade50, child: const Icon(Icons.business, color: Colors.red)), const SizedBox(width: 15), Expanded(child: Text(widget.travail.commentaire, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)))]), const Divider(height: 30), _buildDetailRow(Icons.settings, "Type", widget.travail.typeId), const SizedBox(height: 10), _buildDetailRow(Icons.calendar_today, "Prévu le", dl)])));
  Widget _buildProgressionSection(ColorScheme cs) => Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)), child: Padding(padding: const EdgeInsets.all(20.0), child: Column(children: [const Text("Sélectionner l'état actuel", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStep(1, "En attente", currentStatus >= 1), _buildConnector(currentStatus >= 2), _buildStep(2, "En cours", currentStatus >= 2), _buildConnector(currentStatus >= 3), _buildStep(3, "Terminé", currentStatus >= 3)])])));
  Widget _buildStep(int n, String l, bool a) => InkWell(onTap: () => _changerStatutLocal(n), child: Column(children: [CircleAvatar(radius: 18, backgroundColor: a ? Colors.blue.shade600 : Colors.grey.shade300, child: Text("$n", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(height: 5), Text(l, style: TextStyle(fontSize: 10, color: a ? Colors.black : Colors.grey))]));
  Widget _buildConnector(bool a) => Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20), color: a ? Colors.blue.shade600 : Colors.grey.shade300));
  Widget _buildPdfSection(ColorScheme cs) => Column(children: [if (_localPdfPath != null) Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: ListTile(leading: const Icon(Icons.picture_as_pdf, color: Colors.red), title: const Text("PDF prêt à l'envoi"), subtitle: Text(p.basename(_localPdfPath!)), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _localPdfPath = null)))), OutlinedButton.icon(onPressed: _pickPDF, icon: const Icon(Icons.upload_file), label: const Text("JOINDRE UN RAPPORT PDF"), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))]);
  Widget _buildNotesCard(ColorScheme cs) => Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)), child: ListTile(leading: Icon(Icons.edit_note, color: _notesController.text.isEmpty ? Colors.blue : Colors.green), title: Text(_notesController.text.isEmpty ? "Ajouter une remarque" : "Remarque ajoutée", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), subtitle: _notesController.text.isNotEmpty ? Text(_notesController.text, maxLines: 1, overflow: TextOverflow.ellipsis) : null, trailing: const Icon(Icons.chevron_right), onTap: _showNotesDialog));
  Widget _buildDetailRow(IconData i, String l, String v) => Row(children: [Icon(i, size: 18, color: Colors.grey), const SizedBox(width: 10), Text("$l: ", style: const TextStyle(color: Colors.grey, fontSize: 13)), Text(v, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))]);
  Widget _buildSectionHeader(String t) => Padding(padding: const EdgeInsets.only(bottom: 10, left: 5, top: 10), child: Text(t, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)));
}