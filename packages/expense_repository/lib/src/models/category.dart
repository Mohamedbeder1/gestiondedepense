import '../entities/entities.dart';

class Category {
  String categoryId;
  String name;
  double totalExpense;
  String icon;
  String color;
  Category({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.icon,
    required this.totalExpense,
  });

  static final empty =
      Category(categoryId: '', name: '', color: '', icon: '', totalExpense: 0.0);

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      totalExpense: totalExpense,
      icon: icon,
      color: color,
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      categoryId: entity.categoryId,
      name: entity.name,
      color: entity.color,
      icon: entity.icon,
      totalExpense: entity.totalExpense,
    );
  }
}
