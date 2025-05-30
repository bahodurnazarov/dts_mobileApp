import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: CupertinoNavigationBar(
          middle: const Text(
            'Поддержка',
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSupportCard(
                context,
                icon: CupertinoIcons.phone,
                title: 'Контактная информация',
                description: 'Телефоны и контакты для связи',
                iconColor: Colors.blue,
                onTap: () {
                  print('Перейти к контактной информации');
                },
              ),
              const SizedBox(height: 16),
              _buildSupportCard(
                context,
                icon: CupertinoIcons.chat_bubble,
                title: 'Чат с поддержкой',
                description: 'Онлайн-чат с оператором',
                iconColor: Colors.green,
                onTap: () {
                  print('Перейти к чату с поддержкой');
                },
              ),
              const SizedBox(height: 16),
              _buildSupportCard(
                context,
                icon: CupertinoIcons.mail,
                title: 'Электронная почта',
                description: 'Напишите нам на email',
                iconColor: Colors.orange,
                onTap: () {
                  print('Открыть почтовый клиент');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSupportCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}