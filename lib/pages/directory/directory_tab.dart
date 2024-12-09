import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DirectoryTab extends StatelessWidget {
  final List<Category> categories = [
    Category(
      title: 'Правила дорожного движения',
      description: 'Общие правила для всех участников дорожного движения.',
      icon: CupertinoIcons.book,
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
      description: 'Знаки, предупреждающие о возможной опасности.',
      icon: CupertinoIcons.exclamationmark_triangle,
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
      description: 'Знаки, предоставляющие информацию водителям.',
      icon: CupertinoIcons.info_circle,
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
      description: 'Знаки, указывающие на запреты и ограничения.',
      icon: CupertinoIcons.xmark_circle,
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
      description: 'Знаки, указывающие на обязательные действия.',
      icon: CupertinoIcons.arrow_right,
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
      description: 'Знаки, устанавливающие приоритеты движения.',
      icon: CupertinoIcons.arrow_up_arrow_down,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryDetailsPage(category: category),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              category.icon,
                              size: 30,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  category.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.forward,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ListView.builder(
            itemCount: category.details.length,
            itemBuilder: (context, index) {
              final detail = category.details[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      detail,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Category {
  final String title;
  final String description;
  final IconData icon;
  final List<String> details;

  Category({
    required this.title,
    required this.description,
    required this.icon,
    required this.details,
  });
}
