import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../widgets/header.dart';

class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final List<Question> questions;
  final Map<String, dynamic> userAnswers;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();
    final percentage = (score.correct / questions.length * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildScoreCard(score, percentage),
                    const SizedBox(height: 24),
                    _buildAnswersReview(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(ScoreResult score, int percentage) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Quiz Terminé !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.indigo.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage >= 80
                        ? Colors.green
                        : percentage >= 60
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    '${score.correct}/${questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildScoreDetails(score),
        ],
      ),
    );
  }

  Widget _buildScoreDetails(ScoreResult score) {
    return Column(
      children: [
        _buildDetailRow(
          'Réponses correctes',
          score.correct,
          Icons.check_circle_outline,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          'Réponses incorrectes',
          score.incorrect,
          Icons.cancel_outlined,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, int value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswersReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Révision des réponses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final userAnswer = userAnswers[question.id];
          final isCorrect = question.isCorrect(userAnswer);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                      radius: 12,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (question.type == QuestionType.multipleChoice ||
                    question.type == QuestionType.essay)
                  _buildMultipleChoiceReview(question, userAnswer),
                if (question.type == QuestionType.trueFalse)
                  _buildTrueFalseReview(question, userAnswer),
                if (question.type == QuestionType.numerical)
                  _buildNumericalReview(question, userAnswer),
                if (!isCorrect && question.explanation != null) ...[
                  const SizedBox(height: 16),
                  _buildExplanation(question.explanation!),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMultipleChoiceReview(Question question, String? userAnswer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.options.map((option) {
        final isCorrect = option == question.correctAnswer;
        final isSelected = option == userAnswer;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.shade50
                : isSelected
                    ? Colors.red.shade50
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_outline
                    : isSelected
                        ? Icons.cancel_outlined
                        : Icons.radio_button_unchecked,
                color: isCorrect
                    ? Colors.green
                    : isSelected
                        ? Colors.red
                        : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isCorrect
                        ? Colors.green
                        : isSelected
                            ? Colors.red
                            : Colors.grey[700],
                    fontWeight: (isCorrect || isSelected)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseReview(Question question, bool? userAnswer) {
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseOption(
            'Vrai',
            true,
            question.correctAnswer as bool,
            userAnswer,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTrueFalseOption(
            'Faux',
            false,
            question.correctAnswer as bool,
            userAnswer,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseOption(
    String label,
    bool value,
    bool correctAnswer,
    bool? userAnswer,
  ) {
    final isCorrect = value == correctAnswer;
    final isSelected = value == userAnswer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.shade50
            : isSelected
                ? Colors.red.shade50
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_outline
                : isSelected
                    ? Icons.cancel_outlined
                    : Icons.radio_button_unchecked,
            color: isCorrect
                ? Colors.green
                : isSelected
                    ? Colors.red
                    : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isCorrect
                  ? Colors.green
                  : isSelected
                      ? Colors.red
                      : Colors.grey[700],
              fontWeight: (isCorrect || isSelected)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericalReview(Question question, String? userAnswer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Votre réponse : ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userAnswer ?? 'Non répondu',
              style: TextStyle(
                color:
                    question.isCorrect(userAnswer) ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Réponse correcte : ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              question.correctAnswer.toString(),
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExplanation(String explanation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              explanation,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo,
                side: const BorderSide(color: Colors.indigo),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Pop twice to go back to the quiz list
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Accueil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ScoreResult _calculateScore() {
    int correct = 0;
    int incorrect = 0;

    for (final question in questions) {
      if (userAnswers.containsKey(question.id)) {
        if (question.isCorrect(userAnswers[question.id])) {
          correct++;
        } else {
          incorrect++;
        }
      } else {
        incorrect++;
      }
    }

    return ScoreResult(correct: correct, incorrect: incorrect);
  }
}

class ScoreResult {
  final int correct;
  final int incorrect;

  const ScoreResult({required this.correct, required this.incorrect});
}
