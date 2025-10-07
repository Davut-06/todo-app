import 'package:flutter/material.dart';
import 'package:app_todo/models/user.dart';
import 'package:app_todo/models/todo.dart';
import 'package:app_todo/services/auth_service.dart';

class TodoListScreen extends StatefulWidget {
  final User user;
  const TodoListScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // *** ШАГ 1: ДОБАВЛЕНИЕ КОНТРОЛЛЕРА В КЛАСС СОСТОЯНИЯ ***
  final TextEditingController _todoController = TextEditingController();

  late Future<List<Todo>> _todosFuture;

  @override
  void initState() {
    super.initState();
    // Запускаем загрузку задач, используя ID и токен из объекта User
    _todosFuture = AuthService().fetchUserTodos(
      widget.user.id,
      widget.user.token,
    );
  }

  // *** ШАГ 2: МЕТОД ДЛЯ ОТОБРАЖЕНИЯ ДИАЛОГА ***
  void _showAddTodoDialog() {
    // Очищаем контроллер перед открытием, если там остался старый текст
    _todoController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(hintText: "Enter task name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_todoController.text.isNotEmpty) {
                  // Вызываем метод для отправки/имитации
                  _addTodo(_todoController.text);
                  Navigator.of(context).pop(); // Закрыть диалог
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  //  ШАГ 3: МЕТОД ИМИТАЦИИ ОТПРАВКИ (СТАТУС 200)
  Future<void> _addTodo(String todoText) async {
    // ИСПРАВЛЕНИЕ: Добавлена запятая после completed: false
    final mockTodo = Todo(
      id: 0,
      todo: todoText,
      completed: false, // <--- ИСПРАВЛЕНА ОШИБКА: пропущена запятая
      userId: widget.user.id,
    );

    try {
      // Предполагаем, что addTodo находится в AuthService и имитирует статус 200
      final addedTodo = await AuthService().addTodo(
        mockTodo,
        widget.user.id,
        widget.user.token,
      );

      // Успех! Это ваш имитированный статус 200
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully (Mock 200)!')),
        );

        // Обновляем список, чтобы новая задача появилась
        setState(() {
          // Перезагрузка списка (самый простой путь для мок-данных)
          _todosFuture = AuthService().fetchUserTodos(
            widget.user.id,
            widget.user.token,
          );
        });
      }
    } catch (e) {
      // Имитация ошибки
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mock Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${widget.user.firstName}'),
        backgroundColor: Colors.blueAccent,
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
                return ListTile(
                  title: Text(
                    todo.todo,
                    style: TextStyle(
                      decoration:
                          todo.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: Icon(
                    todo.completed ? Icons.check_circle : Icons.circle_outlined,
                    color: todo.completed ? Colors.green : Colors.grey,
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Start adding tasks!'));
        },
      ),
      // *** ШАГ 4: КНОПКА ВЫЗЫВАЕТ НОВЫЙ МЕТОД ***
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }
}
