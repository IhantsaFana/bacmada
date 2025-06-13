import 'package:flutter/material.dart';

class ProgressOverview extends StatelessWidget {
  const ProgressOverview({super.key});

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
          const Text('Progression du jour', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _SubjectProgress(label: 'Mathématiques', percent: 0.75, color: Colors.indigo),
          const SizedBox(height: 8),
          _SubjectProgress(label: 'Physique-Chimie', percent: 0.60, color: Colors.green),
          const SizedBox(height: 8),
          _SubjectProgress(label: 'SVT', percent: 0.45, color: Colors.orange),
        ],
      ),
    );
  }
}

class _SubjectProgress extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _SubjectProgress({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('${(percent * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.grey.shade200,
          color: color,
          minHeight: 6,
        ),
      ],
    );
  }
}
