enum QuestionType { multipleChoice, trueFalse, numerical, essay }

class Question {
  final String id;
  final String quizId;
  final String text;
  final String? explanation;
  final QuestionType type;
  final List<String> options;
  final dynamic correctAnswer;
  final String? hint;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const Question({
    required this.id,
    required this.quizId,
    required this.text,
    this.explanation,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.hint,
    this.imageUrl,
    this.metadata,
  });

  factory Question.fromMap(Map<String, dynamic> data, String id) {
    return Question(
      id: id,
      quizId: data['quizId'] ?? '',
      text: data['text'] ?? '',
      explanation: data['explanation'],
      type: QuestionType.values.firstWhere(
        (t) => t.toString() == 'QuestionType.${data['type']}',
        orElse: () => QuestionType.multipleChoice,
      ),
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'],
      hint: data['hint'],
      imageUrl: data['imageUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'text': text,
      'explanation': explanation,
      'type': type.toString().split('.').last,
      'options': options,
      'correctAnswer': correctAnswer,
      'hint': hint,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  bool isCorrect(dynamic userAnswer) {
    if (userAnswer == null) return false;

    try {
      switch (type) {
        case QuestionType.multipleChoice:
          return userAnswer.toString().trim() ==
              correctAnswer.toString().trim();

        case QuestionType.trueFalse:
          if (correctAnswer is bool) {
            return userAnswer == correctAnswer;
          } else {
            final bool parsedCorrect =
                correctAnswer.toString().toLowerCase() == 'true';
            final bool parsedAnswer =
                userAnswer.toString().toLowerCase() == 'true';
            return parsedAnswer == parsedCorrect;
          }

        case QuestionType.numerical:
          try {
            final double numericAnswer = double.parse(userAnswer.toString());
            final double correctNumeric =
                double.parse(correctAnswer.toString());
            const double tolerance = 0.001; // 0.1% de marge d'erreur
            return (numericAnswer - correctNumeric).abs() <= tolerance;
          } catch (e) {
            return false; // En cas d'erreur de parsing
          }

        case QuestionType.essay:
          // Pour les questions à développement, nous utiliserons l'IA pour évaluer
          return false; // À implémenter avec l'API Gemini
      }
    } catch (e) {
      print('Error checking answer: $e');
      return false;
    }
  }

  String get difficultyText {
    final difficulty = metadata?['difficulty'] ?? 'medium';
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Facile';
      case 'hard':
        return 'Difficile';
      default:
        return 'Moyen';
    }
  }
}
