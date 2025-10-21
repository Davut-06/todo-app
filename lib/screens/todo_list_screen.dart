import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Future<List<Todo>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _todosFuture = _loadTodos();
  }

  // 1. МЕТОД ЗАГРУЗКИ
  Future<List<Todo>> _loadTodos() async {
    try {
      final response = await _apiClient.getTodos();
      return (response as List).map((json) => Todo.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Ошибка загрузки задач: ${e.message}');
      return [];
    } catch (e) {
      print('Неизвестная ошибка: $e');
      return [];
    }
  }

  // 2. МЕТОД ПОКАЗА ДИАЛОГА ДОБАВЛЕНИЯ
  void _showAddTodoDialog() {
    _todoController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoController,
                decoration: const InputDecoration(hintText: "Enter task name"),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: "Enter description",
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_todoController.text.isNotEmpty) {
                  _addTodo(
                    _todoController.text,
                    _descriptionController.text.isEmpty
                        ? ''
                        : _descriptionController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 3. МЕТОД ПОКАЗА ДИАЛОГА РЕДАКТИРОВАНИЯ
  Future<void> _showEditTodoDialog(Todo todo) async {
    // Предзаполнение контроллеров данными редактируемой задачи
    _todoController.text = todo.todo;
    _descriptionController.text = todo.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoController,
                decoration: const InputDecoration(hintText: "Edit task name"),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: "Edit description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_todoController.text.isNotEmpty) {
                  // Вызов метода сохранения изменений
                  _saveEditedTodo(
                    todo.id,
                    _todoController.text,
                    _descriptionController.text.isEmpty
                        ? ''
                        : _descriptionController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 4. МЕТОД СОХРАНЕНИЯ РЕДАКТИРОВАННЫХ ДАННЫХ
  Future<void> _saveEditedTodo(
    int id,
    String newTitle, // ИСПРАВЛЕНО: newTitle вместо newTitile
    String newDescription,
  ) async {
    try {
      // Вызываем метод API для обновления
      await _apiClient.updateTodoContent(id, newTitle, newDescription);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task edited successfully')),
        );
        setState(() {
          _todosFuture = _loadTodos(); // Обновляем UI
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error editing task: ${e.message}')),
        );
      }
    }
  }

  // 5. МЕТОД ДОБАВЛЕНИЯ НОВОЙ ЗАДАЧИ
  Future<void> _addTodo(String todoText, String descriptionText) async {
    try {
      await _apiClient.createTodo(todoText, descriptionText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
        setState(() {
          _todosFuture = _loadTodos();
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: ${e.message}')),
        );
      }
    }
  }

  // 6. МЕТОД ИЗМЕНЕНИЯ СТАТУСА
  Future<void> _toggleTodoStatus(Todo todo) async {
    final newStatus = !todo.completed;

    try {
      await _apiClient.updateTodoStatus(todo.id, newStatus);

      if (mounted) {
        setState(() {
          _todosFuture = _loadTodos();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task status updated successfully!')),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.message}')),
        );
      }
    }
  }

  // 7. МЕТОД УДАЛЕНИЯ
  Future<void> _deleteTodo(int todoId) async {
    try {
      await _apiClient.deleteTodo(todoId);

      if (mounted) {
        setState(() {
          _todosFuture = _loadTodos();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully!')),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: ${e.message}')),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(Todo todoToDelete) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Deletion confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'Are you sure you want to delete this task?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Отображение имени и описания задачи
                Text(
                  'Name: ${todoToDelete.todo}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  'Description: ${todoToDelete.description.isEmpty ? 'No discription' : todoToDelete.description}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Закрыть диалог
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                // 1. Вызываем метод фактического удаления
                _deleteTodo(todoToDelete.id);
                // 2. Закрываем диалог
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          // Кнопка ВЫХОДА ИЗ СИСТЕМЫ
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _apiClient.logout();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
          IconButton(icon: const Icon(Icons.language), onPressed: () {}),
        ],

        backgroundColor: Colors.cyan,
      ),
      body: FutureBuilder<List<Todo>>(
        future: _todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return Dismissible(
                  key: ValueKey(todo.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {},

                  child: ListTile(
                    onTap: () => _toggleTodoStatus(todo),
                    title: Text(
                      todo.todo,
                      style: TextStyle(
                        decoration:
                            todo.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      todo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        decoration:
                            todo.completed ? TextDecoration.lineThrough : null,
                        color: Colors.grey[600],
                      ),
                    ),
                    // РЯД ИКОНОК
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmationDialog(todo),
                        ),
                        // Кнопка РЕДАКТИРОВАНИЯ
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed:
                              () => _showEditTodoDialog(
                                todo,
                              ), // Вызов диалога редактирования
                        ),
                        const SizedBox(width: 8),
                        // Иконка СТАТУСА
                        Icon(
                          todo.completed
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: todo.completed ? Colors.green : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Start adding tasks!'));
        },
      ),
      // Кнопка ДОБАВЛЕНИЯ
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog, // Вызов диалога добавления
        child: const Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
