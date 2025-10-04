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
            return Center(child: CircularProgressIndicator());
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
          return Center(child: Text('Start adding tasks!'));
        },
      ),
    );
  }
}
