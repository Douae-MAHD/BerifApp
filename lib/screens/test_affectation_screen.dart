import 'package:flutter/material.dart';
import '../models/equipe.dart';
import '../models/technicien.dart';
import '../models/affectation.dart';
import '../services/equipe_service.dart';
import '../services/technicien_service.dart';
import '../services/affectation_service.dart';

class TestAffectationScreen extends StatefulWidget {
  @override
  State<TestAffectationScreen> createState() => _TestAffectationScreenState();
}

class _TestAffectationScreenState extends State<TestAffectationScreen> {
  final equipeService = EquipeService();
  final technicienService = TechnicienService();
  final affectationService = AffectationService();

  String? selectedEquipeId;
  String? selectedTechnicienId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Affectation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔽 EQUIPE
            StreamBuilder<List<Equipe>>(
              stream: equipeService.getEquipes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return DropdownButton<String>(
                  value: selectedEquipeId,
                  hint: const Text('Choisir une équipe'),
                  isExpanded: true,
                  items: snapshot.data!.map((equipe) {
                    return DropdownMenuItem<String>(
                      value: equipe.id,
                      child: Text(equipe.nomEquipe),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedEquipeId = value);
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            /// 🔽 TECHNICIEN
            StreamBuilder<List<Technicien>>(
              stream: technicienService.getTechniciens(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return DropdownButton<String>(
                  value: selectedTechnicienId,
                  hint: const Text('Choisir un technicien'),
                  isExpanded: true,
                  items: snapshot.data!.map((tech) {
                    return DropdownMenuItem<String>(
                      value: tech.id,
                      child: Text('${tech.nom} ${tech.prenom}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedTechnicienId = value);
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            /// ✅ BOUTON AFFECTER
            ElevatedButton(
              onPressed: selectedEquipeId == null ||
                  selectedTechnicienId == null
                  ? null
                  : () async {
                await affectationService.addAffectation(
                  Affectation(
                    id: '',
                    equipeId: selectedEquipeId!,
                    technicienId: selectedTechnicienId!,
                    dateAffectation: DateTime.now(),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Affectation créée'),
                  ),
                );
              },
              child: const Text('Affecter'),
            ),
          ],
        ),
      ),
    );
  }
}
