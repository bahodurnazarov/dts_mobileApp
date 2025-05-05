import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'TestResultPage.dart';

class TestPage extends StatefulWidget {
  final Function(bool) onTestComplete;

  const TestPage({super.key, required this.onTestComplete});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = List.filled(3, null);
  List<bool> isCorrect = List.filled(3, false);
  int? currentSelectedAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Рангҳои чароғи роҳи нақлиёт аз боло ба поён чӣ гунаанд?',
      'answers': [
        'Сурх, зард, сабз',
        'Сабз, зард, сурх',
        'Зард, сабз, сурх',
        'Сурх, сабз, зард'
      ],
      'correctIndex': 0,
    },
    {
      'question': 'Ҳадди минималии суръат дар шаҳр чанд км/соат аст?',
      'answers': ['20 км/соат', '40 км/соат', '60 км/соат', 'Ҳадди минималӣ нест'],
      'correctIndex': 3,
    },
    {
      'question': 'Истифодаи телефон ҳангоми ронандагӣ:',
      'answers': [
        'Иҷозат дода шудааст',
        'Танҳо бо системаи hands-free иҷозат дорад',
        'Танҳо дар шаҳр иҷозат дорад',
        'Манъ аст'
      ],
      'correctIndex': 1,
    },
  ];

  void _selectAnswer(int answerIndex) {
    setState(() {
      currentSelectedAnswer = answerIndex;
    });
  }

  void _nextQuestion() {
    if (currentSelectedAnswer == null) return;

    setState(() {
      selectedAnswers[currentQuestionIndex] = currentSelectedAnswer;
      isCorrect[currentQuestionIndex] =
          currentSelectedAnswer == questions[currentQuestionIndex]['correctIndex'];
      currentSelectedAnswer = null;

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        _finishTest();
      }
    });
  }

  void _finishTest() {
    final correctCount = isCorrect.where((correct) => correct).length;
    final passed = correctCount >= 2;

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => TestResultPage(
          questions: questions,
          selectedAnswers: selectedAnswers,
          isCorrect: isCorrect,
          onComplete: () {
            widget.onTestComplete(passed);
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == questions.length - 1;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Санҷиши модул 1',
          style: TextStyle(
            fontSize: 20,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Савол ${currentQuestionIndex + 1} аз ${questions.length}',
                    style: TextStyle(
                      fontSize: 15,
                      decoration: TextDecoration.none,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${((currentQuestionIndex + 1) / questions.length * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        decoration: TextDecoration.none,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: CupertinoColors.systemGrey5,
                  color: CupertinoColors.activeBlue,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          currentQuestion['question'],
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            color: CupertinoTheme.of(context).textTheme.textStyle.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(currentQuestion['answers'].length, (index) {
                        final isSelected = currentSelectedAnswer == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => _selectAnswer(index),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? CupertinoColors.activeBlue
                                      : CupertinoColors.systemGrey5,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? CupertinoColors.activeBlue.withOpacity(0.2)
                                          : CupertinoColors.systemGrey5,
                                      shape: BoxShape.circle,
                                    ),
                                    child: isSelected
                                        ? Icon(
                                      CupertinoIcons.checkmark_alt,
                                      size: 16,
                                      color: CupertinoColors.activeBlue,
                                    )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      currentQuestion['answers'][index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: TextDecoration.none,
                                        color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: currentSelectedAnswer != null ? _nextQuestion : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: currentSelectedAnswer != null
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isLastQuestion ? 'Барои дидани натиҷаҳо' : 'Саволи навбатӣ',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentSelectedAnswer != null
                            ? CupertinoColors.white
                            : CupertinoColors.secondaryLabel,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,

                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}