import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class AddTechnicianScreen extends StatefulWidget {
  const AddTechnicianScreen({super.key});

  @override
  State<AddTechnicianScreen> createState() => _AddTechnicianScreenState();
}

class _AddTechnicianScreenState extends State<AddTechnicianScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs mis à jour
  final _nameController = TextEditingController();      // Nom
  final _firstNameController = TextEditingController(); // Prénom (Nouveau)
  final _phoneController = TextEditingController();     // Téléphone (Nouveau)
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Appel du service avec TOUS les paramètres requis
      await AuthService().adminCreateTechnician(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        username: _nameController.text.trim(),   // Nom
        prenom: _firstNameController.text.trim(), // Prénom
        telephone: _phoneController.text.trim(),   // Téléphone
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Technicien ajouté avec succès"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: Text("Nouveau Technicien", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_add_alt_1_rounded,
                          size: 40, color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Créer un profil complet",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- FORMULAIRE ---
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: "Nom",
                        icon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _firstNameController,
                        label: "Prénom",
                        icon: Icons.badge_outlined,
                        validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: "Téléphone",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: "Adresse Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => !v!.contains('@') ? "Email invalide" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passController,
                        label: "Mot de passe",
                        icon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        validator: (v) => v!.length < 6 ? "Minimum 6 caractères" : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- BOUTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text("CRÉER LE TECHNICIEN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}