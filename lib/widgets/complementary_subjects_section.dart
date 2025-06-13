import 'package:flutter/material.dart';

class ComplementarySubjectsSection extends StatelessWidget {
  const ComplementarySubjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [BoxShadow(color: Colors.blue.shade50, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Matières complémentaires', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout', style: TextStyle(fontSize: 12, color: Colors.indigo)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ComplementarySubjectCard(
            icon: Icons.history,
            color: Colors.amber,
            title: 'Histoire-Géo',
          ),
          const SizedBox(height: 8),
          _ComplementarySubjectCard(
            icon: Icons.language,
            color: Colors.teal,
            title: 'Langues vivantes',
          ),
        ],
      ),
    );
  }
}

class _ComplementarySubjectCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _ComplementarySubjectCard({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ],
      ),
    );
  }
}
