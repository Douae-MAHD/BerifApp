import 'package:flutter/material.dart';
import '../../widgets/custom_input.dart';
import '../../services/auth_service.dart';
import '../../models/utilisateur.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showError("Veuillez remplir tous les champs");
      return;
    }

    setState(() => _isLoading = true);

    try {
      Utilisateur? user = await AuthService().login(
        _emailController.text.trim().toLowerCase(),
        _passController.text.trim(),
      );

      if (user == null) {
        _showError("Compte sans profil utilisateur");
        return;
      }

      final route =
      (user.role == 'admin') ? '/admin_dashboard' : '/tech_dashboard';

      Navigator.pushReplacementNamed(context, route);

    } catch (e) {
      // 🔥 AFFICHAGE DE LA VRAIE ERREUR FIREBASE
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildLogo(),
              const SizedBox(height: 40),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Bienvenue",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Connectez-vous pour accéder à votre espace",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      CustomInput(
                        label: "Email",
                        hintText: "exemple@berif.fr",
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      CustomInput(
                        label: "Mot de passe",
                        hintText: "••••••••",
                        isPassword: _obscure,
                        controller: _passController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text("Se connecter"),
                      ),
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

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "BERIF",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
