import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final String description;
  final String type;
  final double progress;
  final IconData icon;
  final int chapterCount;
  final int exerciseCount;
  final Color color;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.progress = 0.0,
    this.icon = Icons.book,
    this.chapterCount = 0,
    this.exerciseCount = 0,
    this.color = Colors.indigo,
  });

  factory Subject.fromMap(Map<String, dynamic> data, String id) {
    return Subject(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'main',
      progress: (data['progress'] ?? 0.0).toDouble(),
      chapterCount: data['chapterCount'] ?? 0,
      exerciseCount: data['exerciseCount'] ?? 0,
      icon: Icons.book, // TODO: Add icon support in Firestore
      color: Colors.indigo, // TODO: Add color support in Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'progress': progress,
      'chapterCount': chapterCount,
      'exerciseCount': exerciseCount,
    };
  }
}
