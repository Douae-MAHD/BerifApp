import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/travail.dart';
import '../../providers/client_provider.dart';
import '../../providers/travail_provider.dart';
import '../../providers/equipe_provider.dart';

class AddTravailForm extends ConsumerStatefulWidget {
  final Travail? travail; // ✅ Si nul = Ajout, si non-nul = Modification
  const AddTravailForm({super.key, this.travail});

  @override
  ConsumerState<AddTravailForm> createState() => _AddTravailFormState();
}

class _AddTravailFormState extends ConsumerState<AddTravailForm> {
  final _formKey = GlobalKey<FormState>();
  String _focusedField = "";

  // État du formulaire
  String? _selectedClientId;
  String? _selectedTypeId;
  String? _selectedEquipeId;
  DateTime _datePlanifiee = DateTime.now();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Initialisation en mode ÉDITION
    if (widget.travail != null) {
      _selectedClientId = widget.travail!.clientId;
      _selectedTypeId = widget.travail!.typeId;
      _selectedEquipeId = widget.travail!.equipeId;
      _datePlanifiee = widget.travail!.datePlanifiee ?? DateTime.now();
      _commentController.text = widget.travail!.commentaire;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(allClientsProvider);
    final typesAsync = ref.watch(allTypesProvider);
    final equipesAsync = ref.watch(allEquipesProvider);

    final bool isEditing = widget.travail != null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, -10))
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.withAlpha(80), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEditing ? "Modifier la mission" : "Planifier une mission",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Color(0xFF1A1D21))),
                      const SizedBox(height: 30),

                      // 1. CLIENT
                      clientsAsync.when(
                        data: (list) => _buildPremiumDropdown(
                          id: "client",
                          label: "Client",
                          value: _selectedClientId,
                          items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nomClient))).toList(),
                          onChanged: (val) => setState(() => _selectedClientId = val),
                          icon: Icons.business_rounded,
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text("Erreur clients"),
                      ),

                      // 2. TYPE DE TRAVAIL
                      typesAsync.when(
                        data: (list) => _buildPremiumDropdown(
                          id: "type",
                          label: "Nature de l'intervention",
                          value: _selectedTypeId,
                          items: list.map((t) => DropdownMenuItem(value: t.nomType, child: Text(t.nomType))).toList(),
                          onChanged: (val) => setState(() => _selectedTypeId = val),
                          icon: Icons.construction_rounded,
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const Text("Erreur types"),
                      ),

                      // 3. ÉQUIPE (OBLIGATOIRE)
                      equipesAsync.when(
                        data: (list) => _buildPremiumDropdown(
                          id: "equipe",
                          label: "Équipe assignée",
                          value: _selectedEquipeId,
                          items: list.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nomEquipe))).toList(),
                          onChanged: (val) => setState(() => _selectedEquipeId = val),
                          icon: Icons.groups_rounded,
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const Text("Erreur équipes"),
                      ),

                      // 4. DATE
                      _buildPremiumDatePickerTrigger(),
                      const SizedBox(height: 18),

                      // 5. COMMENTAIRES
                      _buildPremiumField("notes", "Instructions de mission", _commentController, Icons.chat_bubble_outline_rounded, maxLines: 3),

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

  // --- COMPOSANTS UI ---

  Widget _buildPremiumDropdown({
    required String id,
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    bool isFocused = _focusedField == id;
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focusedField = hasFocus ? id : ""),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [if (isFocused) BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.1), blurRadius: 15, spreadRadius: 1)],
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: (val) => val == null ? "Champ requis" : null,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(22),
          icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
          style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: isFocused ? const Color(0xFFD32F2F) : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: isFocused ? const Color(0xFFD32F2F) : Colors.grey.shade400, size: 22),
            filled: true,
            fillColor: isFocused ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.8)),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumField(String fieldId, String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    bool isFocused = _focusedField == fieldId;
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focusedField = hasFocus ? fieldId : ""),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: isFocused ? const Color(0xFFD32F2F) : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: isFocused ? const Color(0xFFD32F2F) : Colors.grey.shade400, size: 22),
            filled: true,
            fillColor: isFocused ? Colors.white : Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.8)),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumDatePickerTrigger() {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); _selectDate(context); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Color(0xFFD32F2F), size: 22),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("DATE PRÉVUE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(_datePlanifiee),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF2D3142))),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _datePlanifiee,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _datePlanifiee = picked);
  }

  Widget _buildSubmitButton(bool isEditing) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)]),
        boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: () { HapticFeedback.heavyImpact(); _submit(); },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        child: Text(isEditing ? "METTRE À JOUR LA MISSION" : "CONFIRMER LA MISSION",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
      ),
    );
  }

  // --- LOGIQUE CRUD ---

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClientId == null || _selectedTypeId == null || _selectedEquipeId == null) return;

      final travailData = Travail(
        id: widget.travail?.id,
        clientId: _selectedClientId!,
        typeId: _selectedTypeId!,
        equipeId: _selectedEquipeId!,
        commentaire: _commentController.text,
        datePlanifiee: _datePlanifiee,
        dateRealisation: widget.travail?.dateRealisation,
        statut: widget.travail?.statut ?? 'en_attente',
      );

      if (widget.travail != null) {
        // ✅ UPDATE (Mise à jour)
        await ref.read(travailServiceProvider).updateTravail(widget.travail!.id!, travailData.toMap());
      } else {
        // ✅ CREATE (Création)
        await ref.read(travailServiceProvider).addTravail(travailData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.travail != null ? "Mission mise à jour" : "Mission créée"),
                backgroundColor: Colors.green
            )
        );
      }
    }
  }
}