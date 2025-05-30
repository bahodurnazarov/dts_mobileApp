import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DirectoryTab extends StatelessWidget {
  final List<Category> categories = [
    Category(
      title: 'Правила дорожного движения',
      description: 'Общие правила для всех участников дорожного движения',
      icon: CupertinoIcons.book,
      color: Colors.indigo,
      details: [
        '1. Водитель обязан соблюдать установленные знаки и разметку.',
        '2. Уступайте дорогу пешеходам на пешеходных переходах.',
        '3. Запрещено использование мобильных телефонов во время движения.',
        '4. Соблюдайте скоростной режим согласно знакам.',
        '5. Не оставляйте транспортное средство на проезжей части без необходимости.',
        '6. Используйте ремни безопасности во время движения.',
        '7. Запрещено управление транспортом в состоянии алкогольного или наркотического опьянения.',
        '8. Не нарушайте правила обгона и перестроения.',
        '9. При приближении спецтранспорта с сигналом, уступите ему дорогу.',
        '10. Включайте ближний свет фар в условиях недостаточной видимости.',
      ],
    ),
    Category(
      title: 'Дорожные знаки: Предупреждающие',
      description: 'Знаки, предупреждающие о возможной опасности',
      icon: CupertinoIcons.exclamationmark_triangle,
      color: Colors.amber,
      details: [
        '1. Знак "Крутой поворот" предупреждает о резких поворотах.',
        '2. Знак "Неровная дорога" предупреждает о выбоинах или ухабах.',
        '3. Знак "Дети" указывает на близость детского учреждения.',
        '4. Знак "Железнодорожный переезд без шлагбаума" указывает на пересечение путей.',
        '5. Знак "Скользкая дорога" предупреждает о риске заноса.',
        '6. Знак "Дикие животные" предупреждает о возможном появлении животных на дороге.',
        '7. Знак "Сужение дороги" предупреждает о сужении полосы движения.',
        '8. Знак "Работы на дороге" указывает на проведение ремонтных работ.',
      ],
    ),
    Category(
      title: 'Дорожные знаки: Информационные',
      description: 'Знаки, предоставляющие информацию водителям',
      icon: CupertinoIcons.info_circle,
      color: Colors.blue,
      details: [
        '1. Знак "Парковка" показывает место для парковки.',
        '2. Знак "Пункт питания" указывает на наличие кафе или ресторана.',
        '3. Знак "Заправочная станция" информирует о месте для заправки топлива.',
        '4. Знак "Место отдыха" указывает на зоны отдыха вдоль дороги.',
        '5. Знак "Пункт технического обслуживания" показывает ближайшую мастерскую.',
        '6. Знак "Гостиница" указывает на расположение отелей поблизости.',
      ],
    ),
    Category(
      title: 'Дорожные знаки: Запрещающие',
      description: 'Знаки, указывающие на запреты и ограничения',
      icon: CupertinoIcons.xmark_circle,
      color: Colors.red,
      details: [
        '1. Знак "Движение запрещено" указывает на запрет въезда.',
        '2. Знак "Обгон запрещен" ограничивает обгон транспортных средств.',
        '3. Знак "Остановка запрещена" указывает на зоны, где нельзя останавливаться.',
        '4. Знак "Проезд без остановки запрещен" требует полной остановки.',
        '5. Знак "Поворот направо запрещен" запрещает поворот в указанную сторону.',
        '6. Знак "Стоянка запрещена" указывает на зону без парковки.',
        '7. Знак "Ограничение скорости" указывает максимально допустимую скорость.',
      ],
    ),
    Category(
      title: 'Дорожные знаки: Обязательные',
      description: 'Знаки, указывающие на обязательные действия',
      icon: CupertinoIcons.arrow_right,
      color: Colors.green,
      details: [
        '1. Знак "Движение прямо" указывает на обязательное направление.',
        '2. Знак "Круговое движение" указывает на въезд в круг.',
        '3. Знак "Включить ближний свет" требует включить фары.',
        '4. Знак "Объезд препятствия" указывает, как объехать препятствие.',
        '5. Знак "Движение с цепями противоскольжения" в зимний период.',
      ],
    ),
    Category(
      title: 'Дорожные знаки: Приоритетные',
      description: 'Знаки, устанавливающие приоритеты движения',
      icon: CupertinoIcons.arrow_up_arrow_down,
      color: Colors.purple,
      details: [
        '1. Знак "Главная дорога" указывает на приоритет движения.',
        '2. Знак "Уступи дорогу" требует пропустить транспорт с главной дороги.',
        '3. Знак "Стоп" требует полной остановки перед перекрестком.',
        '4. Знак "Конец главной дороги" указывает на смену приоритета.',
        '5. Знак "Преимущество встречного движения" запрещает проезд до уступки.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: CupertinoNavigationBar(
          middle: Text(
            'Дорожные правила',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          backgroundColor: CupertinoColors.systemGroupedBackground,
          // border: Border(
          //   bottom: BorderSide(
          //     color: CupertinoColors.inactiveGray,
          //     width: 0.5,
          //   ),
          // ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(category: category);
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsPage(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
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
    );
  }
}

class CategoryDetailsPage extends StatelessWidget {
  final Category category;

  const CategoryDetailsPage({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: CupertinoNavigationBar(
          middle: Text(
            category.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
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
          itemCount: category.details.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final detail = category.details[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: CupertinoColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: category.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      detail,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Category {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> details;

  Category({
    required this.title,
    required this.description,
    required this.icon,
    required this.details,
    required this.color,
  });
}