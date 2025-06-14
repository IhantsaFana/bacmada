import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../widgets/header.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  Map<String, dynamic> _userAnswers = {};
  bool _showExplanation = false;
  String? _currentHint;
  final PageController _pageController = PageController();
  bool _isLoading = true;
  List<Question> _questions = [];
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      await quizProvider.loadQuizQuestions(widget.quiz.id);
      setState(() {
        _questions = quizProvider.getQuestionsForQuiz(widget.quiz.id);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des questions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 16),
            if (_questions.isNotEmpty) _buildProgressBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Chargement des questions...'),
                        ],
                      ),
                    )
                  : _questions.isEmpty
                      ? _buildEmptyState()
                      : _buildQuizContent(),
            ),
            if (!_isLoading && _questions.isNotEmpty) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune question disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ce quiz sera bientôt disponible',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Retour aux quiz'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress =
        _questions.isEmpty ? 0.0 : (_currentIndex + 1) / _questions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.indigo.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_currentIndex >= _questions.length) {
      return _buildEmptyState();
    }

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questions.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
          _showExplanation = false;
          _currentHint = null;
        });
      },
      itemBuilder: (context, index) {
        final question = _questions[index];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestionHeader(question, index + 1),
              if (question.imageUrl != null) ...[
                const SizedBox(height: 16),
                _buildQuestionImage(question.imageUrl!),
              ],
              const SizedBox(height: 24),
              _buildQuestionContent(question),
              if (_showExplanation && question.explanation != null) ...[
                const SizedBox(height: 16),
                _buildExplanation(question.explanation!),
              ],
              if (_currentHint != null) ...[
                const SizedBox(height: 16),
                _buildHint(_currentHint!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionHeader(Question question, int current) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (question.metadata?.containsKey('subject') ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                question.metadata!['subject'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildQuestionContent(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice(question);
      case QuestionType.trueFalse:
        return _buildTrueFalse(question);
      case QuestionType.numerical:
        return _buildNumericalInput(question);
      case QuestionType.essay:
        return _buildMultipleChoice(question); // On convertit en QCM
    }
  }

  Widget _buildMultipleChoice(Question question) {
    // Pour les questions de type essay, générer des options pertinentes
    List<String> options = question.type == QuestionType.essay
        ? _generateOptionsForEssay(question)
        : question.options;

    return Column(
      children: [
        ...options.map((option) {
          final isSelected = _userAnswers[question.id] == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showExplanation
                    ? null
                    : () => _selectAnswer(question.id, option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _showExplanation
                        ? _getAnswerColor(option, question)
                        : (isSelected
                            ? Colors.indigo.withOpacity(0.1)
                            : Colors.white),
                    border: Border.all(
                      color: _showExplanation
                          ? _getAnswerBorderColor(option, question)
                          : (isSelected ? Colors.indigo : Colors.grey.shade300),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showExplanation
                            ? _getAnswerIcon(option, question)
                            : (isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked),
                        color: _showExplanation
                            ? _getAnswerIconColor(option, question)
                            : (isSelected ? Colors.indigo : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.indigo : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        if (!_showExplanation) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _userAnswers.containsKey(question.id)
                ? () => _verifyAnswer(question)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Valider ma réponse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Fonctions utilitaires pour la gestion des réponses
  Color _getAnswerColor(String option, Question question) {
    if (option == question.correctAnswer) {
      return Colors.green.withOpacity(0.1);
    } else if (_userAnswers[question.id] == option) {
      return Colors.red.withOpacity(0.1);
    }
    return Colors.white;
  }

  Color _getAnswerBorderColor(String option, Question question) {
    if (option == question.correctAnswer) {
      return Colors.green;
    } else if (_userAnswers[question.id] == option) {
      return Colors.red;
    }
    return Colors.grey.shade300;
  }

  IconData _getAnswerIcon(String option, Question question) {
    if (option == question.correctAnswer) {
      return Icons.check_circle_outline;
    } else if (_userAnswers[question.id] == option) {
      return Icons.cancel_outlined;
    }
    return Icons.radio_button_unchecked;
  }

  Color _getAnswerIconColor(String option, Question question) {
    if (option == question.correctAnswer) {
      return Colors.green;
    } else if (_userAnswers[question.id] == option) {
      return Colors.red;
    }
    return Colors.grey;
  }

  List<String> _generateOptionsForEssay(Question question) {
    // Générer des options pertinentes basées sur le type de question
    final correctAnswer = question.correctAnswer as String;

    // Vérifier si la réponse contient des mots-clés scientifiques
    if (question.text.toLowerCase().contains('physique') ||
        question.text.toLowerCase().contains('force') ||
        question.text.toLowerCase().contains('mouvement')) {
      return [
        correctAnswer,
        'Le mouvement est uniforme et l\'accélération est nulle',
        'La force est constante mais la vitesse varie',
        'Le mouvement est rectiligne uniformément varié',
      ];
    } else if (question.text.toLowerCase().contains('chimie') ||
        question.text.toLowerCase().contains('réaction')) {
      return [
        correctAnswer,
        'La réaction est endothermique',
        'La réaction est exothermique',
        'La réaction est à l\'équilibre',
      ];
    } else if (question.text.toLowerCase().contains('math') ||
        question.text.toLowerCase().contains('fonction')) {
      return [
        correctAnswer,
        'La fonction est croissante sur tout ℝ',
        'La fonction admet une limite finie en +∞',
        'La fonction est périodique',
      ];
    }

    // Options par défaut si aucun mot-clé n'est détecté
    return [
      correctAnswer,
      'La réponse B qui est incorrecte',
      'La réponse C qui est incorrecte',
      'Aucune des réponses ci-dessus',
    ];
  }

  Widget _buildTrueFalse(Question question) {
    return Row(
      children: [
        Expanded(
          child: _buildAnswerButton(
            question,
            true,
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnswerButton(
            question,
            false,
            Icons.cancel_outlined,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(
    Question question,
    bool value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _userAnswers[question.id] == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            _showExplanation ? null : () => _selectAnswer(question.id, value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(
                value ? 'Vrai' : 'Faux',
                style: TextStyle(
                  color: isSelected ? color : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericalInput(Question question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.metadata?.containsKey('unit') ?? false)
            Text(
              'Unité: ${question.metadata!['unit']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _selectAnswer(question.id, value),
                  enabled: !_showExplanation,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre réponse',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _showExplanation
                    ? null
                    : () => _verifyAnswer(_questions[_currentIndex]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Valider'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEssayInput(Question question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        maxLines: 6,
        onChanged: (value) => _selectAnswer(question.id, value),
        enabled: !_showExplanation,
        decoration: InputDecoration(
          hintText: 'Rédigez votre réponse...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildExplanation(String explanation) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Explication',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHint(String hint) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Indice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastQuestion = _currentIndex == _questions.length - 1;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!_showExplanation && _questions[_currentIndex].hint != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentHint = _questions[_currentIndex].hint;
                });
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Indice'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          const Spacer(),
          if (_showExplanation)
            ElevatedButton.icon(
              onPressed:
                  _currentIndex < _questions.length - 1 ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                  isLastQuestion ? 'Voir les résultats' : 'Question suivante'),
            ),
        ],
      ),
    );
  }

  void _selectAnswer(String questionId, dynamic answer) {
    setState(() {
      _userAnswers[questionId] = answer;
    });
  }

  void _verifyAnswer(Question question) async {
    if (!_userAnswers.containsKey(question.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une réponse'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final isCorrect = question.isCorrect(_userAnswers[question.id]);

      setState(() {
        _showExplanation = true;
      });

      if (isCorrect) {
        // Mettre à jour le progrès
        await context.read<QuizProvider>().updateQuestionProgress(
              widget.quiz.id,
              question.id,
              true,
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCorrect ? 'Bonne réponse !' : 'Ce n\'est pas la bonne réponse.',
          ),
          backgroundColor: isCorrect ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _showExplanation = false;
        _currentHint = null;
        _textController.clear();
      });
    } else {
      // Show the quiz result screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            quiz: widget.quiz,
            questions: _questions,
            userAnswers: _userAnswers,
          ),
        ),
      );
    }
  }
}
