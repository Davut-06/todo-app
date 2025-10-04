import 'package:flutter/material.dart';
// 1. Импорты для работы с API
import 'package:app_todo/services/auth_service.dart';
import 'package:app_todo/models/user.dart';
import 'todo_list_screen.dart'; // Перенаправление на этот экран

// Твой класс Home теперь становится экраном логина
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 2. Переменные для логина
  final TextEditingController _usernameController = TextEditingController(
    text: 'kminchelle',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '0lelplR',
  );
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // 3. Метод обработки входа (ОБНОВЛЕННЫЙ с отладкой)
  Future<void> _handleLogin() async {
    // --- ПЕЧАТЬ ДЛЯ ПРОВЕРКИ ---
    print('--- КНОПКА НАЖАТА, МЕТОД ВЫЗВАН ---');
    // ----------------------------

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User user = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      // Проверка, что виджет все еще в дереве (ВАЖНО для async)
      if (!mounted) return;

      // УСПЕХ: Перенаправляем на новый экран задач
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListScreen(user: user)),
      );
    } catch (e) {
      // ОШИБКА: Теперь показываем более детальную информацию
      print('--- ОШИБКА АУТЕНТИФИКАЦИИ В UI ---');
      print(e); // Вывод полного исключения из AuthService

      // Показываем ошибку, которую нам передал AuthService (включая статус и сообщение)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. UI для логина
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login to App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ls.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'LOGIN:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Login: kminchelle | Pass: 0lelplR',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
