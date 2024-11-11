import 'package:flutter/material.dart';
import 'package:to_do_list/api/firebase_conection.dart';
import 'package:to_do_list/models/category_model.dart';
import 'package:to_do_list/models/task_model.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({super.key});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  List<TaskModel> taskList = [];
  DateTime selectedDate = DateTime.now();
  String _dropdownValue = 'Todas';
  String _dropdownSelectedValue = 'Outras';
  List<TaskModel> filteredTaskList = [];
  List<DropdownMenuItem<String>> categorys = [];

  @override
  void initState() {
    super.initState();
    final future = FirebaseConection.loadData();
    future.then(
      (value) {
        setState(() {
          for (CategoryModel category in FirebaseConection.categorys) {
            categorys.add(DropdownMenuItem(
                value: category.value, child: Text(category.text)));
          }
          taskList = FirebaseConection.tasksProvider;
          filteredTaskList = taskList;
        });
      },
    );
  }

  void _dropdownCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _dropdownValue = selectedValue;
        if (selectedValue == 'Todas') {
          filteredTaskList = taskList;
        } else {
          filteredTaskList = taskList.where((task) {
            return task.category.contains(selectedValue);
          }).toList();
        }
      });
    }
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

  @override
  Widget build(BuildContext context) {
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
            dropdownColor: const Color.fromARGB(255, 225, 231, 174),
            iconEnabledColor: const Color.fromARGB(255, 223, 233, 149),
            style: const TextStyle(
                color: Color.fromARGB(255, 26, 30, 0), fontSize: 16.5),
            iconSize: 42,
            value: _dropdownValue,
            items: categorys,
            onChanged: _dropdownCallback,
            isDense: true,
            underline: DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor))),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 21.0),
            child: ListView.builder(
                itemCount: filteredTaskList.length,
                itemBuilder: (context, index) {
                  TaskModel task = filteredTaskList[index];
                  return ListTile(
                    onTap: () {
                      textEditingControllerTaskTitle.text = task.title;
                      textEditingControllerTaskDescription.text =
                          task.description;
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
                                      controller:
                                          textEditingControllerTaskTitle,
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
                                      items: categorys,
                                      onChanged: (selectedValue) {
                                        if (selectedValue is String) {
                                          setState(() {
                                            _dropdownSelectedValue =
                                                selectedValue;
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
                                      textEditingControllerTaskDescription
                                          .clear();
                                      textEditingControllerCategory.clear();
                                      textEditingControllerDate.clear();

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar')),
                                TextButton(
                                    onPressed: () {
                                      if (textEditingControllerTaskTitle
                                          .text.isNotEmpty) {
                                        TaskModel updatedTask = TaskModel(
                                            id: task.id,
                                            title:
                                                textEditingControllerTaskTitle
                                                    .text,
                                            description:
                                                textEditingControllerTaskDescription
                                                    .text,
                                            dueDate: selectedDate,
                                            isCompleted: task.isCompleted,
                                            category: _dropdownSelectedValue);
                                        Navigator.of(context).pop();
                                        setState(() {
                                          /* taskList[taskList.indexOf(task)] =
                                                updatedTask; */
/*                                             task = updatedTask;
 */
                                          taskList[taskList.indexWhere(
                                            (element) {
                                              return task.id == element.id;
                                            },
                                          )] = updatedTask;
                                        });

                                        FirebaseConection.updateTask(
                                            updatedTask);
                                      }
                                      textEditingControllerTaskTitle.clear();
                                      textEditingControllerTaskDescription
                                          .clear();
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
                            taskList[taskList.indexWhere(
                              (element) {
                                return task.id == element.id;
                              },
                            )] = task;
                          });
                          FirebaseConection.updateTask(task);
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
                            taskList.remove(task);
                          });
                          FirebaseConection.removeTask(task);
                        },
                        icon: const Icon(Icons.delete_outline_rounded)),
                  );
                }),
          ))
        ],
      ),
    );
  }
}
