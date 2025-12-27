import 'package:flutter/material.dart';
import '../../models/travail.dart';
import '../../services/travail_service.dart';

class ListeTravaux extends StatelessWidget {
  ListeTravaux({super.key});

  final TravailService travailService = TravailService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes travaux')),
      body: StreamBuilder<List<Travail>>(
        stream: travailService.getTravaux(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun travail"));
          }

          final travaux = snapshot.data!;
          return ListView.builder(
            itemCount: travaux.length,
            itemBuilder: (context, index) {
              final travail = travaux[index];
              return ListTile(
                title: Text(travail.commentaire),
                subtitle: Text(travail.statut),
              );
            },
          );
        },
      ),
    );
  }
}

