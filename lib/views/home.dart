import 'package:flutter/material.dart';
import 'package:todo_app/model/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [];
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _dialogController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  void _removeTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Quieres eliminar esta tarea?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _tasks.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      _tasks[index].done = value ?? false;
    });
  }

  void _editTask(int index) {
    _dialogController.text = _tasks[index].title;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, setStateDialog) {
          return AlertDialog(
            title: const Text("Editar tarea"),
            content: Column(
              children: [
                TextField(controller: _dialogController, autofocus: true),
                TextField(controller: _descriptionController, autofocus: false),
                ElevatedButton.icon(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setStateDialog(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Seleccionar"),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _dialogController.clear();
                },
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_dialogController.text.isNotEmpty) {
                    setState(() {
                      _tasks[index].title = _dialogController.text;
                      _tasks[index].description = _descriptionController.text;
                      _tasks[index].date = _selectedDate ?? _tasks[index].date;
                    });
                    _dialogController.clear();
                    _descriptionController.clear();
                    _selectedDate = null;
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int pendingTasks = _tasks.where((t) => !t.done).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Tareas ($pendingTasks pendientes)"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text("No hay tareas agregadas !"))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: _tasks[index].done,
                            onChanged: (value) => _toggleTask(index, value),
                          ),
                          title: Text(
                            _tasks[index].title,
                            style: TextStyle(
                              decoration: _tasks[index].done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          onTap: () => _editTask(index),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 39, 207, 120),
                                  foregroundColor:
                                      Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                            
                                ),

                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Detalles de la tarea"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Título: ${_tasks[index].title}",
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Descripción: ${_tasks[index].description}",
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Fecha: ${_tasks[index].date.toLocal().toString().split(' ')[0]}",
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Cerrar"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  "Detalles",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeTask(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _dialogController.clear();
          _descriptionController.clear();
          _selectedDate = null;

          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  title: const Text("Nueva tarea"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _dialogController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: "Escribe una tarea...",
                        ),
                      ),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: "Coloque la descripción...",
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Sin fecha"
                                : "Fecha: ${_selectedDate!.toLocal()}".split(
                                    ' ',
                                  )[0],
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text("Seleccionar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _dialogController.clear();
                      },
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_dialogController.text.isNotEmpty) {
                          setState(() {
                            _tasks.add(
                              Task(
                                _dialogController.text,
                                description: _descriptionController.text,
                                date: _selectedDate ?? DateTime.now(),
                              ),
                            );
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Agregar"),
                    ),
                  ],
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _dialogController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

