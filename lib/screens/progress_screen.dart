import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../widgets/header.dart';
import '../widgets/subject_progress_chart.dart';
import '../widgets/activity_card.dart';
import '../widgets/ai_recommendation_card.dart';
import '../providers/progress_provider.dart';
import '../providers/quiz_provider.dart';
import '../models/progress.dart';
import '../screens/quiz_play_screen.dart';
import '../screens/detailed_progress_screen.dart';
import '../screens/subject_detail_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final progressProvider = context.read<ProgressProvider>();
      progressProvider.initialize().then((_) {
        _animationController.forward();
      });
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: Consumer<ProgressProvider>(
          builder: (context, progressProvider, child) {
            if (progressProvider.isLoading && !_isInit) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                const Header(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => progressProvider.syncWithFirestore(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverallProgress(progressProvider),
                            const SizedBox(height: 24),
                            _buildSubjectsProgress(progressProvider),
                            const SizedBox(height: 24),
                            _buildRecentActivities(progressProvider),
                            const SizedBox(height: 24),
                            _buildAiRecommendations(progressProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallProgress(ProgressProvider provider) {
    final progress = provider.progress;
    final totalProgress = progress.isEmpty
        ? 0.0
        : progress.map((p) => p.progressPercentage).reduce((a, b) => a + b) /
            progress.length;

    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, _) => const DetailedProgressScreen(),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.indigo.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progression Globale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${totalProgress.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'de progression',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildProgressTrend(provider),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTrend(ProgressProvider provider) {
    // TODO: Calculer la tendance réelle
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '+5% cette semaine',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsProgress(ProgressProvider provider) {
    final subjects = provider.progress;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression par matière',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...subjects.map((subject) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OpenContainer(
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) =>
                    SubjectDetailScreen(subject: subject),
                closedBuilder: (context, openContainer) => InkWell(
                  onTap: openContainer,
                  child: SubjectProgressChart(
                    subject: subject.subjectId,
                    progress: subject.progressPercentage,
                    color: Colors.indigo,
                    quizCount: subject.quizCompleted,
                    chaptersCount: subject.chaptersCompleted,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(ProgressProvider provider) {
    final activities = provider.recentActivities;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.2, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activités récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) {
            return ActivityCard(
              icon: _getActivityIcon(activity.type),
              title: activity.title,
              subtitle: activity.subtitle,
              timeAgo: _formatTimeAgo(activity.timestamp),
              color: _getActivityColor(activity.type),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAiRecommendations(ProgressProvider provider) {
    return FutureBuilder<List<Map<String, String>>>(
      future: provider.getRecommendations(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final recommendations = snapshot.data!;

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(0.4, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommandations IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...recommendations.map((rec) {
                return AIRecommendationCard(
                  subject: rec['subject']!,
                  recommendation: rec['recommendation']!,
                  onAction: () => _navigateToRecommendedQuiz(rec['subject']!),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.check_circle;
      case 'badge':
        return Icons.emoji_events;
      case 'chapter':
        return Icons.menu_book;
      default:
        return Icons.star;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'quiz':
        return Colors.green;
      case 'badge':
        return Colors.amber;
      case 'chapter':
        return Colors.blue;
      default:
        return Colors.indigo;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }

  void _navigateToRecommendedQuiz(String subject) async {
    final quizProvider = context.read<QuizProvider>();
    final recommendedQuiz = await quizProvider.getRecommendedQuiz(subject);
    if (recommendedQuiz != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizPlayScreen(quiz: recommendedQuiz),
        ),
      );
    }
  }
}
