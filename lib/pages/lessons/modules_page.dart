import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LearningPage.dart';
import 'test_page.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({super.key});

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  List<Map<String, dynamic>> modules = [];
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initModules();
  }

  Future<void> _clearUnlockedModules() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unlocked_modules');
    print('unlocked_modules removed from cache.');
  }


  Future<void> _initModules() async {
    final prefs = await SharedPreferences.getInstance();
    _printUnlockedModules();
    _clearUnlockedModules();
    final unlockedModules = prefs.getStringList('unlocked_modules') ?? ['0'];

    setState(() {
      modules = [
        {
          "title": "Модули 1: Асосҳо",
          "subtitle": "Асосҳои нақлиёт ва қонунҳо",
          "progress": 0.0,
          "icon": CupertinoIcons.car_fill,
          "color": CupertinoColors.systemGreen,
          "locked": !unlockedModules.contains('0'),
          "completed": prefs.getBool('module_0_completed') ?? false,
        },
        {
          "title": "Модули 2: Идоракунӣ",
          "subtitle": "Идоракунии ҳаракат ва хатарот",
          "progress": 0.0,
          "icon": CupertinoIcons.car_fill,
          "color": CupertinoColors.systemOrange,
          "locked": !unlockedModules.contains('1'),
          "completed": prefs.getBool('module_1_completed') ?? false,
        },
      ];
    });
  }

  Future<void> _unlockModule(int moduleIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedModules = prefs.getStringList('unlocked_modules') ?? ['0'];
    if (!unlockedModules.contains(moduleIndex.toString())) {
      unlockedModules.add(moduleIndex.toString());
      await prefs.setStringList('unlocked_modules', unlockedModules);
      await _initModules(); // Refresh the modules
    }
  }

  void _printUnlockedModules() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedModules = prefs.getStringList('unlocked_modules') ?? [];
    print('Unlocked Modules: $unlockedModules');
  }


  Future<void> _completeModule(int moduleIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('module_${moduleIndex}_completed', true);
    await _initModules(); // Refresh the modules
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text("Модулҳои нақлиётӣ"),
            ),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              "Модулҳои нақлиётӣ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
            backgroundColor: CupertinoColors.systemBackground,
            border: null,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'Омӯзиши нақлиёт',
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
                    'Модулҳоро бо тартиб омӯзед, аз модули 1 оғоз кунед',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: modules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final module = modules[index];
                      return _buildModuleCard(
                        context,
                        title: module['title'],
                        subtitle: module['subtitle'],
                        icon: module['icon'],
                        color: module['color'],
                        locked: module['locked'],
                        completed: module['completed'],
                        onTap: () {
                          if (!module['locked']) {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => LearningPage(
                                  onComplete: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => TestPage(
                                          onTestComplete: (passed) async {
                                            if (passed) {
                                              await _completeModule(index);
                                              if (modules.length > index + 1) {
                                                await _unlockModule(index + 1);
                                              }
                                            }
                                            Navigator.popUntil(
                                                context, (route) => route.isFirst);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required bool locked,
        required bool completed,
        required VoidCallback onTap,
      }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: locked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
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
                      color: locked ? CupertinoColors.systemGrey : color,
                      size: 22,
                    ),
                  ),
                  if (completed)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.checkmark,
                          size: 12,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                ],
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
                        color: locked
                            ? CupertinoColors.secondaryLabel
                            : CupertinoTheme.of(context)
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
              if (locked)
                const Icon(
                  CupertinoIcons.lock_fill,
                  size: 20,
                  color: CupertinoColors.systemGrey,
                )
              else
                const Icon(
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