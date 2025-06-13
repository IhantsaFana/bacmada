import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/ai_recommendation_card.dart';
import '../widgets/progress_overview.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_activity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Header(),
                const SizedBox(height: 16),
                const AIRecommendationCard(),
                const SizedBox(height: 16),
                const ProgressOverview(),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(
                      child: QuickActionButton(
                        icon: Icons.quiz,
                        color: Colors.indigo,
                        label: 'Quiz rapide',
                        description: 'Test tes connaissances',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: QuickActionButton(
                        icon: Icons.description,
                        color: Colors.green,
                        label: 'Annales',
                        description: 'Sujets corrigés',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const RecentActivity(),
                const SizedBox(
                  height: 80,
                ), // Espace pour la bottom navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
