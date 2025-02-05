import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:gestiondedepance/screens/stats/chart.dart';
import 'package:gestiondedepance/utils/important_calcule.dart';

class PricePoint {
  final double x;
  final double y;
  PricePoint(this.x, this.y);
}

class StatScreen extends StatelessWidget {
  final List<Expense> expenses;
  const StatScreen({required this.expenses, super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, double> monthTotals = calculateMonthTotals(expenses);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: LineChartWidget(monthTotals),
            )
          ],
        ),
      ),
    );
  }
}
