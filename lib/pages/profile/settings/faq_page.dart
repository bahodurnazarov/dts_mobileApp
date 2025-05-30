import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
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

  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    isExpandedList = List.generate(faqData.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: CupertinoNavigationBar(
          middle: const Text(
            'Часто задаваемые вопросы',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: CupertinoColors.white,
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.inactiveGray,
              width: 0.5,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              CupertinoIcons.back,
              size: 26,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: faqData.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildFAQItem(
              context,
              question: faqData[index]['question']!,
              answer: faqData[index]['answer']!,
              isExpanded: isExpandedList[index],
              onTap: () {
                setState(() {
                  isExpandedList[index] = !isExpandedList[index];
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFAQItem(
      BuildContext context, {
        required String question,
        required String answer,
        required bool isExpanded,
        required VoidCallback onTap,
      }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.question_circle,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(height: 12),
                  Divider(height: 1, color: Colors.grey[200]),
                  SizedBox(height: 12),
                  Text(
                    answer,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}