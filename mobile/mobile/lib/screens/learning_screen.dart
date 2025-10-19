import 'package:flutter/material.dart';
import '../constants/mock_data.dart';
import '../services/storage_service.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final List<Map<String, dynamic>> _trivia = MockData.getDRRMTrivia();
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _score = 0;

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _showExplanation = true;
      
      if (index == _trivia[_currentQuestionIndex]['correctAnswer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _trivia.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final percentage = (_score / _trivia.length * 100).toStringAsFixed(0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.blue, size: 32),
            SizedBox(width: 12),
            Text('Quiz Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 Congratulations!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $_score / ${_trivia.length}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '$percentage% correct',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_score == _trivia.length)
              const Text(
                'Perfect score! 🏅\nYou earned the DRRM Scholar badge!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _selectedAnswer = null;
                _showExplanation = false;
                _score = 0;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _trivia[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 DRRM Learning'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_trivia.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Score: $_score',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _trivia.length,
            ),
            const SizedBox(height: 24),

            // Question Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  currentQuestion['question'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...List.generate(
              (currentQuestion['options'] as List).length,
              (index) {
                final option = currentQuestion['options'][index];
                final isCorrect = index == currentQuestion['correctAnswer'];
                final isSelected = _selectedAnswer == index;

                Color? backgroundColor;
                Color? borderColor;

                if (_showExplanation) {
                  if (isCorrect) {
                    backgroundColor = Colors.green.shade50;
                    borderColor = Colors.green;
                  } else if (isSelected && !isCorrect) {
                    backgroundColor = Colors.red.shade50;
                    borderColor = Colors.red;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    onPressed: _showExplanation ? null : () => _selectAnswer(index),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: backgroundColor,
                      side: BorderSide(
                        color: borderColor ?? Colors.grey,
                        width: borderColor != null ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),

            // Explanation
            if (_showExplanation)
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedAnswer == currentQuestion['correctAnswer']
                                ? Icons.check_circle
                                : Icons.info,
                            color: _selectedAnswer == currentQuestion['correctAnswer']
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedAnswer == currentQuestion['correctAnswer']
                                ? 'Correct!'
                                : 'Explanation:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(currentQuestion['explanation']),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Next Button
            if (_showExplanation)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentQuestionIndex < _trivia.length - 1
                      ? 'Next Question'
                      : 'Finish',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
