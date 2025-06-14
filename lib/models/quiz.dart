import 'package:flutter/material.dart';
import 'question.dart';

enum QuizDifficulty { easy, medium, hard }

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String description;
  final int questionCount;
  final QuizDifficulty difficulty;
  final double progress;
  final bool isAIRecommended;
  final DateTime? lastAttempt;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.questionCount,
    required this.difficulty,
    this.progress = 0.0,
    this.isAIRecommended = false,
    this.lastAttempt,
    this.questions = const [],
  });

  Color get difficultyColor {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Colors.green;
      case QuizDifficulty.medium:
        return Colors.orange;
      case QuizDifficulty.hard:
        return Colors.red;
    }
  }

  String get difficultyText {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Facile';
      case QuizDifficulty.medium:
        return 'Moyen';
      case QuizDifficulty.hard:
        return 'Difficile';
    }
  }

  factory Quiz.fromMap(Map<String, dynamic> data, String id) {
    return Quiz(
      id: id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      questionCount: data['questionCount'] ?? 0,
      difficulty: QuizDifficulty.values.firstWhere(
        (d) => d.toString() == data['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      progress: (data['progress'] ?? 0.0).toDouble(),
      isAIRecommended: data['isAIRecommended'] ?? false,
      lastAttempt: data['lastAttempt'] != null
          ? DateTime.parse(data['lastAttempt'])
          : null,
      questions: data['questions'] != null
          ? (data['questions'] as List).map((q) => Question.fromMap(q)).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'questionCount': questionCount,
      'difficulty': difficulty.toString(),
      'progress': progress,
      'isAIRecommended': isAIRecommended,
      'lastAttempt': lastAttempt?.toIso8601String(),
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}
