import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/progress.dart';
import '../models/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Progress> _progress = [];
  List<Activity> _recentActivities = [];
  bool _isLoading = false;
  DateTime? _lastSync;

  List<Progress> get progress => _progress;
  List<Activity> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;

  // Initialisation et chargement des données
  Future<void> initialize() async {
    await _loadCachedData();
    await syncWithFirestore();
  }

  // Charger les données du cache
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('cached_progress');
      final activitiesJson = prefs.getString('cached_activities');
      final lastSyncStr = prefs.getString('last_sync');

      if (progressJson != null) {
        final List<dynamic> decoded = jsonDecode(progressJson);
        _progress = decoded.map((e) => Progress.fromMap(e)).toList();
      }

      if (activitiesJson != null) {
        final List<dynamic> decoded = jsonDecode(activitiesJson);
        _recentActivities = decoded.map((e) => Activity.fromMap(e)).toList();
      }

      if (lastSyncStr != null) {
        _lastSync = DateTime.parse(lastSyncStr);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement du cache: $e');
    }
  }

  // Sauvegarder les données en cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_progress',
        jsonEncode(_progress.map((e) => e.toMap()).toList()),
      );
      await prefs.setString(
        'cached_activities',
        jsonEncode(_recentActivities.map((e) => e.toMap()).toList()),
      );
      await prefs.setString('last_sync', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du cache: $e');
    }
  }

  // Synchronisation avec Firestore
  Future<void> syncWithFirestore() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return;

      // Récupérer la progression
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: user.uid)
          .get();

      _progress = progressSnapshot.docs
          .map((doc) => Progress.fromMap(doc.data()))
          .toList();

      // Récupérer les activités récentes
      final activitiesSnapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      _recentActivities = activitiesSnapshot.docs
          .map((doc) => Activity.fromMap(doc.data()))
          .toList();

      // Sauvegarder en cache
      await _saveToCache();

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur de synchronisation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour la progression d'une matière
  Future<void> updateProgress(String subjectId, double newProgress) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final progress = Progress(
        userId: user.uid,
        subjectId: subjectId,
        progressPercentage: newProgress,
        quizCompleted: _progress
                .firstWhere((p) => p.subjectId == subjectId,
                    orElse: () => Progress(
                        userId: user.uid,
                        subjectId: subjectId,
                        progressPercentage: 0,
                        quizCompleted: 0,
                        chaptersCompleted: 0,
                        lastUpdated: DateTime.now()))
                .quizCompleted +
            1,
        chaptersCompleted: _progress
            .firstWhere((p) => p.subjectId == subjectId,
                orElse: () => Progress(
                    userId: user.uid,
                    subjectId: subjectId,
                    progressPercentage: 0,
                    quizCompleted: 0,
                    chaptersCompleted: 0,
                    lastUpdated: DateTime.now()))
            .chaptersCompleted,
        lastUpdated: DateTime.now(),
      );

      // Mettre à jour Firestore
      await _firestore
          .collection('progress')
          .doc('${user.uid}_$subjectId')
          .set(progress.toMap());

      // Mettre à jour la liste locale
      final index = _progress.indexWhere((p) => p.subjectId == subjectId);
      if (index >= 0) {
        _progress[index] = progress;
      } else {
        _progress.add(progress);
      }

      await _saveToCache();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la progression: $e');
    }
  }

  // Ajouter une nouvelle activité
  Future<void> addActivity(
    String type,
    String title,
    String subtitle, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final activity = Activity(
        userId: user.uid,
        type: type,
        title: title,
        subtitle: subtitle,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      // Ajouter à Firestore
      await _firestore.collection('activities').add(activity.toMap());

      // Mettre à jour la liste locale
      _recentActivities.insert(0, activity);
      if (_recentActivities.length > 10) {
        _recentActivities.removeLast();
      }

      await _saveToCache();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout d\'une activité: $e');
    }
  }

  // Obtenir des recommandations basées sur la progression
  Future<List<Map<String, String>>> getRecommendations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Trouver les matières avec la progression la plus faible
      final weakestSubjects = _progress
          .where((p) => p.progressPercentage < 60)
          .toList()
        ..sort((a, b) => a.progressPercentage.compareTo(b.progressPercentage));

      if (weakestSubjects.isEmpty) {
        return [
          {
            'subject': 'Général',
            'recommendation':
                'Excellent travail ! Continuez à maintenir votre niveau.',
          }
        ];
      }

      return weakestSubjects
          .map((p) => {
                'subject': p.subjectId,
                'recommendation':
                    'Votre progression en ${p.subjectId} est de ${p.progressPercentage.round()}%. Nous vous recommandons de faire plus de quiz dans cette matière.',
              })
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la génération des recommandations: $e');
      return [];
    }
  }
}
