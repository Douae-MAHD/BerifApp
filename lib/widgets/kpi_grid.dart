import 'package:flutter/material.dart';

class KPIGrid extends StatelessWidget {
  const KPIGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        _KPIItem("12", "Techniciens"),
        _KPIItem("28", "Clients"),
        _KPIItem("6", "Équipes"),
        _KPIItem("45", "Travaux"),
      ],
    );
  }
}

class _KPIItem extends StatelessWidget {
  final String value;
  final String label;

  const _KPIItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }
}
