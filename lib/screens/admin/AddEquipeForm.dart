import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Modèles
import '../../models/equipe.dart';
import '../../models/technicien.dart';
import '../../models/affectation.dart';

// Providers & Services
import '../../providers/equipe_provider.dart';

class AddEquipeForm extends ConsumerStatefulWidget {
  final Equipe? equipe; // Si non nul = Mode Édition
  const AddEquipeForm({super.key, this.equipe});

  @override
  ConsumerState<AddEquipeForm> createState() => _AddEquipeFormState();
}

class _AddEquipeFormState extends ConsumerState<AddEquipeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _focusedField = "";
  List<String> _selectedTechIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.equipe != null) {
      _nameController.text = widget.equipe!.nomEquipe;
      // Charger les membres actuels de l'équipe pour les pré-cocher
      _loadCurrentMembers();
    }
  }

  void _loadCurrentMembers() async {
    // On attend que le premier frame soit dessiné pour utiliser ref
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final membres = await ref.read(membresEquipeProvider(widget.equipe!.id!).future);
      setState(() {
        _selectedTechIds = membres.map((m) => m.id!).toList();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final techsAsync = ref.watch(allTechniciensProvider);
    final bool isEditing = widget.equipe != null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, -10))
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Barre de drag
              Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEditing ? "Modifier l'Équipe" : "Nouvelle Équipe",
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      const SizedBox(height: 30),

                      // --- CHAMP NOM DE L'ÉQUIPE ---
                      _buildPremiumField(
                          "nom",
                          "Nom de l'équipe (ex: Équipe Nord)",
                          _nameController,
                          Icons.badge_rounded
                      ),

                      const SizedBox(height: 25),
                      Text("SÉLECTIONNER LES TECHNICIENS",
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5)),
                      const SizedBox(height: 15),

                      // --- LISTE DES TECHNICIENS (MULTI-SÉLECTION) ---
                      techsAsync.when(
                        data: (techs) {
                          if (techs.isEmpty) return const Text("Aucun technicien créé.");
                          return Column(
                            children: techs.map((tech) => _buildTechSelectionCard(tech)).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text("Erreur : $e"),
                      ),

                      const SizedBox(height: 40),
                      _buildSubmitButton(isEditing),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE DESIGN ---

  Widget _buildPremiumField(String id, String label, TextEditingController controller, IconData icon) {
    bool isFocused = _focusedField == id;
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focusedField = hasFocus ? id : ""),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [if (isFocused) BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.12), blurRadius: 15, spreadRadius: 2)],
        ),
        child: TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: isFocused ? const Color(0xFFD32F2F) : Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: isFocused ? const Color(0xFFD32F2F) : Colors.grey.shade400),
            filled: true,
            fillColor: isFocused ? Colors.white : Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2)),
          ),
          validator: (val) => val!.isEmpty ? "Champ requis" : null,
        ),
      ),
    );
  }

  Widget _buildTechSelectionCard(Technicien tech) {
    bool isSelected = _selectedTechIds.contains(tech.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD32F2F).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
      ),
      child: CheckboxListTile(
        value: isSelected,
        activeColor: const Color(0xFFD32F2F),
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: Text("${tech.prenom} ${tech.nom}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(tech.specialite, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        secondary: CircleAvatar(
          backgroundColor: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade100,
          child: Icon(Icons.person, color: isSelected ? Colors.white : Colors.grey),
        ),
        onChanged: (bool? value) {
          HapticFeedback.lightImpact();
          setState(() {
            if (value == true) {
              _selectedTechIds.add(tech.id!);
            } else {
              _selectedTechIds.remove(tech.id);
            }
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)]),
        boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          _submit();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
        child: Text(isEditing ? "METTRE À JOUR L'ÉQUIPE" : "CONFIRMER LA CRÉATION",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  // --- LOGIQUE CRUD ---

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTechIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sélectionnez au moins un technicien"), backgroundColor: Colors.orange));
        return;
      }

      final equipeService = ref.read(equipeServiceProvider);
      final affectationService = ref.read(affectationServiceProvider);

      String equipeId;

      if (widget.equipe != null) {
        // 🔹 UPDATE
        equipeId = widget.equipe!.id!;
        await equipeService.updateEquipe(equipeId, {'nom_equipe': _nameController.text});
        // On nettoie les anciennes affectations avant de remettre les nouvelles
        await affectationService.removeAllAffectationsByEquipe(equipeId);
      } else {
        // 🔹 CREATE
        final newEquipe = Equipe(id: null, nomEquipe: _nameController.text, disponibilite: true);
        equipeId = await equipeService.addEquipe(newEquipe);
      }

      // 🔹 CRÉATION DES AFFECTATIONS
      for (String techId in _selectedTechIds) {
        await affectationService.addAffectation(Affectation(
          id: '', // Firestore génère l'ID
          equipeId: equipeId,
          technicienId: techId,
          dateAffectation: DateTime.now(),
        ));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.equipe != null ? "Équipe mise à jour" : "Équipe créée avec succès"), backgroundColor: Colors.green),
        );
      }
    }
  }
}