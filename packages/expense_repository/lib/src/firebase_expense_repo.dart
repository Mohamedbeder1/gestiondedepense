import 'package:expense_repository/expense_repository.dart';

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection =
      FirebaseFirestore.instance.collection('catagories');
  final expenseCollection = FirebaseFirestore.instance.collection('expenses');

  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDoucument());
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory() async {
    try {
      return await categoryCollection.get().then((value) => value.docs
          .map((e) =>
              Category.fromEntity(CategoryEntity.fromDoucument(e.data())))
          .toList());
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<void> createExpense(Expense expense) async {
    try {
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toDoucument());
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      return await expenseCollection.get().then((value) => value.docs
          .map((e) => Expense.fromEntity(ExpenseEntity.fromDoucument(e.data())))
          .toList());
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }
}
