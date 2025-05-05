import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'modules_page.dart';

class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Курсҳо',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: null, // Remove bottom border
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Интихоби курс',
                style: TextStyle(
                  fontSize: 28,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Курсҳои мувофиқро барои омӯзиш интихоб кунед',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCourseCard(
                    context,
                    title: "Курсҳои 20 соата",
                    subtitle: "Курсҳои пурра",
                    icon: CupertinoIcons.book_circle_fill,
                    color: CupertinoColors.activeBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const ModulesPage(),
                          settings: const RouteSettings(name: 'ModulesPage'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCourseCard(
                    context,
                    title: "Курсҳои кӯтоҳ",
                    subtitle: "Омӯзиш дар давоми 5 соат",
                    icon: CupertinoIcons.bolt_fill,
                    color: CupertinoColors.systemYellow,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildCourseCard(
                    context,
                    title: "Курсҳои иловагӣ",
                    subtitle: "Маводҳои иловагӣ барои такмил додан",
                    icon: CupertinoIcons.square_stack_3d_up_fill,
                    color: CupertinoColors.systemGreen,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.7),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 16,
                color: CupertinoColors.secondaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}