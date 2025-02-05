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

Map<String, double> calculateMonthTotals(List<Expense> expenses) {
  Map<String, double> monthTotals = {};

  for (var expense in expenses) {
    // Extract the month and year from the expense's date
    String monthYear =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';

    double amount = expense.amount;

    // If the monthYear already exists in the map, add the amount, otherwise set it
    if (monthTotals.containsKey(monthYear)) {
      monthTotals[monthYear] = monthTotals[monthYear]! + amount;
    } else {
      monthTotals[monthYear] = amount;
    }
  }

  return monthTotals;
}


//


//