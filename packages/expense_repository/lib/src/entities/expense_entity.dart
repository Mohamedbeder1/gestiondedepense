import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class ExpenseEntity {
  String expenseId;
  Category category;
  DateTime date;
  double amount;

  ExpenseEntity({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
  });

  Map<String, Object?> toDoucument() {
    return {
      'expenseId': expenseId,
      'category': category.toEntity().toDoucument(),
      'date': date,
      'amount': amount,
    };
  }

  static ExpenseEntity fromDoucument(Map<String, dynamic> doc) {
    return ExpenseEntity(
        expenseId: doc['expenseId'],
        category:
            Category.fromEntity(CategoryEntity.fromDoucument(doc['category'])),
        date: (doc['date'] as Timestamp).toDate(),
        amount: doc['amount']);
  }
}
