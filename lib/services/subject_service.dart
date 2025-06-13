import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;
  final String description;
  final String category;
  final int coefficient;
  final String imageUrl;
  final List<String> topics;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.coefficient,
    required this.imageUrl,
    required this.topics,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      coefficient: data['coefficient'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      topics: List<String>.from(data['topics'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'coefficient': coefficient,
      'imageUrl': imageUrl,
      'topics': topics,
    };
  }
}

class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir toutes les matières
  Stream<List<Subject>> getSubjects() {
    return _firestore.collection('subject').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
    });
  }

  // Obtenir les matières par catégorie
  Stream<List<Subject>> getSubjectsByCategory(String category) {
    return _firestore
        .collection('subject')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Subject.fromFirestore(doc))
              .toList();
        });
  }

  // Rechercher des matières
  Future<List<Subject>> searchSubjects(String query) async {
    query = query.toLowerCase();
    final snapshot = await _firestore.collection('subject').get();
    return snapshot.docs
        .map((doc) => Subject.fromFirestore(doc))
        .where(
          (subject) =>
              subject.name.toLowerCase().contains(query) ||
              subject.description.toLowerCase().contains(query),
        )
        .toList();
  }

  // Ajouter une nouvelle matière
  Future<void> addSubject(Subject subject) async {
    await _firestore.collection('subject').add(subject.toMap());
  }

  // Mettre à jour une matière
  Future<void> updateSubject(String id, Subject subject) async {
    await _firestore.collection('subject').doc(id).update(subject.toMap());
  }
}
