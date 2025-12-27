import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';

class AddClientForm extends ConsumerStatefulWidget {
  final Client? client;
  const AddClientForm({super.key, this.client});

  @override
  ConsumerState<AddClientForm> createState() => _AddClientFormState();
}

class _AddClientFormState extends ConsumerState<AddClientForm> {
  final _formKey = GlobalKey<FormState>();
  String _focusedField = "";

  late TextEditingController _nomController;
  late TextEditingController _adresseController;
  late TextEditingController _villeController;
  late TextEditingController _telController;
  late TextEditingController _emailController;
  late TextEditingController _secteurController;

  String _typeContrat = "12 mois";
  DateTime _dateDebut = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.client?.nomClient);
    _adresseController = TextEditingController(text: widget.client?.adresse);
    _villeController = TextEditingController(text: widget.client?.ville);
    _telController = TextEditingController(text: widget.client?.telephone);
    _emailController = TextEditingController(text: widget.client?.email);
    _secteurController = TextEditingController(text: widget.client?.secteur);

    if (widget.client != null) {
      _typeContrat = widget.client!.typeContrat;
      _dateDebut = widget.client!.dateDebutContrat ?? DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.client != null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, -10))
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEditing ? "Modifier le Contrat" : "Nouveau Contrat",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      const SizedBox(height: 35),

                      _buildSectionTitle("INFORMATIONS GÉNÉRALES"),
                      const SizedBox(height: 15),
                      _buildPremiumField("nom", "Nom du client", _nomController, Icons.business_rounded),
                      _buildPremiumField("secteur", "Secteur d'activité", _secteurController, Icons.category_rounded),
                      _buildPremiumField("adresse", "Adresse", _adresseController, Icons.location_on_rounded),
                      _buildPremiumField("ville", "Ville", _villeController, Icons.map_rounded),

                      const SizedBox(height: 15),
                      _buildSectionTitle("PÉRIODICITÉ DE MAINTENANCE"),
                      const SizedBox(height: 15),
                      _buildSlidingSelector(),

                      const SizedBox(height: 30),
                      _buildSectionTitle("DÉBUT DE CONTRAT"),
                      const SizedBox(height: 15),
                      _buildPremiumDatePickerTrigger(), // Déclenche le calendrier standard

                      const SizedBox(height: 30),
                      _buildSectionTitle("COORDONNÉES DE CONTACT"),
                      const SizedBox(height: 15),
                      _buildPremiumField("tel", "Téléphone", _telController, Icons.phone_iphone_rounded, keyboard: TextInputType.phone),
                      _buildPremiumField("email", "Email professionnel", _emailController, Icons.alternate_email_rounded, keyboard: TextInputType.emailAddress),

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

  // --- BOUTON DÉCLENCHEUR DU CALENDRIER STANDARD ---
  Widget _buildPremiumDatePickerTrigger() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _selectDate(context); // Appelle showDatePicker
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFD32F2F), size: 20),
            ),
            const SizedBox(width: 15),
            Text(
              DateFormat('dd MMMM yyyy', 'fr_FR').format(_dateDebut).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF2D3142)),
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // --- FONCTION POUR LE CALENDRIER STANDARD (Personnalisé Rouge) ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F), // Couleur du cercle de sélection
              onPrimary: Colors.white,   // Couleur du texte sur le cercle
              onSurface: Color(0xFF2D3142), // Couleur du texte des jours
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)), // Couleur des boutons OK/ANNULER
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateDebut) {
      setState(() {
        _dateDebut = picked;
      });
    }
  }

  // --- RESTE DU CODE (SÉLECTEUR COULISSANT ET CHAMPS) ---

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5));
  }

  Widget _buildSlidingSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: _typeContrat == "6 mois" ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 64) / 2,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
            ),
          ),
          Row(
            children: [
              _buildSelectorItem("6 Mois", "6 mois"),
              _buildSelectorItem("12 Mois", "12 mois"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorItem(String label, String value) {
    bool isSelected = _typeContrat == value;
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); setState(() => _typeContrat = value); },
        behavior: HitTestBehavior.opaque,
        child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isSelected ? const Color(0xFFD32F2F) : Colors.grey))),
      ),
    );
  }

  Widget _buildPremiumField(String fieldId, String label, TextEditingController controller, IconData icon, {TextInputType? keyboard}) {
    bool isFocused = _focusedField == fieldId;
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focusedField = hasFocus ? fieldId : ""),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [if (isFocused) BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.12), blurRadius: 15, spreadRadius: 2)]),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: isFocused ? const Color(0xFFD32F2F) : Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: isFocused ? const Color(0xFFD32F2F) : Colors.grey.shade400, size: 22),
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

  Widget _buildSubmitButton(bool isEditing) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: () { HapticFeedback.heavyImpact(); _submit(); },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
        child: Text(isEditing ? "METTRE À JOUR LE DOSSIER" : "CONFIRMER L'ENREGISTREMENT", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final clientData = Client(
        id: widget.client?.id,
        nomClient: _nomController.text,
        adresse: _adresseController.text,
        ville: _villeController.text,
        telephone: _telController.text,
        email: _emailController.text,
        typeContrat: _typeContrat,
        dateDebutContrat: _dateDebut,
        periodiciteMaintenance: _typeContrat == "6 mois" ? "Semestrielle" : "Annuelle",
        secteur: _secteurController.text,
      );

      if (widget.client != null) {
        await ref.read(clientServiceProvider).updateClient(widget.client!.id!, clientData.toMap());
      } else {
        await ref.read(clientServiceProvider).addClient(clientData);
      }
      Navigator.pop(context);
    }
  }
}