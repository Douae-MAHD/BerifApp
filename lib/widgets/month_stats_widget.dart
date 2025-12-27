import 'package:flutter/material.dart';
import 'year_calendar_modal.dart';

class MonthStatsWidget extends StatelessWidget {
  const MonthStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showYearCalendar(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "Décembre 2025",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatItem("3", "Total"),
                _StatItem("1", "Non assigné", Colors.red),
                _StatItem("1", "Assigné", Colors.orange),
                _StatItem("1", "Terminé", Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const _StatItem(this.value, this.label, [this.color]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
