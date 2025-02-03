class CategoryEntity {
  String categoryId;
  String name;
  double totalExpense;
  String icon;
  String color;
  CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.icon,
    required this.totalExpense,
  });
  Map<String, Object?> toDoucument() {
    return {
      'categoryId': categoryId,
      'name': name,
      'color': color,
      'icon': icon,
      'totalExpense': totalExpense,
    };
  }

  static CategoryEntity fromDoucument(Map<String, dynamic> doc) {
    return CategoryEntity(
        categoryId: doc['categoryId'],
        name: doc['name'],
        color: doc['color'],
        icon: doc['icon'],
        totalExpense: doc['totalExpense']);
  }
}
