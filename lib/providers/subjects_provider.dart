import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';

class SubjectsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  List<Subject> getSubjectsByType(String type) {
    return _subjects.where((subject) => subject.type == type).toList();
  }

  Stream<List<Subject>> getSubjectsByCategory(String category) {
    return _firestore
        .collection('subject')
        .where('type', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Subject.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> fetchSubjects() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore.collection('subject').get();
      _subjects = querySnapshot.docs
          .map((doc) => Subject.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching subjects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSubjectProgress(String subjectId, double progress) async {
    try {
      await _firestore
          .collection('subject')
          .doc(subjectId)
          .update({'progress': progress});

      // Update local state
      final index = _subjects.indexWhere((s) => s.id == subjectId);
      if (index != -1) {
        _subjects[index] = Subject.fromMap(
          {..._subjects[index].toMap(), 'progress': progress},
          subjectId,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating subject progress: $e');
    }
  }
}
