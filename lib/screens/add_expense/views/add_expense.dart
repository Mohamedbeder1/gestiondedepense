import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiondedepance/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:gestiondedepance/screens/add_expense/blocs/get_categoriesbloc/get_categories_bloc.dart';
import 'package:gestiondedepance/screens/add_expense/views/category_creation.dart';
import 'package:gestiondedepance/utils/covert_color.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  late Expense expense;
  bool isLoading = false;

  @override
  void initState() {
    expense = Expense.empty;
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    expense.expenseId = Uuid().v1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          Navigator.pop(context, expense);
        } else if (state is CreateExpenseLoading) {
          setState(() {
            isLoading = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Ajouter des dépenses",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: expenseController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              FontAwesomeIcons.dollarSign,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        readOnly: true,
                        onTap: () {},
                        controller: categoryController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: expense.category == Category.empty
                              ? Colors.white
                              : parseColorString(expense.category.color),
                          hintText: 'Catégorie',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: expense.category == Category.empty
                              ? Icon(
                                  FontAwesomeIcons.list,
                                  color: Colors.grey,
                                  size: 16,
                                )
                              : Image.asset(
                                  'assets/${expense.category.icon}.png',
                                  scale: 2,
                                ),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              var newCategory =
                                  await getCategoryCreation(context);
                              setState(() {
                                state.categories.insert(0, newCategory);
                              });
                            },
                            icon: Icon(
                              FontAwesomeIcons.plus,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: state.categories.length,
                            itemBuilder: (context, int i) {
                              return Card(
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      expense.category = state.categories[i];
                                      categoryController.text =
                                          expense.category.name;
                                    });
                                  },
                                  leading: Image.asset(
                                    'assets/${state.categories[i].icon}.png',
                                    scale: 2,
                                  ),
                                  title: Text(state.categories[i].name),
                                  tileColor: parseColorString(
                                      state.categories[i].color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        textAlignVertical: TextAlignVertical.center,
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: expense.date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              Duration(days: 30),
                            ),
                          );
                          if (newDate != null) {
                            setState(() {
                              dateController.text =
                                  DateFormat('dd/MM/yy').format(newDate);
                              expense.date = newDate;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.clock,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : TextButton(
                                onPressed: () {
                                  setState(() {
                                    expense.amount =
                                        double.parse(expenseController.text);
                                    expense.category.totalExpense +=
                                        double.parse(expenseController.text);
                                  });
                                  context
                                      .read<CreateExpenseBloc>()
                                      .add(CreateExpense(expense));
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    )),
                                child: Text(
                                  'Enregistrer',
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white),
                                ),
                              ),
                      )
                    ],
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
