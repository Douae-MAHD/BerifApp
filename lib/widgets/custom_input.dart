import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String hintText; // Renommé pour plus de clarté
  final bool isPassword;
  final Widget? suffixIcon;
  final TextEditingController? controller; // Ajouté pour récupérer le texte

  const CustomInput({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}