import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';

class SubjectsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Subject> _subjects = [];
  List<Subject> _filteredSubjects = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Subject> get subjects => _subjects;
  List<Subject> get filteredSubjects =>
      _searchQuery.isEmpty ? _subjects : _filteredSubjects;
  bool get isLoading => _isLoading;

  void searchSubjects(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredSubjects = _subjects;
    } else {
      _filteredSubjects = _subjects.where((subject) {
        final name = subject.name.toLowerCase();
        final description = subject.description.toLowerCase();
        return name.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  List<Subject> getSubjectsByType(String type) {
    final subjectsToFilter =
        _searchQuery.isEmpty ? _subjects : _filteredSubjects;
    return subjectsToFilter.where((subject) => subject.type == type).toList();
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
      searchSubjects(_searchQuery); // Update filtered subjects
    } catch (e) {
      print('Error fetching subjects: $e');
      _subjects = [];
      _filteredSubjects = [];
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
      await fetchSubjects(); // Refresh the subjects list
    } catch (e) {
      print('Error updating subject progress: $e');
    }
  }
}
