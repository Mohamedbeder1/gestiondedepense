import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestiondedepance/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:gestiondedepance/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:gestiondedepance/screens/add_expense/blocs/get_categoriesbloc/get_categories_bloc.dart';
import 'package:gestiondedepance/screens/add_expense/views/add_expense.dart';
import 'package:gestiondedepance/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:gestiondedepance/screens/home/views/main_screen.dart';
import 'package:gestiondedepance/screens/stats/stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  Color selectedItem = Colors.blue;
  Color unselectedItem = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExpensesBloc, GetExpensesState>(
        builder: (context, state) {
      if (state is GetExpensesSuccess) {
        return Scaffold(
          bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              backgroundColor: Colors.white,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 3,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    color: index == 0 ? selectedItem : unselectedItem,
                  ),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.graph_square_fill,
                      color: index == 1 ? selectedItem : unselectedItem,
                    ),
                    label: 'Statistiques'),
                //BottomNavigationBarItem(icon: Icon(CupertinoIcons.home)),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              var newExpense = await Navigator.push(
                context,
                MaterialPageRoute<Expense>(
                  builder: (BuildContext context) => MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) =>
                            CreateCategoryBloc(FirebaseExpenseRepo()),
                      ),
                      BlocProvider(
                        create: (context) =>
                            GetCategoriesBloc(FirebaseExpenseRepo())
                              ..add(
                                GetCategories(),
                              ),
                      ),
                      BlocProvider(
                        create: (context) =>
                            CreateExpenseBloc(FirebaseExpenseRepo()),
                      ),
                    ],
                    child: AddExpense(),
                  ),
                ),
              );
              if (newExpense != null) {
                setState(() {
                  state.expenses.insert(0, newExpense);
                });
              }
            },
            shape: CircleBorder(),
            child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.primary,
                    ],
                    transform: GradientRotation(pi / 4),
                  ),
                ),
                child: Icon(CupertinoIcons.add)),
          ),
          body: index == 0
              ? MainScreen(expenses: state.expenses)
              : StatScreen(expenses: state.expenses),
        );
      } else {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }
}
