import 'package:flutter/material.dart';

class AIRecommendationCard extends StatelessWidget {
  final String subject;
  final String recommendation;
  final VoidCallback? onAction;

  const AIRecommendationCard({
    super.key,
    required this.subject,
    required this.recommendation,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.indigo.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Colors.indigo,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommandation IA - $subject',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Commencer maintenant'),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.indigo[700],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
