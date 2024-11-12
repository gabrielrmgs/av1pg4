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
  bool loadingData = true;
  String _dropdownSelectedValue = 'Todas';

  final provider = TaskProvider();

  @override
  void initState() {
    super.initState();
    final future = provider.loadData();
    future.then(
      (value) {
        setState(() {
          provider.filteredTaskList = provider.taskList;
          loadingData = false;
        });
      },
    );
  }

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

  Widget dueDateCheck(TaskModel task) {
    if (task.dueDate.isBefore(DateTime.now())) {
      return const Text('Tarefa expirada');
    } else {
      if (task.dueDate.difference(DateTime.now()).inDays <= 5) {
        return const Text('Expiração próxima');
      } else {
        return Text(
            'Prazo: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}');
      }
    }
  }

  Widget bodyTask() {
    if (loadingData == true) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      ));
    } else {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        child: Column(
          children: [
            DropdownButton(
              hint: const Text('Filtrar categoria'),
              dropdownColor: const Color.fromARGB(255, 226, 228, 207),
              iconEnabledColor: const Color.fromARGB(255, 189, 197, 125),
              style: const TextStyle(
                  color: Color.fromARGB(255, 26, 30, 0), fontSize: 16.5),
              iconSize: 42,
              value: provider.dropdownValue,
              items: provider.dropdownCategoriesList,
              onChanged: provider.dropdownCallback,
              isDense: true,
              underline: DecoratedBox(
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Theme.of(context).primaryColor))),
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(top: 21.0),
                    child: taskOrAdd()))
          ],
        ),
      );
    }
  }

  Widget taskOrAdd() {
    if (provider.tasksIsEmpty) {
      return const Center(
          child: Text('Adicione sua primeira tarefa! ⭐',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(150, 26, 30, 0),
              )));
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
                                items: provider.dropdownCategoriesList,
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

                                  Navigator.of(context).pop();
                                  setState(() {
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
                      provider.checked(task);
                    });
                  },
                ),
              ),
              title: Text(task.title),
              subtitle: dueDateCheck(task),
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
                  trailing: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 18,
                  ),
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
                                      id: DateTime.now().toString(),
                                      value: textEditingControllerCategory.text,
                                      text: textEditingControllerCategory.text);
                                  provider.saveNewCategory(newCategory);
                                  textEditingControllerCategory.clear();
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Salvar"))
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text("Remover categoria"),
                  leading: const Icon(
                    Icons.remove_circle_outline_outlined,
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_outlined, size: 18),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Lista de categorias"),
                          content: SizedBox(
                            height: 300,
                            width: 300,
                            child: ListView.builder(
                              itemCount: provider.categoryList.length,
                              itemBuilder: (context, index) {
                                CategoryModel categoryModel =
                                    provider.categoryList[index];
                                return ListTile(
                                  title: Text(categoryModel.value),
                                  trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          provider
                                              .removeCategory(categoryModel);
                                        });
                                      },
                                      icon: const Icon(
                                          Icons.delete_outline_rounded)),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Fechar"))
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
          body: bodyTask(),
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
                                items: provider.dropdownCategoriesList,
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
                                /* setState(
                                  () { */
                                provider.saveNewTask(newTask);
                                /* },
                                ); */
                                Navigator.of(context).pop();
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
