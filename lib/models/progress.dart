import 'package:cloud_firestore/cloud_firestore.dart';

class Progress {
  final String userId;
  final String subjectId;
  final double progressPercentage;
  final int quizCompleted;
  final int chaptersCompleted;
  final DateTime lastUpdated;

  Progress({
    required this.userId,
    required this.subjectId,
    required this.progressPercentage,
    required this.quizCompleted,
    required this.chaptersCompleted,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'progressPercentage': progressPercentage,
      'quizCompleted': quizCompleted,
      'chaptersCompleted': chaptersCompleted,
      'lastUpdated': lastUpdated,
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      userId: map['userId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      progressPercentage: (map['progressPercentage'] ?? 0.0).toDouble(),
      quizCompleted: map['quizCompleted'] ?? 0,
      chaptersCompleted: map['chaptersCompleted'] ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }
}

class Activity {
  final String userId;
  final String type; // 'quiz', 'badge', 'chapter'
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.userId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp,
      'metadata': metadata,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: map['metadata'],
    );
  }
}
