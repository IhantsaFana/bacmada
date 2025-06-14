import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/header.dart';
import '../widgets/quiz_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch quizzes when the screen loads
    Future.microtask(() {
      context.read<QuizProvider>().fetchQuizzes();
      // Generate daily quiz recommendation
      context.read<QuizProvider>().generateDailyQuiz(
            'Mathématiques', // You can make this dynamic based on user preference
            'Terminal S', // You can make this dynamic based on user level
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            if (quizProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => quizProvider.fetchQuizzes(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Header(),
                      const SizedBox(height: 24),

                      // Daily Quiz Section
                      if (quizProvider.dailyQuiz != null) ...[
                        const Text(
                          'Quiz du jour',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        QuizCard(
                          quiz: quizProvider.dailyQuiz!,
                          onTap: () {
                            // TODO: Navigate to quiz details
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Available Quizzes Section
                      const Text(
                        'Quiz disponibles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (quizProvider.quizzes.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun quiz disponible pour le moment',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quizProvider.quizzes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final quiz = quizProvider.quizzes[index];
                            return QuizCard(
                              quiz: quiz,
                              onTap: () {
                                // TODO: Navigate to quiz details
                              },
                            );
                          },
                        ),

                      // Space for bottom navigation
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
