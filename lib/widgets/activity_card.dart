import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String client;
  final String adresse;
  final String statut;

  const ActivityCard({
    super.key,
    required this.client,
    required this.adresse,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(client,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Chip(label: Text(statut)),
            ],
          ),
          const SizedBox(height: 8),
          Text(adresse, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {},
            child: const Text("Voir / Assigner équipe"),
          )
        ],
      ),
    );
  }
}
