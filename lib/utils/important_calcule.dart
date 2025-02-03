// Function to calculate category-wise totals
import 'package:expense_repository/expense_repository.dart';

Map<String, double> calculateCategoryTotals(List<Expense> expenses) {
  Map<String, double> categoryTotals = {};

  for (var expense in expenses) {
    String categoryName = expense.category.name;
    double amount = expense.amount;

    if (categoryTotals.containsKey(categoryName)) {
      categoryTotals[categoryName] = categoryTotals[categoryName]! + amount;
    } else {
      categoryTotals[categoryName] = amount;
    }
  }

  return categoryTotals;
}

double calculateTotalExpenses(List<Expense> expenses) {
  double total = 0;
  for (var expense in expenses) {
    total += expense.amount;
  }
  return total;
}

double calculateTotalExpenset(Map<String, double> categoryTotals) {
  double totalExpense = 0.0;
  categoryTotals.forEach((category, amount) {
    totalExpense += amount;
  });

  return totalExpense;
}
