import 'package:flutter/material.dart';
import 'package:to_do_list/models/category_model.dart';
import 'package:to_do_list/models/task_model.dart';
import 'package:to_do_list/providers/task_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
/*   String _dropdownValue = 'Todas';
 */
  String _dropdownSelectedValue = 'Todas';
/*   List<TaskModel> filteredTaskList = [];
 */
  List<DropdownMenuItem<String>> categories = [];
  final provider = TaskProvider();

  @override
  void initState() {
    super.initState();
    final future = provider.loadData();
    future.then(
      (value) {
        setState(() {
          for (CategoryModel category in provider.categoryList) {
            categories.add(DropdownMenuItem(
                value: category.value, child: Text(category.text)));
          }
          provider.filteredTaskList = provider.taskList;
          //loadingData = false;
        });
      },
    );
  }

  /* void _dropdownCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _dropdownValue = selectedValue;
        if (selectedValue == 'Todas') {
          filteredTaskList = provider.taskList;
        } else {
          filteredTaskList = provider.taskList.where((task) {
            return task.category.contains(selectedValue);
          }).toList();
        }
      });
    }
  } */

  /*  void _testAtt(TaskModel newTask) {
    setState(() {
      taskList.clear();
      taskList = FirebaseConection.tasksProvider;
    });
  } */

  TextEditingController textEditingControllerTaskTitle =
      TextEditingController();
  TextEditingController textEditingControllerTaskDescription =
      TextEditingController();
  TextEditingController textEditingControllerDate = TextEditingController();
  TextEditingController textEditingControllerCategory = TextEditingController();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        textEditingControllerDate.text = picked.toString().split(" ")[0];
      });
    }
  }

  Widget taskOrAdd() {
    if (provider.tasksIsEmpty) {
      return const Center(
          child: Text(
        'Adicione sua primeira tarefa!',
        style: TextStyle(
            decorationStyle: TextDecorationStyle.dotted,
            decoration: TextDecoration.underline),
      ));
    } else {
      return ListView.builder(
          itemCount: provider.filteredTaskList.length,
          itemBuilder: (context, index) {
            TaskModel task = provider.filteredTaskList[index];
            return ListTile(
              onTap: () {
                textEditingControllerTaskTitle.text = task.title;
                textEditingControllerTaskDescription.text = task.description;
                textEditingControllerDate.text =
                    task.dueDate.toString().split(" ")[0];
                _dropdownSelectedValue = task.category;
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Editar tarefa'),
                        content: SizedBox(
                          height: 300.0,
                          child: Column(
                            children: [
                              TextField(
                                controller: textEditingControllerTaskTitle,
                                decoration: const InputDecoration(
                                    labelText: 'Título',
                                    helperText:
                                        'Escreva o título da atividade'),
                              ),
                              TextField(
                                controller:
                                    textEditingControllerTaskDescription,
                                decoration: const InputDecoration(
                                    labelText: 'Descrição',
                                    helperText: 'Descreva a atividade'),
                                maxLines: 2,
                              ),
                              DropdownButton(
                                value: _dropdownSelectedValue,
                                items: categories,
                                onChanged: (selectedValue) {
                                  if (selectedValue is String) {
                                    setState(() {
                                      _dropdownSelectedValue = selectedValue;
                                    });
                                  }
                                },
                              ),
                              TextField(
                                controller: textEditingControllerDate,
                                decoration: const InputDecoration(
                                  labelText: 'DATA DE VENCIMENTO',
                                  filled: true,
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () {
                                  _selectDate();
                                },
                              )
                            ],
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.spaceBetween,
                        actions: [
                          TextButton(
                              onPressed: () {
                                textEditingControllerTaskTitle.clear();
                                textEditingControllerTaskDescription.clear();
                                textEditingControllerCategory.clear();
                                textEditingControllerDate.clear();

                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () {
                                if (textEditingControllerTaskTitle
                                    .text.isNotEmpty) {
                                  task.title =
                                      textEditingControllerTaskTitle.text;
                                  task.description =
                                      textEditingControllerTaskDescription.text;
                                  task.dueDate = selectedDate;
                                  task.category = _dropdownSelectedValue;

                                  /* task.copyWith(
                                                  id: task.id,
                                                  title:
                                                      textEditingControllerTaskTitle
                                                          .text,
                                                  description:
                                                      textEditingControllerTaskDescription
                                                          .text,
                                                  dueDate: selectedDate,
                                                  isCompleted: task.isCompleted,
                                                  category:
                                                      _dropdownSelectedValue); */
                                  /* TaskModel updatedTask = TaskModel(
                                                  id: task.id,
                                                  title:
                                                      textEditingControllerTaskTitle
                                                          .text,
                                                  description:
                                                      textEditingControllerTaskDescription
                                                          .text,
                                                  dueDate: selectedDate,
                                                  isCompleted: task.isCompleted,
                                                  category:
                                                      _dropdownSelectedValue); */
                                  Navigator.of(context).pop();
                                  setState(() {
                                    /* provider.taskList[provider
                                                    .taskList
                                                    .indexWhere(
                                                  (element) {
                                                    return task.id ==
                                                        element.id;
                                                  },
                                                )] = task; */
                                    provider.updateTask(task);
                                  });
                                }
                                textEditingControllerTaskTitle.clear();
                                textEditingControllerTaskDescription.clear();
                              },
                              child: const Text('Atualizar')),
                        ],
                      );
                    });
                  },
                );
              },
              leading: Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  value: task.isCompleted,
                  onChanged: (isChecked) {
                    task.isCompleted = isChecked!;
                    setState(() {
                      /* provider
                                      .taskList[provider.taskList.indexWhere(
                                    (element) {
                                      return task.id == element.id;
                                    },
                                  )] = task; */
                      provider.checked(task);
                    });
                  },
                ),
              ),
              title: Text(task.title),
              subtitle: Text(
                  (task.dueDate.difference(DateTime.now()).inDays <= 5)
                      ? 'Validade próxima'
                      : ''),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      provider.taskList.remove(task);
                    });
                    provider.removeTask(task);
                  },
                  icon: const Icon(Icons.delete_outline_rounded)),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            title: const Text('Lista de Tarefas'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 120.0,
                  child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 10.0, 0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: const Text(
                        "Opções",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          color: Colors.white,
                        ),
                      )),
                ),
                ListTile(
                  title: const Text("Remover todas as tarefas"),
                  leading: const Icon(Icons.delete_outline_rounded),
                  onTap: () {
                    provider.removeAllTasks();
                    /* setState(() {
                    taskList.clear();
                  }); */
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text("Criar nova categoria"),
                  leading: const Icon(Icons.add_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Nova Categoria"),
                          content: SizedBox(
                            height: 210,
                            child: Column(
                              children: [
                                TextField(
                                  controller: textEditingControllerCategory,
                                  decoration: const InputDecoration(
                                    label: Text("Nome da Categoria"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  CategoryModel newCategory = CategoryModel(
                                      value: textEditingControllerCategory.text,
                                      text: textEditingControllerCategory.text);
                                  provider.saveNewCategory(newCategory);
                                  /* setState(() {
                                    categories.add(DropdownMenuItem(
                                      value: newCategory.value,
                                      child: Text(newCategory.text),
                                    ));
                                  }); */
                                  textEditingControllerCategory.clear();
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Salvar"))
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
            ),
            child: Column(
              children: [
                DropdownButton(
                  hint: const Text('Filtrar categoria'),
                  dropdownColor: const Color.fromARGB(255, 225, 231, 174),
                  iconEnabledColor: const Color.fromARGB(255, 223, 233, 149),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 26, 30, 0), fontSize: 16.5),
                  iconSize: 42,
                  value: provider.dropdownValue,
                  items: categories,
                  onChanged: provider.dropdownCallback,
                  isDense: true,
                  underline: DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor))),
                ),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: taskOrAdd()))
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            //Criar tarefa
            onPressed: () {
              textEditingControllerDate.clear();
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                      title: const Text('Nova tarefa'),
                      content: SizedBox(
                        height: 300.0,
                        child: Column(
                          children: [
                            TextField(
                              controller: textEditingControllerTaskTitle,
                              decoration: const InputDecoration(
                                  labelText: 'Título',
                                  helperText: 'Escreva o título da atividade'),
                            ),
                            TextField(
                              controller: textEditingControllerTaskDescription,
                              decoration: const InputDecoration(
                                  labelText: 'Descrição',
                                  helperText: 'Descreva a atividade'),
                              maxLines: 2,
                            ),
                            DropdownButton(
                                value: _dropdownSelectedValue,
                                items: categories,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      _dropdownSelectedValue = value!;
                                    },
                                  );
                                }),
                            TextField(
                              controller: textEditingControllerDate,
                              decoration: const InputDecoration(
                                labelText: 'DATA DE VENCIMENTO',
                                filled: true,
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () {
                                _selectDate();
                              },
                            )
                          ],
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      actions: [
                        TextButton(
                            onPressed: () {
                              textEditingControllerTaskTitle.clear();
                              textEditingControllerTaskDescription.clear();
                              textEditingControllerCategory.clear();
                              textEditingControllerDate.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () {
                              if (textEditingControllerTaskTitle
                                  .text.isNotEmpty) {
                                TaskModel newTask = TaskModel(
                                    id: DateTime.now().toString(),
                                    title: textEditingControllerTaskTitle.text,
                                    description:
                                        textEditingControllerTaskDescription
                                            .text,
                                    dueDate: selectedDate,
                                    category: _dropdownSelectedValue);
                                setState(
                                  () {
                                    provider.saveNewTask(newTask);
                                  },
                                );
                                Navigator.of(context).pop();
                                //_testAtt(newTask);
                              }
                              textEditingControllerTaskTitle.clear();
                              textEditingControllerTaskDescription.clear();
                              textEditingControllerCategory.clear();
                              textEditingControllerDate.clear();
                            },
                            child: const Text('Salvar')),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.add_task_rounded),
          ),
        );
      },
    );
  }
}
