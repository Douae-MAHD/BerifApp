import 'package:flutter/material.dart';

class CardTravail extends StatelessWidget {
  final String titre;
  final String client;
  final String date;
  final String statut;
  final String priorite;
  final VoidCallback onTap;

  const CardTravail({
    super.key,
    required this.titre,
    required this.client,
    required this.date,
    required this.statut,
    required this.priorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Carte Travail - Widget'),
              SizedBox(height: 8),
              Text('Cliquez pour voir les détails'),
            ],
          ),
        ),
      ),
    );
  }
}