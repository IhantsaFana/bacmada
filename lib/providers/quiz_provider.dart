import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../services/gemini_service.dart';

class QuizProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();

  List<Quiz> _quizzes = [];
  Quiz? _dailyQuiz;
  Map<String, List<Question>> _quizQuestions = {};
  Map<String, String> _aiExplanations = {};
  bool _isLoading = false;
  String _error = '';
  final List<String> _completedQuizzes = [];

  List<Quiz> get quizzes => _quizzes;
  Quiz? get dailyQuiz => _dailyQuiz;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<Question> getQuestionsForQuiz(String quizId) {
    return _quizQuestions[quizId] ?? [];
  }

  Future<void> loadQuizQuestions(String quizId) async {
    if (_quizQuestions.containsKey(quizId) &&
        _quizQuestions[quizId]!.isNotEmpty) {
      return; // Les questions sont déjà chargées
    }

    try {
      // Essayer d'abord de récupérer les questions de Firestore
      final questionsSnapshot = await _firestore
          .collection('questions')
          .where('quizId', isEqualTo: quizId)
          .get();

      if (questionsSnapshot.docs.isEmpty) {
        // Si aucune question n'existe, créer des questions par défaut
        _quizQuestions[quizId] = await _generateDefaultQuestions(quizId);
      } else {
        _quizQuestions[quizId] = questionsSnapshot.docs
            .map((doc) => Question.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      print('Error loading questions for quiz $quizId: $e');
      // En cas d'erreur d'accès à Firestore, utiliser des questions locales
      _quizQuestions[quizId] = _createLocalQuestions(quizId);
    }
  }

  List<Question> _createLocalQuestions(String quizId) {
    // Créer des questions locales pour le mode hors ligne ou en cas d'erreur
    return [
      Question(
        id: 'local_1_$quizId',
        quizId: quizId,
        text: 'Quelle est la différence entre la vitesse et l\'accélération ?',
        type: QuestionType.essay,
        options: [],
        correctAnswer:
            'La vitesse mesure le changement de position, l\'accélération mesure le changement de vitesse.',
        explanation:
            'La vitesse est une grandeur qui décrit le taux de variation de la position d\'un objet, tandis que l\'accélération décrit le taux de variation de la vitesse.',
      ),
      Question(
        id: 'local_2_$quizId',
        quizId: quizId,
        text:
            'La Terre tourne autour du Soleil en suivant une orbite elliptique.',
        type: QuestionType.trueFalse,
        options: ['Vrai', 'Faux'],
        correctAnswer: true,
        explanation:
            'La première loi de Kepler stipule que les planètes décrivent des orbites elliptiques dont le Soleil occupe l\'un des foyers.',
      ),
      Question(
        id: 'local_3_$quizId',
        quizId: quizId,
        text:
            'Calculez l\'accélération d\'un objet dont la vitesse passe de 0 à 10 m/s en 2 secondes.',
        type: QuestionType.numerical,
        options: [],
        correctAnswer: 5,
        metadata: {'unit': 'm/s²'},
        explanation:
            'L\'accélération est la variation de vitesse divisée par le temps : a = Δv/Δt = (10-0)/2 = 5 m/s²',
      ),
    ];
  }

  Future<List<Question>> _generateDefaultQuestions(String quizId) async {
    final questions = _createLocalQuestions(quizId);

    try {
      // Essayer de sauvegarder les questions dans Firestore
      for (var question in questions) {
        await _firestore
            .collection('questions')
            .doc(question.id)
            .set(question.toMap());
      }
    } catch (e) {
      print('Error saving default questions: $e');
      // Continuer même si la sauvegarde échoue
    }

    return questions;
  }

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final querySnapshot = await _firestore.collection('quizzes').get();
      _quizzes = querySnapshot.docs
          .map((doc) => Quiz.fromMap(doc.data(), doc.id))
          .toList();

      // Pour le quiz quotidien, on charge immédiatement ses questions
      if (_dailyQuiz != null) {
        await loadQuizQuestions(_dailyQuiz!.id);
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des quiz';
      print('Error fetching quizzes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateDailyQuiz(String subject, String studentLevel) async {
    try {
      _isLoading = true;
      notifyListeners();

      final recommendation = await _geminiService.getQuizRecommendation(
        subject,
        studentLevel,
      );

      final quizId = 'daily-${DateTime.now().toIso8601String()}';
      _dailyQuiz = Quiz(
        id: quizId,
        title: recommendation['title'],
        subject: subject,
        description: recommendation['description'],
        questionCount: recommendation['questionCount'],
        difficulty: _parseDifficulty(recommendation['difficulty']),
        isAIRecommended: true,
      );

      // Créer immédiatement les questions par défaut pour le quiz quotidien
      await _generateDefaultQuestions(quizId);

      notifyListeners();
    } catch (e) {
      print('Error generating daily quiz: $e');
      _error = 'Erreur lors de la génération du quiz quotidien';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuestionProgress(
      String quizId, String questionId, bool isCorrect) async {
    try {
      // Mettre à jour le progrès de la question
      await _firestore.collection('progress').add({
        'quizId': quizId,
        'questionId': questionId,
        'isCorrect': isCorrect,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Recalculer le progrès global du quiz
      final progress = await _calculateQuizProgress(quizId);
      await updateQuizProgress(quizId, progress);
    } catch (e) {
      print('Error updating question progress: $e');
      throw Exception('Failed to update progress');
    }
  }

  Future<double> _calculateQuizProgress(String quizId) async {
    try {
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('quizId', isEqualTo: quizId)
          .where('isCorrect', isEqualTo: true)
          .get();

      final totalQuestions = _quizQuestions[quizId]?.length ?? 0;
      if (totalQuestions == 0) return 0.0;

      final correctAnswers = progressSnapshot.docs.length;
      return correctAnswers / totalQuestions;
    } catch (e) {
      print('Error calculating quiz progress: $e');
      return 0.0;
    }
  }

  Future<String> getAIExplanation(Question question, dynamic userAnswer) async {
    if (_aiExplanations.containsKey(question.id)) {
      return _aiExplanations[question.id]!;
    }

    try {
      final explanation = await _geminiService.getQuestionExplanation(
        question.text,
        question.correctAnswer.toString(),
        userAnswer.toString(),
      );

      _aiExplanations[question.id] = explanation;
      notifyListeners();
      return explanation;
    } catch (e) {
      print('Error getting AI explanation: $e');
      return 'Une erreur est survenue lors de la génération de l\'explication.';
    }
  }

  Future<void> updateQuizProgress(String quizId, double progress) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({
        'progress': progress,
        'lastAttempt': DateTime.now().toIso8601String(),
      });
      await fetchQuizzes();
    } catch (e) {
      print('Error updating quiz progress: $e');
      _error = 'Erreur lors de la mise à jour du progrès';
      notifyListeners();
    }
  }

  // Obtenir les quiz pour une matière donnée
  List<Quiz> getQuizzesForSubject(String subjectId) {
    try {
      return _quizzes.where((quiz) => quiz.subject == subjectId).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des quiz: $e');
      return [];
    }
  }

  // Obtenir un quiz recommandé pour une matière
  Future<Quiz?> getRecommendedQuiz(String subjectId) async {
    try {
      final quizzes = getQuizzesForSubject(subjectId);
      // Filtrer les quiz non terminés et trier par pertinence
      final uncompletedQuizzes = quizzes
          .where((quiz) => !_completedQuizzes.contains(quiz.id))
          .toList();

      if (uncompletedQuizzes.isEmpty) {
        return quizzes.isNotEmpty ? quizzes.first : null;
      }

      // Pour l'instant, on retourne simplement le premier quiz non complété
      // TODO: Implémenter un algorithme de recommandation plus sophistiqué
      return uncompletedQuizzes.first;
    } catch (e) {
      debugPrint('Erreur lors de la recommandation de quiz: $e');
      return null;
    }
  }

  QuizDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return QuizDifficulty.easy;
      case 'hard':
        return QuizDifficulty.hard;
      default:
        return QuizDifficulty.medium;
    }
  }
}
