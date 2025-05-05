import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> selectedAnswers;
  final List<bool> isCorrect;
  final VoidCallback onComplete;

  const TestResultPage({
    super.key,
    required this.questions,
    required this.selectedAnswers,
    required this.isCorrect,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final correctCount = isCorrect.where((correct) => correct).length;
    final passed = correctCount >= 2;
    final primaryColor = passed ? CupertinoColors.systemGreen : CupertinoColors.systemRed;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Натиҷаҳо',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onComplete,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Анчом',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        passed ? CupertinoIcons.checkmark_alt : CupertinoIcons.xmark,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      passed ? 'Табрик!' : 'Кӯшиш намоед',
                      style: TextStyle(
                        fontSize: 24,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctCount аз ${questions.length} саволҳо дуруст',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    if (passed) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.lock_open_fill,
                              size: 18,
                              color: CupertinoColors.activeBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Модули 2 кушода шуд',
                              style: TextStyle(
                                fontSize: 15,
                                decoration: TextDecoration.none,
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final selectedAnswer = selectedAnswers[index];
                    final correct = isCorrect[index];
                    final answerColor = correct ? CupertinoColors.systemGreen : CupertinoColors.systemRed;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question['question'],
                            style: TextStyle(
                              fontSize: 17,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                              color: CupertinoTheme.of(context).textTheme.textStyle.color,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildAnswerRow(
                            context,
                            isUserAnswer: true,
                            isCorrect: correct,
                            answer: question['answers'][selectedAnswer!],
                          ),
                          const SizedBox(height: 14),
                          _buildAnswerRow(
                            context,
                            isUserAnswer: false,
                            isCorrect: true,
                            answer: question['answers'][question['correctIndex']],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerRow(
      BuildContext context, {
        required bool isUserAnswer,
        required bool isCorrect,
        required String answer,
      }) {
    final color = isUserAnswer
        ? (isCorrect ? CupertinoColors.systemGreen : CupertinoColors.systemRed)
        : CupertinoColors.systemGreen;
    final icon = isUserAnswer
        ? (isCorrect ? CupertinoIcons.checkmark_alt : CupertinoIcons.xmark)
        : CupertinoIcons.checkmark_alt;
    final prefix = isUserAnswer ? 'Ҷавоби шумо: ' : 'Ҷавоби дуруст: ';

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '$prefix$answer',
            style: TextStyle(
              fontSize: 15,
              color: color,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}