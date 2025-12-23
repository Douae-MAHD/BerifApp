import 'package:flutter/material.dart';

class SuiviTravailScreen extends StatefulWidget {
  final String travailId;
  final bool isTechnicien;

  const SuiviTravailScreen({
    super.key,
    required this.travailId,
    this.isTechnicien = false,
  });

  @override
  State<SuiviTravailScreen> createState() => _SuiviTravailScreenState();
}

class _SuiviTravailScreenState extends State<SuiviTravailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTechnicien ? 'Suivi travail' : 'Détails travail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID Travail: ${widget.travailId}'),
            Text('Mode Technicien: ${widget.isTechnicien}'),
            const SizedBox(height: 20),
            const Text('Page de suivi - En construction'),
          ],
        ),
      ),
    );
  }
}