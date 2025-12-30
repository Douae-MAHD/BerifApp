import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/technicien.dart';
import '../../services/technicien_service.dart';

class EditTechnicianScreen extends StatefulWidget {
  final Technicien technicien; // On reçoit le technicien à modifier

  const EditTechnicianScreen({super.key, required this.technicien});

  @override
  State<EditTechnicianScreen> createState() => _EditTechnicianScreenState();
}

class _EditTechnicianScreenState extends State<EditTechnicianScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  final _service = TechnicienService();

  @override
  void initState() {
    super.initState();
    // On pré-remplit les champs avec les données actuelles
    _nameController = TextEditingController(text: widget.technicien.nom);
    _emailController = TextEditingController(text: widget.technicien.email);
  }

  void _update() async {
    setState(() => _isLoading = true);
    try {
      await _service.updateTechnicien(widget.technicien.id, {
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context); // Retour à la liste
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Technicien mis à jour !"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nom complet",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _update,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ENREGISTRER LES MODIFICATIONS"),
              ),
            )
          ],
        ),
      ),
    );
  }
}