import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqData = [
      {
        "question": "Какие обращения не подлежат рассмотрению?",
        "answer":
        "Согласно статье 21 Закона Республики Таджикистан «Об обращениях физических и юридических лиц», анонимные обращения (без указания ФИО, места жительства или реквизитов юридического лица) не подлежат рассмотрению, если они не содержат сведений о преступлениях."
      },
      {
        "question": "Как связаться с управлением наземного транспорта?",
        "answer": "Email: rnr@mintrans.tj\nТелефон: (+992) 222-22-15"
      },
      {
        "question": "Как узнать последние новости министерства?",
        "answer": "Email: mintrans@admin.tj\nТелефон: (+992) 992"
      },
      {
        "question": "Какой адрес Министерства транспорта?",
        "answer":
        "Почтовый индекс: 734042, г. Душанбе, улица Айни, 14\nТелефон: (+992 37) 221-17-13\nОбщий отдел: (+992 37) 222-22-14"
      },
      {
        "question": "Как связаться с приемной министра?",
        "answer": "Телефон: (+992 37) 221-17-13\nФакс: (+992 37) 221-20-03"
      },
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Часто задаваемые вопросы',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: TextDecoration.none, // Remove underline
          ),
        ),
        backgroundColor: CupertinoColors.white,
        border: Border(bottom: BorderSide(color: CupertinoColors.inactiveGray, width: 0.5)),
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: faqData.length,
          itemBuilder: (context, index) {
            return _buildFAQItem(
              context,
              question: faqData[index]['question']!,
              answer: faqData[index]['answer']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return GestureDetector(
      onTap: () {
        // Toggle answer visibility or show a dialog, if needed.
        print('Tapped on: $question');
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.question_circle,
                    size: 28,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      decoration: TextDecoration.none, // Remove underline
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.inactiveGray,
                decoration: TextDecoration.none, // Remove underline
              ),
            ),
          ],
        ),
      ),
    );
  }
}
